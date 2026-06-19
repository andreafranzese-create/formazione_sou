
  # REVERSE PROXY

```ruby
Vagrant.configure("2") do |config|
    
    #MACCHINA 1

    config.vm.define "PRX-01" do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "PRX-01"
    config.vm.network "private_network", ip: "192.168.56.11"
    config.vm.network "forwarded_port", guest: 443, host: 8080
    
    config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install -y haproxy
    mkdir -p /etc/ssl/mycerts
    openssl req -new -x509 -days 365 -nodes -out /etc/ssl/mycerts/esempio.pem -keyout /etc/ssl/mycerts/esempio.key --subj "/C=IT/ST=Italy/L=Roma/O=Test/OU=IT/CN=esempio.com"
    cat /etc/ssl/mycerts/esempio.pem /etc/ssl/mycerts/esempio.key > /etc/ssl/mycerts/esempioproxy.pem
    cat <<EOT > /etc/haproxy/haproxy.cfg
global
    daemon
    log /dev/log local0

defaults
    mode http
    log global
    option forwardfor
    timeout connect 5s
    timeout client 30s
    timeout server 30s


frontend esempio_ssl
    bind *:443 ssl crt /etc/ssl/mycerts/esempioproxy.pem

    acl scuola path_beg /scuola
    acl lavoro path_beg /lavoro

    use_backend WEB-01 if scuola
    use_backend WEB-02 if lavoro

    http-request deny unless scuola or lavoro

backend WEB-01
    server WEB-01 192.168.56.12:80 check

backend WEB-02
    server WEB-02 192.168.56.13:80 check
EOT
systemctl restart haproxy
    SHELL


    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end

    #MACCHINA 2

   config.vm.define "WEB-01" do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "WEB-01"
    config.vm.network "private_network", ip: "192.168.56.12"
    config.vm.synced_folder "./condivisa", "/condivisa"
    config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install -y apache2
    mkdir -p /var/www/html/WEB-01
    echo "HELLO FROM WEB-01" > /var/www/html/WEB-01/index.html
    systemctl restart apache2
    SHELL

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end

    #MACCHINA 3

   config.vm.define "WEB-02" do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "WEB-02"
    config.vm.network "private_network", ip: "192.168.56.13"
    config.vm.synced_folder "./condivisa", "/condivisa"
    
    config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install -y apache2
    mkdir -p /var/www/html/WEB-02
    echo "HELLO FROM WEB-02" > /var/www/html/WEB-02/index.html
    systemctl restart apache2
    SHELL

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end
end
```

## MACCHINA PRX-01
Questa macchina funziona come reverse proxy: il traffico passa prima da lei, che fa da intermediario tra il client e i server a cui inoltra le richieste. Inizialmente è stata configurata in HTTP e successivamente in HTTPS per crittografare la comunicazione tra client e server.
### Configurazione 
- Sistema operativo: Ubuntu Jammy 64 bit
- Hostname: PRX-01
- Memoria RAM: 1024 MB
- CPU: 1 core
- Network: interfaccia di rete privata
  -  IP statico: 192.168.56.11
- Pacchetti installati: HAProxy
- Port forwarding (utilizzato per controllare il corretto funzionamento dell'esercizio):
  - Host: porta 8080
  - Guest: porta 443
### Funzionamento
Dopo l'installazione del pacchetto HAProxy, è stato configurato il file haproxy.cfg che si trova nella directory /etc/haproxy:

```bash
global
    daemon
    log /dev/log local0

defaults
    mode http
    log global
    option forwardfor
    timeout connect 5s
    timeout client 30s
    timeout server 30s


frontend esempio
    bind *:80 

    acl scuola path_beg /scuola
    acl lavoro path_beg /lavoro

    use_backend WEB-01 if scuola
    use_backend WEB-02 if lavoro

    http-request deny unless scuola or lavoro

backend WEB-01
    server WEB-01 192.168.56.12:80 check

backend WEB-01
    server WEB-01 192.168.56.13:80 check
```
---
#### GLOBAL
La sezione global contiene le impostazioni generali di HAProxy. In questo caso:

```bash
global
    daemon
    log /dev/log local0
```
- daemon: avvia HAProxy in modalità background
- log /dev/log local0: serve a dire ad HAProxy dove e come inviare i log di sistema
#### DEFAULT
La sezione defaults definisce i parametri predefiniti che vengono applicati a tutte le sezioni successive:

```bash
defaults
    mode http
    log global
    option forwardfor
    timeout connect 5s
    timeout client 30s
    timeout server 30s
```

- mode http: mette HAProxy in modalità HTTP
- log global: utilizza le impostzioni di log definite nella sezione global
- option forwardfor: serve a far passare ai server backend l’IP reale del client
- timeout connect 5s: indica il tempo massimo per stabilire una connessione con il server backend.
- timeout client 30s: indica il tempo massimo di inattività consentito per il client
- timeout server 30s: indica il tempo massimo di inattività consentito per il server backend
#### FRONTEND HTTP
La sezione frontend definisce il punto da cui entra il traffico e dove HAProxy decide come gestire le richieste in arrivo.

```bash
frontend esempio
    bind *:80

    acl scuola path_beg /scuola
    acl lavoro path_beg /lavoro

    use_backend WEB-01 if scuola
    use_backend WEB-02 if lavoro

    http-request deny unless scuola or lavoro
```

- bind *:80: indica che il frontend è in ascolto su tutte le interfacce di rete sulla porta 80.
- acl scuola path_beg /scuola: Crea una regola chiamata “scuola” che si attiva quando il percorso dell’URL inizia con /scuola
- acl lavoro path_beg /lavoro: Crea una seconda regola chiamata “lavoro” che si attiva quando il percorso dell’URL inizia con /lavoro
- use_backend WEB-01 if scuola: inoltra le richieste al backend WEB-01 se è soddisfatta la condizione della ACL scuola.
- use_backend WEB-02 if lavoro: inoltra le richieste al backend WEB-02 se è soddisfatta la ACL lavoro.
- http-request deny unless scuola or lavoro: blocca tutte le richieste che non rispettano nessuna delle due condizioni.
#### FRONTEND HTTPS
Per rendere il frontend HTTPS c'è bisogno della coppia certificato/chiavi privata (TLS). In questo caso è stata una coppia chiave privata e certificato autofirmato:

```bash
openssl req -new -x509 -days 365 -nodes -out /etc/ssl/mycerts/esempio.pem -keyout /etc/ssl/mycerts/esempio.key --subj "/C=IT/ST=Italy/L=Roma/O=Test/OU=IT/CN=esempio.com"
```
Per HAProxy serve un unico file che contiene insieme certificato e chiave privata. Si possono unire con il comando:

```bash
cat /etc/ssl/mycerts/esempio.pem /etc/ssl/mycerts/esempio.key > /etc/ssl/mycerts/esempioproxy.pem
```

Infine bisogna dire ad HAProxy dove trovare il file del certificato e quindi si rientra nel file haproxy.cfg e si scrive:

```bash
frontend esempio_ssl
    bind *:443 ssl crt /etc/ssl/mycerts/esempioproxy.pem
```

#### BACKEND
La sezione backend definisce a quali server HAProxy deve mandare le richieste che arrivano dal frontend.

```bash
backend scuola
    server scuola 192.168.56.12:80 check

backend lavoro
    server lavoro 192.168.56.13:80 check
```
---
Completata la configurazione, il servizio HAProxy viene riavviato per applicare le modifiche con il comando:

```bash
systemctl restart haproxy
```
## MACCHINA WEB-01 E WEB-02
Queste macchine funzionano come server WEB
### Configurazione 
- Sistema operativo: Ubuntu Jammy 64 bit
- Hostname: WEB-01 / WEB-02
- Memoria RAM: 1024 MB
- CPU: 1 core
- Network: interfaccia di rete privata
  -  IP statico WEB-01: 192.168.56.12
  -  IP statico WEB-02: 192.168.56.13
- Pacchetti installati: apache2
### Funzionamento
Dopo aver installato Apache2 e configurato il server web in /var/www/html, bisogna creare una sottocartella con il path definito nelle ACL:

```bash
acl scuola path_beg /scuola
acl lavoro path_beg /lavoro
```

 /scuola nel caso di WEB-01 e /lavoro nel caso di WEB-02.
 
  In entrambe va inserito il file index.html in quanto quando si visita l'indirizzo https://192.168.56.11/scuola, Apache parte dalla DocumentRoot e aggiunge il path, andando quindi a cercare l'index.html nella cartella /var/www/html/scuola.