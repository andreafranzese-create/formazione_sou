# Esercitazione: Contadino, Capra, Cavolo e Lupo

Implementazione del classico rompicapo dell'attraversamento del fiume, dove le due
sponde sono **due macchine virtuali** e ogni attore (contadino, capra, cavolo, lupo)
è un **container Docker**. Lo spostamento di un attore da una sponda all'altra viene
simulato **eliminando** il container su una VM e **ricreandolo** sull'altra, con
operazioni coordinate via **SSH**.

---

## Il problema

Un contadino deve attraversare un fiume portando con sé una capra, un cavolo e un lupo.
La barca può contenere **solo il contadino** e **al massimo un altro passeggero**.

Alcuni attori non possono restare soli sulla stessa sponda senza il contadino:

- il **lupo mangia la capra**
- la **capra mangia il cavolo**

Obiettivo: portare tutti e tre sull'altra riva, evitando che una coppia incompatibile
resti sola su una sponda senza il contadino.

### Soluzione corretta (7 mosse)

1. Il contadino porta la **capra** a destra
2. Torna **da solo** a sinistra
3. Porta il **lupo** a destra *(oppure il cavolo — vedere variante)*
4. Riporta la **capra** a sinistra
5. Porta il **cavolo** a destra
6. Torna **da solo** a sinistra
7. Porta la **capra** a destra -> tutti sull'altra sponda

#### Variante (dal passaggio 3)

Al passo 3 si può portare il cavolo invece del lupo:

3. Porta il **cavolo** a destra
4. Riporta la **capra** a sinistra
5. Porta il **lupo** a destra
6. Torna **da solo** a sinistra
7. Porta la **capra** a destra -> tutti sull'altra sponda

---

## Logica del sistema

Il rompicapo è mappato su un'infrastruttura reale a due nodi:

| Elemento del problema           | Componente di sistema           |
|---------------------------------|---------------------------------|
| Sponda sinistra / destra        | Le due VM (`ub1`, `ub2`)        |
| Il fiume                        | La **rete** tra le due VM       |
| Contadino, lupo, capra, cavolo  | Quattro **container Docker**    |
| La barca                        | Il canale **SSH** tra le VM     |

---

## Architettura 

| Nodo  | Hostname | IP              | Ruolo                                          |
|-------|----------|-----------------|------------------------------------------------|
| `ub1` | ub1      | 192.168.56.11   | **Sponda 1** — esegue lo script Bash del gioco |
| `ub2` | ub2      | 192.168.56.12   | **Sponda 2** — pilotata da `ub1` via SSH       |

### Mappatura porte

| Attore     | Porta host |
|------------|------------|
| capra      | 8080       |
| lupo       | 8081       |
| cavolo     | 8082       |
| contadino  | 8083       |

---

## Provisioning con Vagrant + Ansible

### Vagrantfile

Crea due VM identiche:

- **Box**: ubuntu/jammy64
- **Risorse**: 1 vCPU, 1024 MB RAM
- **Rete**: IP statico privato (ub1 = 192.168.56.11, ub2 = 192.168.56.12)
- **Cartella condivisa**: ./condivisa → /condivisa
- **Provisioning Ansible** → dichiarato solo su ub2, ma con ansible.limit = "all" viene applicato a entrambe le VM in una sola passata.

### playbook.yaml
Automatizza l'intera preparazione dell'ambiente: 

```yaml
---
- hosts: all
  become: true

  tasks:
    - name: Scaricare lo script di docker
      get_url:
        url: https://get.docker.com
        dest: /root/get-docker.sh

    - name: Dare permessi allo script
      file:
        path: /root/get-docker.sh
        mode: '0755'

    - name: Avvia lo script per scaricare docker
      command: /root/get-docker.sh
       args:
         creates: /usr/bin/docker

    - name: Aggiungi l'utente vagrant al gruppo docker
      user:
        name: vagrant
        groups: docker
        append: true

    - name: Copia lo script del rompicapo nelle vm
      copy:
        src: /Users/andreafranzese/Desktop/projects/formazione_sou/vagrant-test/rompicapo
        dest: /root/rompicapo
        owner: root
        group: root
        mode: '0755'
      when: ansible_hostname == "ub1"

    - name: Genera chiavi ssh
      command: ssh-keygen -t ed25519  -f /root/.ssh/id_ed25519 -N ""
      args:
        creates: /root/.ssh/id_ed25519
      when: ansible_hostname == "ub1"

    - name: Leggi il file con cat
      command: cat /root/.ssh/id_ed25519.pub
      register: pubkey
      when: ansible_hostname == "ub1"

    - name: Copia la chiave pubblica nella seconda macchina
      authorized_key:
       user: vagrant
       state: present
       key: "{{ hostvars['ub1'].pubkey.stdout }}"
      when: ansible_hostname ==   "ub2"

    - name: Config SSH globale
      lineinfile:
        path: /etc/ssh/ssh_config
        line: "StrictHostKeyChecking no"

    - name: Pull dell'immagine docker
      command: docker pull ealen/echo-server:latest
```

Cosa fa, task per task:

| Task                     | Host        | Effetto                                                             |
|--------------------------|-------------|---------------------------------------------------------------------|
| Installazione script Docker     | tutti       | Scarica lo script ufficiale `get.docker.com`.             |
| Dare permessi allo script | tutti | Da permessi di esecuzione allo script |
|Avvia lo script docker | tutti | Esegue lo script docker per installarlo
| Utente nel gruppo docker | tutti       | `vagrant` può usare Docker senza `sudo`.                            |
| Copia script rompicapo   | solo `ub1`  | Copia la cartella `rompicapo` (dall'host) in `/root/rompicapo`.     |
| Genera chiavi SSH        | solo `ub1`  | Crea `id_ed25519` per `root` (idempotente grazie a `creates`).      |
| Leggi + copia chiave     | ub1 → ub2   | Registra la pubkey di `ub1` e la autorizza per `vagrant` su `ub2`.  |
| Config SSH globale       | tutti       | Disabilita `StrictHostKeyChecking` per connessioni non interattive. |
| Pull immagine            | tutti       | Pre-scarica `ealen/echo-server:latest` su entrambe le VM.           |

---

## Script

Ad ogni turno lo script mostra lo **stato attuale** delle due sponde e chiede all'utente
quale attore spostare. Il gioco alterna due fasi in loop:

1. **Sponda 1 -> Sponda 2**: chiede chi portare sull'altra sponda.
2. **Sponda 2 -> Sponda 1**: chiede chi riportare indietro.

Digita uno tra: `contadino`, `lupo`, `capra`, `cavolo`.

- Puoi spostare solo un attore presente sulla sponda di partenza di quel turno.
- Ogni mossa **muove implicitamente anche il contadino**
- Dopo ogni mossa lo script esegue i controlli di sconfitta/vittoria e incrementa `mosse`.

---

### Come funziona il codice

- **`menu` / `menu_sponde`** — stampano intestazione e stato delle sponde elencando i container attivi
- **`verifica`** — ispeziona i container con `docker container inspect` (in locale e via
  SSH) per assegnare a ogni attore la sponda `1` o `2` poi controlla se tutti gli attori sono sulla Sponda 2 e, in tal caso,
  chiude la partita mostrando il numero di mosse.
- **`contadino_loc` / `contadino_rem`** — spostano il contadino sulla Sponda 1 o 2
- **`cleanup`** — rimuove **tutti** i container su entrambe le VM con
  `docker rm -f`
- **`trap cleanup EXIT`** — garantisce la pulizia dell'ambiente all'uscita (vittoria, sconfitta o interruzione)
- Ogni spostamento consiste nel rimuovere il container sulla sponda di partenza
(`docker stop`/`docker rm`) e ricrearlo con
`docker run` sull'altra.

#### Stato delle sponde
- Lo script contiene una variabile per attore (`lupo`, `capra`, `cavolo`,
`contadino`) con valore:
  - `1` -> attore sulla **Sponda 1** (ub1)
  - `2` -> attore sulla **Sponda 2** (ub2)

La posizione reale è verificata ispezionando i container con `docker container inspect`