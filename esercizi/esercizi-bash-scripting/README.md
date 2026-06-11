
## SCRIPT #1
```bash 
#!/usr/bin/env bash

while true; do
read -p "Inserire il file da controllare: " file
if [ -f "$file" ] && [ -s "$file" ]; then
risultato=$(sort "$file" | uniq -dc | sort -k1 -k2 -nr | head -n 3)
 echo "I tre indirizzi IP più frequenti sono: "
    echo "$risultato"
    exit 0
else
    echo  "Inserire un file valido"
fi
done 
```
Spiegazione dello script

```bash
while true; do
```

Inizia un ciclo infinito che continua finché non viene trovato un file valido
```bash
read -p "..." file
```

Chiede all’utente di inserire il nome del file e lo salva nella variabile "file”
```bash
if [ -f "$file" ] && [ -s "$file" ]; then
```
Controlla due condizioni:
 -f "$file" → verifica che il file esista ed è un file regolare.
 -s "$file" → verifica che il file non sia vuoto
 se entrambe sono vere vengono eseguite le istruzioni dentro il blocco "then".
 ```bash
risultato=$(sort "$file" | uniq -dc | sort -k1 -k2 -nr | head -n 3)
```
Esegue una pipeline di comandi:
- sort "$file" → ordina le righe del file
- uniq -dc → mostra solo le righe duplicate con il numero di occorrenze
- sort -k1 -k2 -nr → riordina in modo numerico decrescente in base alla prima colonna e in caso di parità di valore utilizza la seconda
- head -n 3 → prende solo le prime 3 righe
Il risultato viene salvato nella variabile "risultato"
```bash
exit 0
```
E’ un istruzione di uscita con codice di ritorno 0, quindi lo script è terminato senza errori
```bash
else
```
​
Viene eseguito se il file non esiste o è vuoto
```bash
fi
```

Chiude il blocco if
```bash
done
```
​Chiude il ciclo while (che ricomincia se il file non è valido)

## SCRIPT #2 
```bash
#!/bin/bash

# Richiede all'utente il nome del file
read -p "Immettere il file con la lista di server e utilizzo di CPU: " file
echo ””

# Verifica che il file esista (-f) e che non sia vuoto (-s)
if [[ ! -f "$file" || ! -s "$file" ]]; then
echo -e "Il file non esiste o è vuoto \v"
exit 1
fi

# serve per leggere il file riga per riga e dividere ogni riga in tre colonne
while read -r col1 col2 col3; do

# La riga non è considerata valida se:
# - la prima colonna è vuota
# - nella seconda colonna non è presente un numero intero
# - sono presenti più di due colonne
if [[ -z "$col1" || ! "$col2" =~ ^[0-9]+$ || -n "$col3" ]]; then
echo -e "Il file non è valido \v"
exit 1
fi
done < "$file"

# Array associativi:
# som_cpu -> somma degli utilizzi CPU per ogni server
# occ -> numero di occorrenze di ogni server
declare -A som_cpu
declare -A occ

# Legge nuovamente il file per riga per riga
while read -r server cpu; do

# Aggiorna la somma delle CPU per il server corrente
som_cpu["$server"]=$(( som_cpu["$server"] += cpu ))

# Incrementa il numero di occorrenze del server
occ["$server"]=$(( occ["$server"] += 1 ))
done < "$file"

# Intestazione del report finale
echo -e "=== REPORT UTILIZZO MEDIO CPU === \v"

# Per ogni server presente nell'array
for server in "${!som_cpu[@]}"; do

# Calcola la media intera dell'utilizzo CPU
media=$(( som_cpu["$server"] / occ["$server"] ))

# Stampa il nome del server e la media calcolata
echo -e "$server: $media \v"
done
```

### SPIEGAZIONE SCRIPT #2 
Lo script richiede all'utente il nome di un file contenente i dati relativi ai server e al loro utilizzo della CPU. Inizialmente verifica che il file esista e non sia vuoto, in caso contrario termina l'esecuzione con un messaggio di errore. Successivamente controlla che ogni riga del file sia nel formato corretto, cioè composta da un nome di server e da un valore numerico di utilizzo CPU, senza colonne aggiuntive. Una volta validati i dati, utilizza due array associativi: uno per accumulare la somma dei valori di CPU di ogni server e uno per contare quante volte ogni server compare nel file. Infine calcola l'utilizzo medio della CPU dividendo la somma totale per il numero di occorrenze e stampa un report finale con la percentuale media di utilizzo per ogni server.
