# Port Scanner

E' uno script bash che si comporta come un **port scanner** per individuare quali porte di un host sono in ascolto. Permette di specificare host, range di porte e protocollo da riga di comando, con relativa sanificazione dell'input.

Lo scan viene effettuato tramite un **ciclo** che utilizza il comando `nc` per ogni porta, senza utilizzare la feature di scan integrata (`-z`).

---

## Comando

```bash
./portscanner -h IP -r PORTA_INIZIALE-PORTA_FINALE -p PROTOCOLLO
```

### Argomenti

| Opzione | Descrizione | Esempio |
|---------|-------------|---------|
| `-h` | Indirizzo IP target | `-h 192.168.1.10` |
| `-r` | Range di porte nel formato `inizio-fine` | `-r 1-1000` |
| `-p` | Protocollo: `TCP` o `UDP` | `-p TCP` |

### Esempio

```bash
./portscanner -h 192.168.1.10 -r 1-100 -p TCP
```

---

## Funzionamento

Lo script procede per fasi:

1. **Acquisizione dei parametri**: tramite il comando `getopts` (`-h` host, `-r` range, `-p` protocollo).
2. **Separazione del range in porta iniziale e finale**: la stringa `inizio-fine` viene divisa con `awk -F'-'` in porta iniziale (`portai`) e porta finale (`portaf`).
3. **Sanificazione dell'input**: gli argomenti vengono validati prima della scansione.
4. **Verifica di raggiungibilità dell'host**: avviene tramite il comando `ping`, accompagnata da una barra di avanzamento eseguita in background.
5. **Scansione**: in base al protocollo scelto, un ciclo `for` prova ogni porta dell'intervallo con nc per capire se è in ascolto

---

## Sanificazione dell'input

Lo script effettua i seguenti controlli prima di scansionare:

- **Presenza degli argomenti e numero massimo**: host, range e protocollo non devono essere vuoti, e non devono essere passati più di 6 argomenti complessivi (`$# -gt 6`), che è il massimo previsto da `-h IP -r RANGE -p PROTO`.
- **Validità dell'IP**: l'host deve corrispondere a un indirizzo IPv4 valido, verificato tramite espressione regolare che accetta solo ottetti compresi tra `0` e `255`.
- **Validità del range di porte**: porta iniziale e finale non devono superare il valore massimo `65535`, e la stringa del range non deve contenere lettere.
- **Validità del protocollo**: sono ammessi unicamente i valori `TCP` o `UDP`; qualsiasi altro valore viene respinto.

Ogni verifica è associata ad un **codice di uscita**:

### Codici di uscita

| Codice | Significato |
|--------|-------------|
| `1` | Argomenti mancanti, vuoti o troppi |
| `2` | IP non valido |
| `3` | Range di porte non valido|
| `4` | Protocollo non valido |
| `5` | Host non raggiungibile |
| `6` | Interruzione forzata |

---

## Verifica di raggiungibilità e barra di caricamento

Prima della scansione, lo script verifica che l'host risponda con:

```bash
timeout 4 ping -c 4 "$host"
```

Vengono inviati 4 pacchetti ICMP **"echo request"** (`-c 4`), con un timeout complessivo di 4 secondi (`timeout 4`) per non restare bloccati su host che non rispondono. Se il `ping` fallisce, lo script termina con il messaggio "**HOST NON RAGGIUNGIBILE**".

Nel mentre viene mostrata una **barra di caricamento** lanciata in background (`barra &`). Il suo PID viene salvato (`pid=$!`) e la funzione `chiusura` la interrompe una volta terminata la verifica di raggiungibilità.

---

## Tipo di pacchetti inviati e verifica

Per ogni porta, lo script esegue:

Per il **protocollo TCP**

```bash
echo | nc -w 1 "$host" "$porta" &> /dev/null
```
Per il **protocollo UDP**

```bash
echo | nc -u -w 1 "$host" "$porta" &> /dev/null
```

dove:

- `nc` tenta di contattare la porta
- `-u` serve per utilizzare pacchetti UDP invece di quelli TCP
- `-w 1` imposta un timeout di 1 secondo, così il comando non resta bloccato
- `echo |` invia un input vuoto a netcat, evitando di rimanere in attesa all'infinito
- `&> /dev/null` scarta sia l'output standard sia gli errori, perché interessa solo l'**esito** del comando, non la risposta.

L'esito viene letto dall'`if`, che valuta l'`exit status` di `nc`: 
- stato `0` → connessione riuscita → porta in ascolto
- stato diverso da `0` → porta non in ascolto

### Scansione TCP

Prima di scambiare dati, client e server eseguono il **three-way handshake** (SYN → SYN-ACK → ACK). Questo rende la verifica **affidabile**:

- **Porta aperta**: il server completa l'handshake (risponde con SYN-ACK) → la connessione si stabilisce → `nc` esce con stato `0` → "in ascolto".
- **Porta chiusa**: il sistema risponde con una flag `RST` → la connessione viene rifiutata → "non in ascolto".

Quindi, nel caso dello scan TCP, lo stato della porta viene determinato in base all'esito del tentativo di connessione: se il **three-way handshake** si completa correttamente, la porta è aperta, invece se il sistema risponde con un pacchetto RST, la porta è chiusa. Nel caso in cui il pacchetto TCP non possa arrivare al servizio, risponde con un pacchetto ICMP 

### Scansione UDP

Mentre lo scan TCP è **affidabile**, lo scan UDP **non lo è**, e questa è una conseguenza della natura del protocollo.

#### Perché UDP è inaffidabile

- **Nessun handshake**: UDP non stabilisce una connessione. `nc` invia un **datagrammma** senza poter verificare immediatamente se la porta è aperta o se è presente un servizio in ascolto.
- **Porta aperta = silenzio**: Una porta UDP aperta di solito non risponde a un **datagramma** vuoto, perché il servizio si aspetta richieste precise e ignora quelle non valide. Però “**nessuna risposta**” non vuol dire necessariamente che la porta sia aperta: può succedere anche se il datagrammma è andato perso o se un firewall blocca le risposte. Per questo lo scan UDP non permette di sapere con certezza se la porta è aperta o chiusa
- **Porta chiusa = pacchetto ICMP, ma inaffidabile**: una porta chiusa dovrebbe generare un messaggio ICMP "`port unreachable`", ma questo segnale è spesso filtrato dai firewall e soggetto a limiti da parte del sistema operativo.

### Comportamento osservato

Il risultato dello scan UDP cambia a seconda dell'ambiente:

- **Su localhost (`127.0.0.1`)**: i messaggi ICMP "port unreachable" arrivano subito e non sono filtrati, quindi le porte chiuse vengono rilevate correttamente.
- **Su un host remoto**: le porte chiuse smettono di dare un segnale chiaro e diventano indistinguibili da quelle aperte. Il risultato perde affidabilità.

### Note

- **ICMP** (Internet Control Message Protocol) è un protocollo della rete usato per inviare messaggi di controllo e di errore
- **Un Echo Request** è un tipo di messaggio ICMP usato per verificare se un host è raggiungibile.
- **getopts** è un comando utilizzato negli script bash per leggere e gestire le opzioni passate ad uno script