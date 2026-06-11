## ESEMPIO 2-1

```bash
cd /var/log
cat /dev/null > messages
cat /dev/null > wtmp
echo "Log files cleaned up."
```

Questo script serve a svuotare alcuni file di log di sistema presenti nella directory /var/log, senza eliminarli.

## ESEMPIO 9-5

```bash
#!/bin/bash
# am-i-root.sh:   Am I root or not?

ROOT_UID=0   # Root has $UID 0.

if [ "$UID" -eq "$ROOT_UID" ]  # Will the real "root" please stand up?
then
  echo "You are root."
else
  echo "You are just an ordinary user (but mom loves you just the same)."
fi

exit 0

# ============================================================= #
# Code below will not execute, because the script already exited.

# An alternate method of getting to the root of matters:

ROOTUSER_NAME=root

username=`id -nu`              # Or...   username=`whoami`
if [ "$username" = "$ROOTUSER_NAME" ]
then
  echo "Rooty, toot, toot. You are root."
else
  echo "You are just a regular fella."
fi
```

Questo script verifica se l’utente che lo esegue è l’utente root oppure no. Per farlo confronta il valore dell’UID corrente ($UID) con 0, che è l’identificatore del superuser. Se i due valori coincidono, stampa un messaggio che conferma i privilegi di root, altrimenti indica che l’utente è normale. Nella seconda parte viene mostrato un metodo alternativo: si ricava il nome dell’utente tramite il comando id -nu e lo si confronta con la stringa “root”.

## ESEMPIO 4-5

```bash
#!/bin/bash

# Call this script with at least 10 parameters, for example
# ./scriptname 1 2 3 4 5 6 7 8 9 10
MINPARAMS=10

echo

echo "The name of this script is \"$0\"."
# Adds ./ for current directory
echo "The name of this script is \"`basename $0`\"."
# Strips out path name info (see 'basename')

echo

if [ -n "$1" ]              # Tested variable is quoted.
then
 echo "Parameter #1 is $1"  # Need quotes to escape #
fi 

if [ -n "$2" ]
then
 echo "Parameter #2 is $2"
fi 

if [ -n "$3" ]
then
 echo "Parameter #3 is $3"
fi 

# ...


if [ -n "${10}" ]  # Parameters > $9 must be enclosed in {brackets}.
then
 echo "Parameter #10 is ${10}"
fi 

echo "-----------------------------------"
echo "All the command-line parameters are: "$*""

if [ $# -lt "$MINPARAMS" ]
then
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
fi  

echo

exit 0
```

Questo script mostra come lavorare con i parametri passati da riga di comando. All’inizio stampa il nome dello script, sia con il percorso completo ($0) sia usando basename per ottenere solo il nome del file. Successivamente controlla la presenza dei parametri uno per uno, verificando che non siano vuoti prima di stamparli. Viene evidenziato anche il fatto che i parametri con indice maggiore di 9 devono essere scritti tra parentesi graffe. Infine lo script stampa tutti i parametri insieme tramite $* e controlla che il numero totale di argomenti ($#) sia almeno 10; se non lo è, mostra un messaggio di avviso.

## ESEMPIO 4-2

```bash
#!/bin/bash
# Naked variables

echo

# When is a variable "naked", i.e., lacking the '$' in front?
# When it is being assigned, rather than referenced.

# Assignment
a=879
echo "The value of \"a\" is $a."

# Assignment using 'let'
let a=16+5
echo "The value of \"a\" is now $a."

echo

# In a 'for' loop (really, a type of disguised assignment):
echo -n "Values of \"a\" in the loop are: "
for a in 7 8 9 11
do
  echo -n "$a "
done

echo
echo

# In a 'read' statement (also a type of assignment):
echo -n "Enter \"a\" "
read a
echo "The value of \"a\" is now $a."

echo

exit 0 
```

Questo script mostra che una variabile viene scritta senza $ quando le si assegna un valore, mentre il $ serve invece per leggerne il contenuto. Poi si vede un altro modo di assegnare valori usando let, che serve per fare calcoli direttamente in Bash. Lo script mostra anche che nei cicli for la variabile cambia valore a ogni giro del ciclo, e anche che con read si effettua un’assegnazione leggendo l’input dell’utente.ù

## ESEMPIO 6-1

```bash
#!/bin/bash

echo hello
echo $?    # Exit status 0 returned because command executed successfully.

lskdf      # Unrecognized command.
echo $?    # Non-zero exit status returned -- command failed to execute.

echo

exit 113   # Will return 113 to shell.
           # To verify this, type "echo $?" after script terminates.

#  By convention, an 'exit 0' indicates success,
#+ while a non-zero exit value means an error or anomalous condition.
#  See the "Exit Codes With Special Meanings" appendix.#!/bin/bash
```

Questo script serve a mostrare come funziona lo status di uscita (exit status) dei comandi. Prima esegue echo hello, che va a buon fine, quindi echo $? restituisce 0, cioè successo. Poi prova a eseguire un comando inesistente (lskdf), che genera un errore: in questo caso echo $? restituisce un valore diverso da zero, indicando fallimento. Infine lo script finisce con exit 113, cioè restituisce al sistema il codice 113 come stato finale, quindi segnala una chiusura con errore.

## ESEMPIO 37-5

```bash
#!/bin/bash4
# fetch_address.sh

declare -A address
#       -A option declares associative array.

address[Charles]="414 W. 10th Ave., Baltimore, MD 21236"
address[John]="202 E. 3rd St., New York, NY 10009"
address[Wilma]="1854 Vermont Ave, Los Angeles, CA 90023"


echo "Charles's address is ${address[Charles]}."
# Charles's address is 414 W. 10th Ave., Baltimore, MD 21236.
echo "Wilma's address is ${address[Wilma]}."
# Wilma's address is 1854 Vermont Ave, Los Angeles, CA 90023.
echo "John's address is ${address[John]}."
# John's address is 202 E. 3rd St., New York, NY 10009.

echo

echo "${!address[*]}"   # The array indices ...
# Charles John Wilma
```

Questo script mostra l’uso degli array associativi. Viene prima dichiarato un array associativo con declare -A address, poi vengono inseriti alcuni indirizzi associati ai nomi Charles, John e Wilma. Successivamente lo script stampa i valori corrispondenti a ciascuna chiave usando la sintassi ${address[Nome]}. Infine, con ${!address[*]} viene mostrato l’elenco di tutte le chiavi dell’array, cioè gli “indici” utilizzati.

## ESEMPIO 32-7

```bash
#! /bin/bash
# progress-bar2.sh
# Author: Graham Ewart (with reformatting by ABS Guide author).
# Used in ABS Guide with permission (thanks!).

# Invoke this script with bash. It doesn't work with sh.

interval=1
long_interval=10

{
     trap "exit" SIGUSR1
     sleep $interval; sleep $interval
     while true
     do
       echo -n '.'     # Use dots.
       sleep $interval
     done; } &         # Start a progress bar as a background process.

pid=$!
trap "echo !; kill -USR1 $pid; wait $pid"  EXIT        # To handle ^C.

echo -n 'Long-running process '
sleep $long_interval
echo ' Finished!'

kill -USR1 $pid
wait $pid              # Stop the progress bar.
trap EXIT

exit $?
```

Questo script crea una barra di progresso usando punti stampati a intervalli regolari mentre viene eseguita un’operazione più lunga. In pratica avvia in background un ciclo che stampa dei puntini ogni secondo per simulare l’avanzamento. Il processo viene gestito con un trap e un pid per poterlo terminare in modo controllato. Nel frattempo lo script principale esegue un’attività "lunga" simulata con sleep. Quando l’operazione "lunga" termina, lo script invia un segnale per fermare il processo della barra di progresso e attende la sua chiusura con wait. Viene anche gestito il caso di interruzione (ad esempio con Ctrl+C) per evitare processi lasciati in esecuzione.