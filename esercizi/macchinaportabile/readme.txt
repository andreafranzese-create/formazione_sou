Ho configurato un ambiente composto da due macchine virtuali portabili: una basata su Rocky Linux e una su Debian.
Sulla macchina Rocky Linux ho installato e configurato un server web Apache HTTPS con certificati autofirmati. Il servizio è in esecuzione e ascolta sulla porta 443.
La seconda macchina, Debian, è utilizzata come client di test: da questa macchina verifico il corretto funzionamento del server web utilizzando il comando curl.
Inoltre, il server web è raggiungibile anche dalla macchina host.
