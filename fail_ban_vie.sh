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

    ./fail_ban_vie.sh --ban     Surveille toutes les minutes les logs de fail2ban
    ./fail_ban_vie.sh --banlog  Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
    ./fail_ban_vie.sh --iptable Cherche actuellement bannies par fail2ban et les rajoute dans iptables
    ./fail_ban_vie.sh --geoloc  Affiche la base en y ajoutant la geolocalisation

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
            vil=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ips | cut -d ',' -f 5 | sed "s/\ //" | sed "s/ò/o/; s/ê/e/" )
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
        if [ "$base" == "" ]; then echo $ips >> /var/log/iptable_base; fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
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
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then echo $ip >> /var/log/iptable_base; echo $ip;fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done
}

ban_log () { # Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
ip=1
until [[ -z "$ip" ]]    # Tant que IP n'est pas égale à rien
    do 
    numero=$(($numero + 1)) # Incrémente le numéro de colonne pour la prochaine IP
    
   ip=$(cat /var/log/auth.log | grep "Failed password for root from" | cut -d ' ' -f 12 | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connaxion en root a été effectuée
    rech="Failed password for root from"
    
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP;  echo $ip; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then 
            echo $ip":"$(cat /var/log/auth.log |  grep "Failed password for root from" | grep "$ip"  | wc -l) >> /var/log/iptable_base  
        fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done
    
until [[ -z "$ip" ]]    # Tant que IP n'est pas égale à rien
    do 
    ip=$(cat /var/log/auth.log | grep "Failed password for invalid user" | cut -d ' ' -f 12 | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connaxion en root a été effectuée
    rech="Failed password for invalid user"
    
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP;  echo $ip; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then 
            echo $ip":"$(cat /var/log/auth.log |  grep "Failed password for root from" | grep "$ip"  | wc -l) >> /var/log/iptable_base  
        fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done
}

geoloc () { # Affiche la base en y ajoutant la geolocalisation
echo "==============================================================================================================================================================="
printf "%-20s %-20s %-20s %-20s %-20s %-52s %-20s\n" "| IP" "| Ville" "| Code Postal" "| Pays" "| Nombre d'attaque" "| Afficher la carte" "|"
echo "==============================================================================================================================================================="
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
        vil=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 5 | sed "s/\ //" | sed "s/ò/o/; s/ê/e/" )
        cp=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 6)
        cnt=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 4 | sed "s/\ //") 
        
        url=$(echo "http://trouver-ip.com/index.php?ip=$ip")
        
        printf "%-20s %-20s %-20s %-20s %-20s %-52s %-3s\n" "| $ip" "| $vil" "| $cp" "| $cnt" "| $nb" "| $url" "|"
    fi
done
echo "==============================================================================================================================================================="

}

if [ -f /var/log/iptable_base ]; then test; else touch /var/log/iptable_base; fi # Si la base n'existe pas il l'a crée
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then aide; exit 0; fi
if [ "$1" == "--ban" ]; then ban; exit 0; fi
if [ "$1" == "--banlog" ]; then ban_log; exit 0; fi
if [ "$1" == "--iptable" ]; then iptable; exit 0; fi
if [ "$1" == "--geoloc" ]; then geoloc; exit 0; fi
