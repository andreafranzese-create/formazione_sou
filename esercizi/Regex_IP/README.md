# Classificatore di indirizzi IPv4

Lo script richiede come input un indirizzo IPv4 e lo classifica stampando la **classe** (A, B, C, D, E) e il **tipo** (rete privata, loopback,
link-local, multicast, indirizzi riservati, anycast, TEST-NET o pubblici).
Per la verifica dell'input immesso vengono utilizzate espressioni regolari.


# Funzionamento

Lo script è interattivo: non prende argomenti da riga di comando, ma chiede
**l'indirizzo IP** tramite prompt.

Viene mostrato:

```
Inserire un'indirizzo IPv4:
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

Inserire un'indirizzo IPv4: 192.168.1.10

IP: 192.168.1.10
Classe: C
Tipo: Privato
```

```text
./classifica-ip.sh

Inserire un'indirizzo IPv4: 127.0.0.1

IP: 127.0.0.1
Classe: A
Tipo: Loopback
```

```text
./classifica-ip.sh

Inserire un'indirizzo IPv4: 999.1.1.1

ERRORE non è stato inserito un ip valido
```

---
## Validazione REGEX

Ogni IPv4 è composto da quattro ottetti, ogni ottetto deve essere un numero tra 0 e 255 che viene verificato tramite la regex estesa:

```text
(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])
```

- `25[0-5]` -> da 250 a 255
- `2[0-4][0-9]` -> da 200 a 249
- `1[0-9]{2}` -> da 100 a 199
- `[1-9]?[0-9]` -> da 0 a 99 (il ? indica una cifra iniziale opzionale)
- Il `{2}` ripete due volte il blocco che lo precedo
- Il `^` viene utilizzato per definire l'inizio della stringa
- Il `$` viene utilizzato per definire la fine della stringa
---
##  IPv4

Nello script, inizialmente viene verificato che l'indirizzo inserito sia un indirizzo `IPv4` valido:

```text
^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```
## Classe

Successivamente viene determinata la classe dell'indirizzo IP in base al valore del primo ottetto:

#### Classe A

Intervallo di IP: **1.0.0.0 - 126.255.255.255**

```text
^(12[0-6]|1[0-1][0-9]|[1-9][0-9]|[1-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### Classe B

Intervallo di IP: **128.0.0.0 - 191.255.255.255**

```text
^(19[0-1]|1[3-8][0-9]|12[8-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### Classe C

Intervallo di IP: **192.0.0.0 - 223.255.255.255**

```text
^(22[0-3]|2[0-1][0-9]|19[2-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ 
```

#### Classe D

Intervallo di IP: **224.0.0.0 - 239.255.255.255**

```text
^(23[0-9]|22[4-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### Classe E

Intervallo di IP: **240.0.0.0 - 255.255.255.255**

```text
^(24[0-9]|25[0-5])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

## Tipo

Infine viene verificato il `tipo` di indirizzo IP: 

#### Indirizzi zero
Intervallo di **IP: 0.0.0.0 - 0.255.255.255**

```text
^0\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP privati

Intervallo di IP: **10.0.0.0 - 10.255.255.255**

```text
^10\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP Loopback

Intervallo di IP: **127.0.0.0 - 127.255.255.255**

```text
^127\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP Linklocal

Intervallo di IP: **169.254.0.0 - 169.254.255.255**

```text
^169\.254\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP privati

Intervallo di IP: **172.16.0.0 - 172.31.255.255**

```text
^172\.(1[6-9]|2[0-9]|3[0-1])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```
#### IP TEST-NET-1 

Intervallo di IP: **192.0.2.0 - 192.0.2.255**

```text
^192\.0\.2\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP anycast

Intervallo di IP: **192.88.99.0 - 192.88.99.255**

```text
^192\.88\.99\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP privati 

Intervallo di IP: **192.168.0.0 - 192.168.255.255**

```text
^192\.168\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP benchmark

Intervallo di IP: **198.18.0.0 - 198.19.255.255**

```text
^198\.1[8-9]\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

#### IP multicast

Intervallo di IP: **224.0.0.0 - 239.255.255.255**

```text
^(22[4-9]|23[0-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
``` 

#### IP riservati 

Intervallo di IP: **240.0.0.0 - 255.255.255.255**

```text
^(24[0-9]|25[0-5])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
```

## Espressioni regolari: base vs estese

Le espressioni regolari di base (BRE) utilizzano una sintassi più semplice e richiedono caratteri di escape (\\) per alcuni operatori speciali, mentre le espressioni regolari estese (ERE) permettono l'utilizzo diretto di operatori come +, ?, | e ().
## GREP vs EGREP
Il comando `grep` viene utilizzato per le regex di base, mentre il comando `egrep` viene utilizzato per le regex estese




