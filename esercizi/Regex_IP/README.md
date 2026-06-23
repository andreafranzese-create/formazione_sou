# Classificatore di indirizzi IPv4
## SCRIPT

```bash
#!/usr/bin/env bash

read -p "Inserire un'indirizzo IPV4: " ip

if [[ $ip =~ ^0\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo "IP: $ip"
	echo "Classe: A"
        echo "Tipo: Indirizzo zero"

elif [[ $ip =~ ^10\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: A"
        echo  "Tipo: Privato"

elif [[ $ip =~ ^127\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: A"
        echo  "Tipo: Loopback"

elif [[ $ip =~ ^169\.254\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: B"
        echo  "Tipo: Link-local"

elif [[ $ip =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: B"
        echo  "Tipo: Privato"

elif [[ $ip =~ ^192\.0\.2\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: C"
        echo  "Tipo: TEST-NET-1"

elif [[ $ip =~ ^192\.88\.99\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: C"
        echo  "Tipo: Anycast 6to4"

elif [[ $ip =~ ^192\.168\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: C"
        echo  "Tipo: Privato"

elif [[ $ip =~ ^198\.1[8-9]\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: C"
        echo  "Tipo: Test di rete"

elif [[ $ip =~ ^(22[4-9]|23[0-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: D"
        echo  "Tipo: Multicast"

elif [[ $ip =~ ^(24[0-9]|25[0-5])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
        echo
	echo  "IP: $ip"
        echo  "Classe: E"
        echo  "Tipo: Riservati"
else
	echo "ERRORE non è stato inserito un ip valido"
        exit 1
fi
```

Questo script richiede come input un indirizzo IPv4 e lo classifica stampando la **classe** (A, B, C, D, E) e il **tipo** (rete privata, loopback,
link-local, multicast, indirizzi riservati, anycast o TEST-NET).
Per la verifica dell'input immesso vengono utilizzate espressioni regolari.


# Funzionamento

Lo script è interattivo: non prende argomenti da riga di comando, ma chiede
**l'indirizzo IP** tramite prompt.

Viene mostrato:

```
Inserire un'indirizzo IPV4:
```

Nel caso in cui viene inserito un indirizzo IP sbagliato esce dallo script con messaggio di errore. Invece nel caso in cui sia giusto mostra:

```bash
IP: x.x.x.x
Classe: x
Tipo: x
```

## Esempi

```text
./classifica-ip.sh

Inserire un'indirizzo IPV4: 192.168.1.10

IP: 192.168.1.10
Classe: C
Tipo: Privato
```

```text
$ ./classifica-ip.sh

Inserire un'indirizzo IPV4: 127.0.0.1

IP: 127.0.0.1
Classe: A
Tipo: Loopback
```

```text
$ ./classifica-ip.sh

Inserire un'indirizzo IPV4: 999.1.1.1

ERRORE non è stato inserito un ip valido
```

## Validazione REGEX

Ogni IPV4 è composto da quattro ottetti, ogni ottetto deve essere un numero tra 0 e 255 che viene verificato tramite la regex estesa:

```bash
(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])
```

- `25[0-5]` -> da 250 a 255
- `2[0-4][0-9]` -> da 200 a 249
- `1[0-9]{2}` -> da 100 a 199
- `[1-9]?[0-9]` -> da 0 a 99 (il ? indica una cifra iniziale opzionale)
- Il `{2}` ripete due volte il blocco che lo precedo
- Il `^` viene utilizzato per definire l'inizio della stringa
- Il `$` viene utilizzato per definire la fine della stringa

Le espressioni regolari sono state progettate per riconoscere specifiche classi o tipi di indirizzi IPv4, identificandoli tramite precisi intervalli numerici:

#### Indirizzi zero (classe A)

```bash
^0\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP privati (classe A)

```bash
^10\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP Loopback (classe A)

```bash
^127\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP Linklocal (classe B)

```bash
^169\.254\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP privati (classe B)

```bash
^172\.(1[6-9]|2[0-9]|3[0-1])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```
#### IP TEST-NET-1 (classe C)

```bash
^192\.0\.2\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP anycast (classe C)

```bash
^192\.88\.99\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP privati (classe C)

```bash
^192\.168\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP benchmark (classe C)

```bash
^198\.1[8-9]\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP multicast (classe D)

```bash
^(22[4-9]|23[0-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
``` 

#### IP riservati classe E

```bash
^(24[0-9]|25[0-5])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

## Espressioni regolari: base vs estese

Le espressioni regolari di base (BRE) utilizzano una sintassi più semplice e richiedono caratteri di escape (\\) per alcuni operatori speciali, mentre le espressioni regolari estese (ERE) permettono l'utilizzo diretto di operatori come +, ?, | e ().
## GREP vs EGREP
Il comando `grep` viene utilizzato per le regex di base, mentre il comando `egrep` viene utilizzato per le regex estese