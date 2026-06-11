
## PINGPONG DEMO

```ruby
Vagrant.configure("2") do |config|

#1° MACCHINA

    config.vm.define "rocky2" do |config|
    config.vm.box = "generic/rocky8"
    config.vm.hostname = "rocky2"
    config.vm.network "private_network", ip: "192.168.56.10"

    config.vm.provision "shell", inline: <<-SHELL
     dnf install podman -y
     dnf install sshpass -y
     sudo -u vagrant podman create --name ping alpine sleep 60
     cat <<'FINE' > /home/vagrant/pingpong
     #!/usr/bin/env bash
     while true; do
          podman start ping
          echo ping
          sleep 60
          podman stop ping
          sshpass -p "vagrant" ssh vagrant@192.168.56.12 "podman start pong"
          echo pong
          sleep 60 
          sshpass -p "vagrant" ssh vagrant@192.168.56.12 "podman stop pong"
     done
     FINE
     chmod +x /home/vagrant/pingpong
     SHELL
   
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end

#2° MACCHINA

   config.vm.define "rocky3" do |config|
    config.vm.box = "generic/rocky8"
    config.vm.hostname = "rocky3"
    config.vm.network "private_network", ip: "192.168.56.12"

    config.vm.provision "shell", inline: <<-SHELL
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    dnf install podman -y   
    sudo -u vagrant podman create --name pong alpine sleep 60
    SHELL

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end
end
```

Ho configurato un ambiente composto da due macchine virtuali basate su Rocky Linux, collegate tra loro tramite una rete privata. Su entrambe le macchine ho installato Podman e creato un container dedicato: ping sulla prima macchina e pong sulla seconda. Per consentire l'esecuzione automatica di comandi remoti, ho configurato l'autenticazione SSH tramite password e installato il pacchetto sshpass sulla prima macchina, in modo da permettere l'accesso alla seconda VM senza richiedere l'inserimento manuale delle credenziali. Sulla prima macchina ho inoltre creato uno script che esegue un ciclo continuo. Lo script avvia il container ping, lo mantiene in esecuzione per un minuto e successivamente lo arresta; quindi si collega tramite SSH alla seconda macchina, avvia il container pong, lo lascia in esecuzione per un minuto e infine lo arresta. Il processo viene ripetuto indefinitamente, simulando un semplice meccanismo di alternanza tra due container distribuiti su host differenti.

## PINGPONG

```ruby
Vagrant.configure("2") do |config|

#1° MACCHINA

    config.vm.define "rocky4" do |config|
    config.vm.box = "generic/rocky8"
    config.vm.hostname = "rocky4"
    config.vm.network "private_network", ip: "192.168.56.10"
    config.vm.synced_folder "./condivisa", "/condivisa"

    config.vm.provision "shell", inline: <<-SHELL
     dnf install podman -y

     cat <<'FINE' > /home/vagrant/pingpong
      #!/usr/bin/env bash
      read -p "Quante volte vuoi eseguire il ping pong? " n
      for ((i=1; i<=n; i++)); do
          podman start ping >/dev/null
          echo "Container ping eseguito"
          sleep 60
          podman stop ping >/dev/null
          ssh vagrant@192.168.56.12 "podman start pong >/dev/null"
          echo "Container pong eseguito"
          sleep 60 
          ssh vagrant@192.168.56.12 "podman stop pong >/dev/null"
      done
     FINE
     SHELL

     config.vm.provision "shell", inline: <<-SHELL
     chmod +x /home/vagrant/pingpong
     sudo -u vagrant ssh-keygen -t ed25519 -N "" -f /home/vagrant/.ssh/id_ed25519
     cp /home/vagrant/.ssh/id_ed25519.pub /condivisa
     sudo -u vagrant podman create --name ping alpine sleep 60
     SHELL
   
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end

#2° MACCHINA

   config.vm.define "rocky3" do |config|
    config.vm.box = "generic/rocky8"
    config.vm.hostname = "rocky3"
    config.vm.network "private_network", ip: "192.168.56.12"
    config.vm.synced_folder "./condivisa", "/condivisa"

    config.vm.provision "shell", inline: <<-SHELL
    dnf install podman -y   
    sudo -u vagrant podman create --name pong alpine sleep 60
    cat /condivisa/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys
    SHELL

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
    end
  end
end
```

Ho configurato un ambiente composto da due macchine virtuali portabili basate su Rocky Linux, collegate tra loro tramite una rete privata. Su entrambe le macchine ho installato Podman e creato un container dedicato: ping sulla prima macchina e pong sulla seconda. Per consentire la comunicazione automatica tra le due VM, ho configurato l'autenticazione SSH tramite chiavi pubbliche, generando la chiave sulla prima macchina e autorizzandola sulla seconda attraverso una cartella condivisa. Sulla prima macchina ho creato uno script che gestisce l'esecuzione alternata dei due container. Lo script avvia il container ping, lo mantiene in esecuzione per un minuto e successivamente lo arresta; quindi si collega via SSH alla seconda macchina, avvia il container pong, lo lascia in esecuzione per un minuto e infine lo arresta. Il ciclo viene ripetuto per il numero di volte scelto dall'utente, simulando un semplice meccanismo di "ping-pong" tra due host distinti.

