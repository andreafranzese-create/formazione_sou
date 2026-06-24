##Script per l'orchestrazione del pingpong tra due container, uno locale e uno remoto.

#!/usr/bin/env bash
	
verifica_3opt() {
if [[ ! "$opt" =~ ^[1-3]$ ]]; then
        echo "ERRORE INSERIRE UN VALORE VALIDO"
        exit 1
fi
}

checkloc() {
            if ! podman container exists "$nomec1"; then
                    echo "ERRORE il container non esiste"
                    exit 1
            fi
    }

checkrem() {
	if ! ssh vagrant@192.168.56.12 "podman container exists '$nomec2'"; then
                    echo "ERRORE il container non esiste"
                    exit 1
            fi
    }

chiusura_for() {
	echo
    podman kill "$nomec1" &>/dev/null
    ssh vagrant@192.168.56.12 "podman kill $nomec2 &>/dev/null"
	echo "Interruzione forzata"
    exit 1
}

load() {
echo
echo -n "Caricamento in corso"
for ((j=0;j<4;j++));do
echo -n "."
sleep 1
done
echo
echo
}

trap chiusura_for SIGINT

load

while true;do 
  	echo "===== MENU PINGPONG ====="
        echo "1) Crea un container per il pingpong"
        echo "2) Elimina un container"
        echo "3) Avvia pingpong"
        echo "4) Visualizza info su container"
        echo "5) Esci"
        echo
        read -p "Selezione: " opt
        echo
if [[ ! "$opt" =~ ^[1-5]$ ]]; then
        echo "ERRORE INSERIRE UN VALORE VALIDO"
        exit 1
fi

case "$opt" in
1)
	while true; do
	echo "===== MENU ====="
	echo "1) Crea un container sulla macchina locale"
	echo "2) Crea un container sulla macchina remota"
        echo "3) Back"
       	echo
    read -p "Selezione: " opt
    echo
   
    verifica_3opt
   
    case "$opt" in
	    1)
		    read -p "Inserisci un nome per il container: " nomec1
	       	    podman create --name "$nomec1" alpine sleep 60 &>/dev/null
		    if [[ $? = 0 ]]; then
			    echo "Container $nomec1 creato con successo"
		    else
			    echo "ERRORE creazione fallita"
			    exit 1
		    fi
		    echo
		    ;;
	    2)
		    read -p "Inserisci un nome per il container: " nomec2
		    if ssh vagrant@192.168.56.12 "podman create --name '$nomec2' alpine sleep 60 &>/dev/null"; then
			    echo "Container $nomec2 creato con successo"
		    else
			    echo "ERRORE creazione fallita"
			    exit 1
		    fi
		    echo
		    ;;
	    3)
		    break
    esac
done
   ;;
2)
	while true; do
	echo "===== MENU ====="
	echo "1) Elimina un container sulla macchina locale"
	echo "2) Elimina un container sulla macchina remota"
	echo "3) Back"
	echo 

        read -p "Selezione: " opt
	echo

	verifica_3opt

	case "$opt" in
		1)
			echo "Lista di container disponibili:"
			podman ps -a --format "{{.Names}}" 2>/dev/null
			read -p "Inserisci il nome del container da eliminare: " nomec1
			checkloc
			podman kill $nomec1 &>/dev/null
			podman rm $nomec1 &> /dev/null
			echo "Container $nomec1 rimosso con successo"
			echo
			break
			;;
		2)
			echo "Lista di container disponibili:"
			ssh vagrant@192.168.56.12 "podman ps -a --format '{{.Names}}' 2>/dev/null"
			echo
			read -p "Inserisci il nome del container da eliminare: " nomec2
			checkrem
			ssh vagrant@192.168.56.12 "podman kill $nomec2 &>/dev/null"
			ssh vagrant@192.168.56.12 "podman rm $nomec2 &>/dev/null"
			echo "Container $nomec2 rimosso con successo"
		        break
			echo
			;;
		3)
			break
		;;
	esac
    done
	;;	
3)
	while true; do
	echo "===== IMPOSTAZIONI PINGPONG ====="
        echo "1) Avvia pingpong infinito"
        echo "2) Avvia pingpong per n volte"
        echo "3) Back"
        echo 
        read -p "Selezione: " opt
        echo

	verifica_3opt

    case "$opt" in
    1)
	    echo "Lista di container disponibili:"
            podman ps -a --format "{{.Names}}" 2>/dev/null
	    echo
	    read -p "Inserisci il nome del container da utilizzare in locale: " nomec1
	    echo
	    checkloc
            echo "Lista di container disponibili:"
            ssh vagrant@192.168.56.12 "podman ps -a --format '{{.Names}}' 2>/dev/null"
	    echo
	    read -p "Inserisci il nome del container da utilizzare da remoto: " nomec2
 	   echo
	   checkrem
	   read -p "Inserisci ogni quanto va passata la palla (MAX 60s): " temp
	   echo
	   if [[ ! $temp =~ ^[0-9]+$ || $temp == 0 ]]; then
		   echo "ERRORE inserire un tempo valido"
		   exit 1
	   elif (( $temp > 60 )); then
		   echo "ERRORE il valore massimo è 60"
		   exit 1
	   fi
	   while true; do
             podman start $nomec1 &>/dev/null
             echo "Turno del container $nomec1"
             sleep "$temp"
             podman stop $nomec1 &>/dev/null
             ssh vagrant@192.168.56.12 "podman start $nomec2 &>/dev/null"
             echo "Turno del container $nomec2"
             sleep "$temp" 
             ssh vagrant@192.168.56.12 "podman stop $nomec2 &>/dev/null"
         done
         ;;

    2)
	 echo "Lista di container disponibili:"
          podman ps -a --format "{{.Names}}" 2>/dev/null
	 echo
	  read -p "Inserisci il nome del container da utilizzare da locale: " nomec1
	 checkloc
         echo
	 echo "Lista di container disponibili:"
          ssh vagrant@192.168.56.12 "podman ps -a --format '{{.Names}}' 2>/dev/null"  
	 echo
	  read -p "Inserisci il nome del container da usare da remoto: " nomec2
	   checkrem
	   echo
	   read -p "Quante volte vuoi eseguire il ping pong?: " n
	 if [[ ! $n =~ ^[0-9]+$ ]];then
		 echo "ERRORE inserire un numero valido"
		 exit 1
	 fi
	 read -p "Inserisci ogni quanto va passata la palla (MAX 60s): " temp
	 echo
	 if [[ ! $temp =~ ^[0-9]+$ || $temp == 0 ]]; then
		echo "ERRORE inserire un tempo valido"
	       exit 1	
	 elif (( $temp > 60 )); then
                   echo "ERRORE inserire un tempo valido"
                   exit 1
           fi
       	   for ((i=1; i<=n; i++)); do
             podman start $nomec1 &>/dev/null
             echo "Turno del container $nomec1"
             sleep $temp
             podman stop $nomec1 &>/dev/null
             ssh vagrant@192.168.56.12 "podman start '$nomec2' &>/dev/null"
             echo "Turno del container $nomec2"
             sleep $temp
             ssh vagrant@192.168.56.12 "podman stop '$nomec2' &>/dev/null"
     done
    break
    ;;
    3)
	    break
	    ;;
    esac
done
    ;;
4)
	while true; do
echo "===== MENU CONTAINER ====="
echo "1) Visualizza info su container locali"
echo "2) Visualizza info su container remoti"
echo "3) Back"
echo

read -p "Selezione: " opt
echo

verifica_3opt

case "$opt" in
	1)
	        echo "Lista di container disponibili:"
                podman ps -a --format "{{.Names}}" 2>/dev/null
		echo
		read -p "Inserire il nome del container: " nomec1
		while true; do
                checkloc
		echo "===== MENU CONTAINER LOCALI ====="
		echo "1) Visualizza l'id del container"
		echo "2) Visualizza la data di creazione del container"
                echo "3) Visualizza l'immmagine del container"
		echo "4) Visualizza lo stato del container"
		echo "5) Visualizza il comando del container"
		echo "6) Back"
		echo

		declare -A container
		container[id]=$(podman ps -a --filter "name=$nomec1" --format "{{.ID}}")
		container[date]=$(podman ps -a --filter "name=$nomec1" --format "{{.CreatedAt}}")
		container[image]=$(podman ps -a --filter "name=$nomec1" --format "{{.Image}}")
		container[state]=$(podman ps -a --filter "name=$nomec1" --format "{{.Status}}")
		container[command]=$(podman ps -a --filter "name=$nomec1" --format "{{.Command}}")

		read -p "Selezione: " opt
		echo

		if [[ ! "$opt" =~ ^[0-6]$ ]]; then
                    echo "ERRORE INSERIRE UN VALORE VALIDO"
                    exit 1
                fi

		case "$opt" in
			1)
				echo "L'ID del container è ${container[id]}";
			echo
				;;
			2)
				echo "La data di creazione è ${container[date]}"
			echo
				;;
			3)
				echo "L'immagine del container è ${container[image]}"
			echo
				;;
			4)
				echo "Lo stato del container è ${container[state]}"
			echo
				;;
			5)
				echo "Il comando nel container è ${container[command]}"
			echo
				;;
			6)
				break
				;;
		esac
	done
		;;
	2)
		echo
		echo "Lista di container disponibili:"
                ssh vagrant@192.168.56.12 "podman ps -a --format '{{.Names}}' 2>/dev/null"
		echo
		read -p "Inserire il nome del container: " nomec2
		echo
		while true; do
                checkrem
	        echo "===== MENU CONTAINER REMOTO ====="
                echo "1) Visualizza l'id del container"
                echo "2) Visualizza la data di creazione del container"
                echo "3) Visualizza l'immmagine del container"
                echo "4) Visualizza lo stato del container"
                echo "5) Visualizza il comando del container"
                echo "6) Back"
                echo

                declare -A container
                container[id]=$(ssh vagrant@192.168.56.12 "podman ps -a --filter 'name=$nomec1' --format '{{.ID}}'")
                container[date]=$(ssh vagrant@192.168.56.12 "podman ps -a --filter 'name=$nomec1' --format '{{.CreatedAt}}'")
                container[image]=$(ssh vagrant@192.168.56.12 "podman ps -a --filter 'name=$nomec1' --format '{{.Image}}'")
                container[state]=$(ssh vagrant@192.168.56.12 "podman ps -a --filter 'name=$nomec1' --format '{{.Status}}'")
                container[command]=$(ssh vagrant@192.168.56.12 "podman ps -a --filter 'name=$nomec1' --format '{{.Command}}'")
                read -p "Selezione: " opt

                if [[ ! "$opt" =~ ^[0-6]$ ]]; then
                    echo "ERRORE INSERIRE UN VALORE VALIDO"
                    exit 1
		fi
		    case "$opt" in
                        1)
                                echo "L'ID del container è ${container[id]}"
                        echo
				;;
                        2)
                                echo "La data di creazione è ${container[date]}"
                            echo
			    	;;
                        3)
                                echo "L'immagine del container è ${container[image]}"
                                echo
				;;
                        4)
                                echo "Lo stato del container è ${container[state]}"
                                echo
				;;
                        5)
                                echo "Il comando nel container è ${container[command]}"
                                echo
				;;
                        6)
                                break
                                ;;
                esac
        done
                ;;
	3)
		break
		;;
esac
done

    ;;
5)
	echo "Chiusura effettuata"
	exit 0
	;;
esac
done
