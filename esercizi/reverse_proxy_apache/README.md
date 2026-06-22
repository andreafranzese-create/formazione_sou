
# REVERSE PROXY (apache2)

```ruby
Vagrant.configure("2") do |config|

      #MACCHINA 1

    config.vm.define "PRX-01" do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "PRX-01"
    config.vm.network "private_network", ip: "192.168.56.11"
    config.vm.synced_folder "./condivisa", "/condivisa"
    config.vm.provision "shell", inline: <<-SHELL
        apt update
        apt install -y apache2
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
    config.vm.provision "shell", inline: <<-SHELL
        apt update
        apt install -y apache2
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
    config.vm.provision "shell", inline: <<-SHELL
        apt update
        apt install -y apache2
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
  - IP statico: 192.168.56.11
- Pacchetti installati: apache2
## Funzionamento
Dopo l'installazione del pacchetto apache2, è stato generato un certificato autofirmato nella directory /etc/ssl/mycerts. Come primo passo si generano la coppia di chiavi rsa:

```bash
openssl genrsa -out esempio.key 2048
```

Questo genera la chiave privata RSA a 2048 bit. Successivamente si genera la CSR(Certificate Signing Request):

```bash
openssl req -new -key esempio.key -out esempio.csr
```

La CSR contiene:
- La chiave pubblica
- I metadati inseriti
- Una firma digitale fatta con la chiave privata

Successivamente dato che non abbiamo una CA, si genera un certificato self-signed firmato con la nostra chiave privata:

```bash
openssl x509 -req -days 365 -in esempio.csr -signkey esempio.key -out esempio.pem
```
Successivamente sono stati abilitati i moduli di apache:

```bash
a2enmod proxy proxy_http ssl
```
- proxy: è il modulo base del reverse proxy
- proxy_http: è il modulo per comunicare con i backend in HTTP
- ssl: è il modulo che gestisce le connessioni HTTPS

Successivamente è stato creato il file reverse_proxy.conf nella directory /etc/apache2/sites-available:

```bash
<VirtualHost *:443>

    SSLEngine On
    SSLCertificateFile    /etc/ssl/mycerts/esempio.pem
    SSLCertificateKeyFile /etc/ssl/mycerts/esempio.key

    ProxyRequests Off

    ProxyPass        /scuola  http://192.168.56.12/
    ProxyPassReverse /scuola  http://192.168.56.12/

    ProxyPass        /lavoro  http://192.168.56.13/
    ProxyPassReverse /lavoro  http://192.168.56.13/

    ErrorLog  ${APACHE_LOG_DIR}/proxy_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/proxy_ssl_access.log combined
</VirtualHost>
```
---

### Spiegazione file

```bash
<VirtualHost *:443>
```

Definisce un Virtual Host che ascolta su tutte le interfacce di rete sulla porta 443

```bash
SSLEngine On
SSLCertificateFile    /etc/ssl/mycerts/esempio.pem
SSLCertificateKeyFile /etc/ssl/mycerts/esempio.key
```

- SSLEngine On: attiva la cifratura HTTPS su questo virtual host
- SSLCertificateFile: percorso del certificato autofirmato (.pem)
- SSLCertificateKeyFile: percorso della chiave privata (.key), usata per cifrare la comunicazione

```bash
ProxyRequests Off
```

- ProxyRequests Off: disabilita il forward proxy cioè Apache non può essere utilizzato dai client per navigare su internet

```bash
ProxyPass        /scuola  http://192.168.56.12/
ProxyPassReverse /scuola  http://192.168.56.12/
```

- ProxyPass: tutte le richieste che arrivano su /scuola vengono inoltrate al server 192.168.56.12
- ProxyPassReverse: riscrive l'indirizzo nei redirect del backend, sostituendo l'IP interno con quello del proxy, in modo che il client non tenti di contattare direttamente un server che non può raggiungere.

```bash
ErrorLog  ${APACHE_LOG_DIR}/proxy_ssl_error.log
CustomLog ${APACHE_LOG_DIR}/proxy_ssl_access.log combined
```

- ErrorLog → è il file dove Apache scrive gli errori
- CustomLog → è il file dove vengono registrati tutti gli accessi
- combined → formato di log standard 
- ${APACHE_LOG_DIR}: variabile Apache che punta a /var/log/apache2/
---
Successivamente la configurazione del reverse proxy è stata abilitata tramite il comando:

```bash
a2ensite reverse_proxy.conf
```

Infine per applicare le modifiche è stato utilizzato il comando:

```bash
systemctl restart apache2
```

## MACCHINA WEB-01 E WEB-02
Queste macchine funzionano come server WEB
### CONFIGURAZIONE

- Sistema operativo: Ubuntu Jammy 64 bit
- Hostname: WEB-01 / WEB-02
- Memoria RAM: 1024 MB
- CPU: 1 core
- Network: interfaccia di rete privata
  - IP statico WEB-01: 192.168.56.12
  - IP statico WEB-02: 192.168.56.13
- Pacchetti installati: apache2

### FUNZIONAMENTO
A differenza di HAProxy, in questo caso è sufficiente configurare dei server web con degli index.html personalizzati nella directory /var/www/html
