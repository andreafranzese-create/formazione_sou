# Esercizi Ansible 

## Struttura del progetto

```
.
├── Vagrantfile
├── playbook-esercizi-1-2.yaml      # pacchetti + utenti + vault
├── playbook-esercizio-3.yaml       # limiti + whitelist + apache2 + template
├── vars.yaml                       # variabili del template "VirtualHost"
├── vault.yaml                      # variabili cifrate 
└── template.j2                     # template VirtualHost Apache      
```

## Playbook "playbook-1-2.yaml" — pacchetti, utenti e vault

```yaml
hosts: all
become: true
gather_facts: false
```
- `hosts: all`-> utilizza tutti i gruppi host dell'inventario
- `become: true` → tutto gira come root
- `gather_facts: false` ->  disattiva la raccolta automatica dei fact all'inizio del play

### Task 1 — Installa pacchetti (`dict2items`)

#### Variabili

```yaml
vars:
  pacchetti:
    nginx: present
    apache2: present
    curl: absent
```

`dict2items` converte il dizionario in una lista di coppie:

```yaml
[key: nginx - value: present] 
[key: apache2 - value: present]
[key: curl - value: absent]
```
#### Task

```yaml
 - name: Installa pacchetti
   ansible.builtin.package:
     name: "{{ item.key }}"
     state: "{{ item.value }}"
     update_cache: true
   loop: "{{ pacchetti | dict2items }}"
```

Il loop usa `item.key` come nome del pacchetto e `item.value` come stato

### Task 2 — Crea utenti

#### Variabili

```yaml
utenti:
  - nome: franco
    group: sudo
    shell: /bin/bash
  - nome: luca
    group: sudo
    shell: /bin/sh
  - nome: francesco
    group: sudo
    shell: /bin/zsh
```

#### Task

```yaml
- name: Crea utenti
  ansible.builtin.user:
    name: "{{ item.nome }}"
    groups: "{{ item.group }}"
    shell: "{{ item.shell }}"
    append: true
    state: present
  loop: "{{ utenti }}"
```

Il **loop** scorre direttamente sulla lista di dizionari: ogni item è un dizionario, e i suoi campi si leggono con item.nome e item.shell.

### Task 3 — Stampa i segreti dal vault

#### Variabili

```yaml
vars_files:
  - vault.yaml
```

Include il file `vault.yaml`, che contiene le variabili cifrate con **Ansible Vault** attraverso il comando:

```bash
ansible-vault encrypt vault.yaml    
```

#### Task

```yaml
- name: Stampa la password degli utenti
  ansible.builtin.debug:
    msg: "La password di {{ item.utente }} è {{ item.password }}"
  loop: "{{ passwords }}"
```

Stampa in chiaro le password degli utenti, dopo che Ansible ha chiesto la vault password all'avvio con:

```bash
ansible-playbook playbook-esercizi-1-2.yaml --ask-vault-pass
```

Oppure, se il provisioning è gestito da Vagrant, si abilita la richiesta della password nel `Vagrantfile`:

```ruby
ansible.ask_vault_pass = true
```


## Playbook "playbook-3.yaml" — limiti, whitelist, Apache e template


### Task 1 — Limita numero di file aperti

`/etc/security/limits.conf` è il file che definisce i limiti sulle risorse che ogni utente o gruppo può consumare

#### Variabili

```yaml
users:
  - name: vagrant
    tipo_accesso: ALL
    tipo_limite: 
      - hard 
      - soft
  - name: root
    tipo_accesso: 192.168.1.0/24
    tipo_limite:
      - hard 
      - soft
```

#### Task

```yaml
- name: Limita numero di file aperti
      ansible.builtin.lineinfile:
        path: /etc/security/limits.conf
        regexp: '^{{ item.0.name }}\\s+{{ item.1 }}\\s+nofile'
        line: "{{ item.0.name }} {{ item.1 }} nofile {{ 10000 if ambiente == 'produzione' else 1000 }}"
        create: true
      loop: "{{ users | subelements('tipo_limite') }}"
```

- `regexp` intercetta la riga già presente e la sostituisce invece di duplicarla. In caso di riesecuzioni in cui trova la riga identica -> `ok`, non `changed`.
- `users | subelements('tipo_limite')` -> scorre ogni utente insieme a ogni suo **tipo_limite**, uno alla volta: se vagrant ha [soft, hard], il loop gira due volte, con item.0.name = vagrant e item.1 = soft poi hard

- `{{ 10000 if ambiente == 'produzione' else 1000 }}` -> è un operatore ternario Jinja2: sceglie tra due valori in base a una condizione, tutto su una riga.

### Task 2 — Whitelist accesso utenti

`/etc/security/access.conf` è il file che definisce chi può fare login e da dove.

#### Variabili

```yaml
users:
  - name: vagrant
    tipo_accesso: ALL
    tipo_limite: 
      - hard
      - soft
  - name: root
    tipo_accesso: 192.168.1.0/24
    tipo_limite:
      - hard
      - soft
```

#### Task

```yaml
- name: Whitelist accesso utenti
  ansible.builtin.lineinfile:
    path: /etc/security/access.conf
    regexp: '^\+:{{ item.0.name }}'
    insertbefore: '^-:ALL:ALL'
    line: "+:{{ item.0.name }}:{{ item.0.tipo_accesso }}"
  loop: "{{ users | subelements('tipo_limite') }}"

```

`insertbefore: '^-:ALL:ALL'` -> `access.conf` è valutato in ordine, la **prima corrispondenza vince**. L'ultima riga è tipicamente `-:ALL:ALL`, le regole `+` vanno messe prima: per questo si utilizza `insertbefore`.

### Task 3 — Installa apache2

#### Task

```yaml
- name: Scarica il pacchetto apache2
  ansible.builtin.apt:
    name: apache2
    state: present
```

Indica che il pacchetto apache2 deve essere presente nella macchina

### Task 4 — Template + handler

#### Task
```yaml
- name: Configurazione apache2 con template
  ansible.builtin.template:
    src: "test.j2"
    dest: "/etc/apache2/sites-enabled/000-default.conf"
  notify:
    - restarta apache2

handlers:
  - name: restarta apache2
    service:
      name: apache2
      state: restarted
```

Il modulo **template** copia un file dal control node al target, ma prima lo passa attraverso Jinja2: le variabili {{ }}, i cicli e gli if vengono risolti con i valori dell'host.

`notify`: il task segnala **l'handler** solo se ha davvero cambiato il file. Se il template renderizzato è identico a quello già sul disco, il task è `ok`, l'handler non scatta e apache non viene riavviato inutilmente.


## Il template VirtualHost

```jinja
<VirtualHost {{ ip_server }}:{{ porta }}>
{% if porta == 443 %}
    SSLEngine on
    ...
{% endif %}
```

Un solo template per HTTP e HTTPS: il blocco `{% if %}` scrive le direttive SSL solo sulla 443. Le variabili (`ip_server`, `porta`, `server_name`, `server_alias`, `document_root`, `certificate_file`, `certificate_key`) vanno definite in `vars.yaml`.