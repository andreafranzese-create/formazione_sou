# formazione_sou

Raccolta degli esercizi svolti con focus su
**Linux**, **Bash scripting**, **Git**, **networking** e **automazione dell'infrastruttura**.

## Esercizi

| Esercizio | Descrizione |
|---|---|
| [ansible](esercizi/ansible) | Playbook Ansible per pacchetti, utenti, template Jinja2 e segreti con Vault |
| [capra-cavolo-lupo-contadino](esercizi/capra-cavolo-lupo-contadino) | Il classico rompicapo dell'attraversamento del fiume risolto con VM e container |
| [commenti-script](esercizi/commenti-script) | Analisi e commento di script Bash di esempio |
| [devops-contest](esercizi/devops-contest) | Provisioning con Vagrant di macchine con servizi web e HTTPS |
| [esercizi-bash-scripting](esercizi/esercizi-bash-scripting) | Script Bash su file di log, validazione dell'input e interazione con l'utente |
| [git_merge_conflict](esercizi/git_merge_conflict) | Generazione e risoluzione di conflitti di merge tra branch |
| [pingpong](esercizi/pingpong) | Orchestrazione di container Podman tra due nodi coordinati via SSH |
| [port_scanner](esercizi/port_scanner) | Port scanner in Bash con parsing e sanificazione degli argomenti |
| [regex-ipv4](esercizi/regex-ipv4) | Classificatore di indirizzi IPv4 per classe e tipo tramite regex |
| [reverse_proxy_apache](esercizi/reverse_proxy_apache) | Reverse proxy con Apache2, in HTTP e poi in HTTPS |
| [reverse_proxy_haproxy](esercizi/reverse_proxy_haproxy) | Reverse proxy con HAProxy, in HTTP e poi in HTTPS |

## Temi affrontati

- **Bash scripting**: validazione dell'input, cicli, espressioni regolari, `awk`, gestione
  degli argomenti da riga di comando.
- **Git**: utilizzo dei branch e gestione dei conflitti di merge.
- **Virtualizzazione e provisioning**: ambienti riproducibili con **Vagrant** e VM multiple
  in rete privata.
- **Container**: gestione di container con **Docker** e **Podman**, anche coordinata da remoto
  via SSH.
- **Networking e servizi**: reverse proxy con **Apache2** e **HAProxy**, certificati
  autofirmati e configurazione HTTPS.
- **Automazione**: **Ansible** per la gestione di pacchetti, utenti, template e segreti
  con Ansible Vault.