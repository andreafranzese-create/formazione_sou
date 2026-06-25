# Merge conflict

Per generare un **conflitto di merge** in Git è necessario avere almeno due branch. Nel caso in cui ne avessimo solo uno ne creiamo un altro con:

```bash
git branch conflict
```

Andiamo successivamente a modificare lo stesso file su entrambi i branch. Ad esempio modifichiamo il file `lista_ip.txt` nei branch **main** e **conflict**

File `lista_ip.txt` nel branch **main**:

```bash
Lista di ip server:
192.168.0.1
192.168.0.3
```

File `lista_ip.txt` nel branch **conflict**:

```bash
Lista di ip server:
10.0.0.1
10.0.0.2
```

Successivamente si esegue il merge tra i due branch e Git si accorge che alcune modifiche sono in conflitto. Git in questo caso ha comportamenti diversi in base allo stato del file:

## File untracked

Git rileva che il file esiste sul computer dell'utente ma non fa parte del repository. Per evitare di cancellarlo accidentalmente, interrompe il merge se rischia di sovrascriverlo e mostra il messaggio:

```text
error: The following untracked working tree files would be overwritten by merge:
lista_ip.txt
Please move or remove them before you merge.
```
## File tracked ma con modifiche non committate

Git rileva che esistono cambiamenti locali non ancora salvati nella cronologia e blocca il merge quando le modifiche rischiano di essere sovrascritte e mostra il messaggio:

```text
error: Your local changes to the following files would be overwritten by merge:
lista_ip.txt
Please commit your changes or stash them before you merge.
```
## File committato

Git confronta la storia dei due branch utilizzando l'ultimo commit condiviso tra i branch ed eseguire un **three-way merge**. Se le modifiche riguardano parti diverse del file, Git riesce normalmente a combinarle da solo. Se invece viene modificata la stessa parte del file in modi diversi, Git non sa quale scegliere e segnala un conflitto che deve essere risolto manualmente e mostra il messaggio: 

```text
CONFLICT (content): Merge conflict in lista_ip.txt
Automatic merge failed; fix conflicts and then commit the result.
```

Successivamente aprendo il file, è possibile vedere le parti in conflitto evidenziate da Git.

```bash
Lista di ip server:
<<<<<<< main
192.168.0.1
192.168.0.3
=======
10.0.0.1
10.0.0.2
>>>>>>> conflict
```

## Come risolvere un merge conflict

Per risolverlo è necessario aprire il file e modificare manualmente le parti in conflitto scegliendo quali modifiche mantenere o combinandole ad esempio:

```bash
Lista di ip server:
192.168.0.1
192.168.0.3
10.0.0.1
10.0.0.2
```

Dopo aver risolto il conflitto, si aggiunge il file all’area di staging con il comando:

```bash
git add lista_ip.txt 
```

e si conclude il merge con un commit.

```bash
git commit -m “Risolto merge conflict”
```