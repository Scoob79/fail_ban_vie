#!/bin/bash

#   ________   ______   ______  __               _______    ______   __    __     __     __  ______  ________ 
#  |        \ /      \ |      \|  \             |       \  /      \ |  \  |  \   |  \   |  \|      \|        \
#  | $$$$$$$$|  $$$$$$\ \$$$$$$| $$             | $$$$$$$\|  $$$$$$\| $$\ | $$   | $$   | $$ \$$$$$$| $$$$$$$$
#  | $$__    | $$__| $$  | $$  | $$             | $$__/ $$| $$__| $$| $$$\| $$   | $$   | $$  | $$  | $$__    
#  | $$  \   | $$    $$  | $$  | $$             | $$    $$| $$    $$| $$$$\ $$    \$$\ /  $$  | $$  | $$  \   
#  | $$$$$   | $$$$$$$$  | $$  | $$             | $$$$$$$\| $$$$$$$$| $$\$$ $$     \$$\  $$   | $$  | $$$$$   
#  | $$      | $$  | $$ _| $$_ | $$_____        | $$__/ $$| $$  | $$| $$ \$$$$      \$$ $$   _| $$_ | $$_____ 
#  | $$      | $$  | $$|   $$ \| $$     \ ______| $$    $$| $$  | $$| $$  \$$$ ______\$$$   |   $$ \| $$     \
#   \$$       \$$   \$$ \$$$$$$ \$$$$$$$$|      \\$$$$$$$  \$$   \$$ \$$   \$$|      \\$     \$$$$$$ \$$$$$$$$
#                                         \$$$$$$                              \$$$$$$                        
#                                                                                                             
#                                                                                                             

#set -x
aide () {
echo "
   ________   ______   ______  __               _______    ______   __    __     __     __  ______  ________ 
  |        \ /      \ |      \|  \             |       \  /      \ |  \  |  \   |  \   |  \|      \|        \
  | ########|  ######\ \######| ##             | #######\|  ######\| ##\ | ##   | ##   | ## \######| ########
  | ##__    | ##__| ##  | ##  | ##             | ##__/ ##| ##__| ##| ###\| ##   | ##   | ##  | ##  | ##__    
  | ##  \   | ##    ##  | ##  | ##             | ##    ##| ##    ##| ####\ ##    \##\ /  ##  | ##  | ##  \   
  | #####   | ########  | ##  | ##             | #######\| ########| ##\## ##     \##\  ##   | ##  | #####   
  | ##      | ##  | ## _| ##_ | ##_____        | ##__/ ##| ##  | ##| ## \####      \## ##   _| ##_ | ##_____ 
  | ##      | ##  | ##|   ## \| ##     \ ______| ##    ##| ##  | ##| ##  \### ______\###   |   ## \| ##     \
   \##       \##   \## \###### \########|      \\\\#######  \##   \## \##   \##|      \\\\#     \###### \########
                                         \######                              \######                        

  #############################################################################################################
  # Ce script permet de récupérer les adresse IP bannies par fail2ban de les ajouter à iptables et de les     #
  # intergrer dans un fichier iptable_base que la fonction --iptables les ajoute au redémarrage dans iptable. #
  #############################################################################################################
                                                                                                             
Fonctionnement :
================

une fois les deux scripts copier et mis en execution sur la machine il ne vous reste plus qu'a les ajouter
dans la table cron de root.

    ./fail_ban_vie.sh --ban         Surveille toutes les minutes les logs de fail2ban
    ./fail_ban_vie.sh --banlog      Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
    ./fail_ban_vie.sh --iptable     Cherche actuellement bannies par fail2ban et les rajoute dans iptables
    ./fail_ban_vie.sh --geoloc      Affiche la base en y ajoutant la geolocalisation
    ./fail_ban_vie.sh --coh_base    Remet en cohérencela base par rapport à iptables

En root :
---------

crontab -e

Copier les deux lignes suivantes :

* * * * * /le chemin absolu/fail_ban_vie.sh --ban # Surveille toutes les minutes les logs de fail2ban
0 12 * * * /le chemin absolu/fail_ban_vie.sh --banlog # Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
@reboot /le chemin absolu/fail_ban_vie.sh --iptable # Remet les IP bannies dans iptables
"
}

API_Key="o.XwShYtgQ3h3QU7c1lOJ2kNFkz8n0uen4"

ban () { # Cherche actuellement bannies par fail2ban et les rajoute dans iptables

chaine=$(fail2ban-client status sshd | tail -n 1) # Récupère les IP actuellement bannies par fail2ban
ips=1
until [[ -z "$ips" ]]    # Tant que IP n'est pas égale à rien
    do 
    numero=$(($numero + 1)) # Incrémente le numéro de colonne pour la prochaine IP
    ip="${chaine##*:}:" # Supprime tout ce qu'il y a avant les IP
    ip=$(echo $ip | sed 's/\ /:/g') # Remplace tout les espace par des : 
    ips=$(echo $ip | cut -d ':' -f $numero) # Récupère l'IP
    if [ "$ips" != "" ] ;then   # Si IP n'est pas égale à rien    
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ips) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
            /sbin/iptables -I INPUT -s $ips -j DROP
            echo $ips
            vil=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ips | cut -d ',' -f 5 | sed "s/\ //" | sed "s/ò/o/; s/ê/e/; s/ä/a/g" )
            cp=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ips | cut -d ',' -f 6)
            cnt=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ips | cut -d ',' -f 4 | sed "s/\ //") 
            url=$(echo "http://trouver-ip.com/index.php?ip=$ips")
/home/sadmin/script/pushbullet.sh --push_contact  $API_Key "..:: IP BANNIE ::.." "Nouvelle attaque :
IP : $ips
Ville : $vil
Code postal : $cp
Pays : $cnt
URL : $url" "scoob79mobile@gmail.com"
        fi
        base=$(cat /var/log/iptable_base | grep $ips) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
            ret1=$(cat /var/log/auth.log |  grep --binary-files=text "Failed password for invalid user" | grep "$ips"  | wc -l)
            ret2=$(cat /var/log/auth.log |  grep --binary-files=text "Failed password for root from" | grep "$ips"  | wc -l)
            if [ "$ret1" -gt 0 ]; then echo $ips":$ret1" >> /var/log/iptable_base; fi
            if [ "$ret2" -gt 0 ]; then echo $ips":$ret2" >> /var/log/iptable_base; fi
            
        fi 
    fi
done
}

iptable () { # Cherche toutes les ip dans /var/log/iptable_base et les rajoute dans iptables
ip=1
until [[ -z "$ip" ]]    # Tant que IP n'est pas égale à rien
    do 
    numero=$(($numero + 1)) # Incrémente le numéro de colonne pour la prochaine IP
    ip=$(cat /var/log/iptable_base | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connaxion en root a été effectuée
    ip=$(echo $ip | cut -d ':' -f 1)
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies et ne contient que des chiffre et .
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then echo $ip >> /var/log/iptable_base; echo $ip;fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done
}

ban_log () { # Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
ip=1
I=0
BCDIR=$(which bc)
CUTDIR=$(which cut)
until [[ -z "$ip" ]]    # Tant que IP n'est pas égale à rien
    do 
    numero=$(($numero + 1)) # Incrémente le numéro de colonne pour la prochaine IP
    rech="Failed password for root from"
    ip=$(cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f 12 | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connaxion en root a été effectuée
    
    NBLIGNE=`cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f1 | wc -l`
    PROGRESS=`"$BCDIR" -l <<< "($I/$NBLIGNE)*100" | $CUTDIR -d"." -f1`
    echo -ne "Progression : $PROGRESS%\r"
    let "I=$I+1"
    
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP;  echo $ip; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then 
            echo $ip":"$(cat /var/log/auth.log |  grep --binary-files=text "$rech" | grep "$ip"  | wc -l) >> /var/log/iptable_base  
        fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute

    fi
done

I=0

until [[ -z "$ip" ]]    # Tant que IP n'est pas égale à rien
    do 
    rech="Failed password for invalid user"
    ip=$(cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f 12 | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connaxion en root a été effectuée
    
    NBLIGNE=`cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f1 | wc -l`
    PROGRESS=`"$BCDIR" -l <<< "($I/$NBLIGNE)*100" | $CUTDIR -d"." -f1`
    echo -ne "Progression : $PROGRESS%\r"
    let "I=$I+1"
    
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP;  echo $ip; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then 
            echo $ip":"$(cat /var/log/auth.log |  grep --binary-files=text "$rech" | grep "$ip"  | wc -l) >> /var/log/iptable_base  
        fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done
}

geoloc () { # Affiche la base en y ajoutant la geolocalisation
echo "========================================================================================================================================================================================"
printf "%-20s %-20s %-10s %-25s %-20s %-52s %-7s %-10s %-10s %-3s\n" "| IP" "| Ville" "| CP" "| Province" "| Nombre d'attaque" "| Afficher la carte" "| Etat" "| pkts" "| bits" "|"
echo "========================================================================================================================================================================================"
ip=1
te=teste
until [[ -z "$ip" ]]    # Tant que IP n'est pas égale à rien
    do 
    numero=$(($numero + 1)) # Incrémente le numéro de colonne pour la prochaine IP
    ip=$(cat /var/log/iptable_base | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connaxion en root a été effectuée
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        # Geolocalise les adresse IP
        nb=$(echo $ip | cut -d ':' -f 2)
        ip=$(echo $ip | cut -d ':' -f 1)
        vil=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 5 | sed "s/\ //" | sed "s/ò/o/; s/ê/e/; s/é/e/; s/è/e/; s/ö/o/" )
        cp=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 6)
        cnt=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 4 | sed "s/\ //") 
        drop=$(iptables -L INPUT -v -n | grep DROP | grep "$ip")
        if [ "$drop" != "" ]; then etat="DROP"; else etat="";fi
        pkts=$(iptables -L INPUT -v -n | grep DROP | grep "$ip" | cut -d ' ' -f1-5 | sed 's/\ //g')
        bits=$(iptables -L INPUT -v -n | grep DROP | grep "$ip" | cut -d ' ' -f6-10 | sed 's/DROP//g; s/\ //g')
        url=$(echo "http://trouver-ip.com/index.php?ip=$ip")
        
        printf "%-20s %-20s %-10s %-25s %-20s %-52s %-7s %-10s %-10s %-3s\n" "| $ip" "| $vil" "| $cp" "| $cnt" "| $nb" "| $url" "| $etat" "| $pkts" "| $bits" "|"
    fi
done
echo "========================================================================================================================================================================================"
echo "$numero IP enregistrées et bannies"
}

base () { # Remet en cohérence la base et iptables
ip_iptable=$(iptables -L INPUT -v -n | grep DROP | cut -d ' ' -f30-38 | sed 's/\ //g') # Récupère les IP bloquées dans iptables
ip=1
numero=0
until [[ -z "$ip" ]] # Tant que IP n'est pas égale à rien
    do
    let "numero = numero +1"
    ip=$(echo "$ip_iptable" | cut -d '
' -f $numero) # Détermine l'IP suivante
    if [ "$ip" != "" ]; then   # Si IP n'est pas égale à rien et ne contient que des chiffre et .
        compare=$(grep "$ip" /var/log/iptable_base)
        if [ "$compare" == "" ]; then echo $ip >> /var/log/iptable_base; echo $ip;fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done

iptable
}

if [ -f /var/log/iptable_base ]; then test; else touch /var/log/iptable_base; fi # Si la base n'existe pas il l'a crée
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then aide; exit 0; fi
if [ "$1" == "--ban" ]; then ban; exit 0; fi
if [ "$1" == "--banlog" ]; then ban_log; exit 0; fi
if [ "$1" == "--iptable" ]; then iptable; exit 0; fi
if [ "$1" == "--geoloc" ]; then geoloc; exit 0; fi
if [ "$1" == "--coh_base" ]; then base; exit 0; fi
