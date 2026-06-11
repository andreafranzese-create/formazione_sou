## DevOps Contest

```ruby
#1° MACCHINA

Vagrant.configure("2") do |config|
    config.vm.define "rocky2" do |config|
    config.vm.box = "generic/rocky8"
    config.vm.hostname = "rocky2"
    config.vm.network "private_network", ip: "192.168.56.10"
    config.vm.network "forwarded_port", guest: 443, host: 8443

    config.vm.provision "shell", inline: <<-SHELL
        dnf install httpd -y
        systemctl enable httpd
        dnf install mod_ssl -y
        firewall-cmd --permanent --add-service=https
        firewall-cmd --reload
        sed -i 's|#DocumentRoot "/var/www/html"|DocumentRoot "/var/www/html"|' /etc/httpd/conf.d/ssl.conf
        openssl req -new -x509 -days 365 -nodes -out /etc/ssl/certs/esempio.com.pem -keyout /etc/ssl/certs/esempio.com.key --subj "/C=IT/ST=Italy/L=Roma/O=Test/OU=IT/CN=esempio.com"
        sed -i 's|SSLCertificateFile /etc/pki/tls/certs/localhost.crt|SSLCertificateFile /etc/ssl/certs/esempio.com.pem|' /etc/httpd/conf.d/ssl.conf
        sed -i 's|SSLCertificateKeyFile /etc/pki/tls/private/localhost.key|SSLCertificateKeyFile /etc/ssl/certs/esempio.com.key|' /etc/httpd/conf.d/ssl.conf
        echo "Hello DevOpsTribe!" > /var/www/html/index.html
        systemctl restart httpd
    SHELL
   
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end

#2° MACCHINA

   config.vm.define "deb2" do |config|
    config.vm.box = "generic/debian9"
    config.vm.hostname = "deb2"
    config.vm.network "private_network", ip: "192.168.56.11"

    config.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install curl -y
    SHELL

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end
end
```

Ho configurato un ambiente composto da due macchine virtuali portabili: una basata su Rocky Linux e una su Debian.
Sulla macchina Rocky Linux ho installato e configurato un server web Apache HTTPS con certificati autofirmati. Il servizio è in esecuzione e ascolta sulla porta 443.
La seconda macchina, Debian, è utilizzata come client di test: da questa macchina verifico il corretto funzionamento del server web utilizzando il comando curl.
Inoltre, il server web è raggiungibile anche dalla macchina host.
