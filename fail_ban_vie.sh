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
# set -x
aide () {
echo -e "
   ________   ______   ______  __               _______    ______   __    __     __     __  ______  ________ 
  |        \ /      \ |      \|  \             |       \  /      \ |  \  |  \   |  \   |  \|      \|        \

  | ########|  ######\ \######| ##             | #######\|  ######\| ##\ | ##   | ##   | ## \######| ########
  | ##__    | ##__| ##  | ##  | ##             | ##__/ ##| ##__| ##| ###\| ##   | ##   | ##  | ##  | ##__    
  | ##  \   | ##    ##  | ##  | ##             | ##    ##| ##    ##| ####\ ##    \##\ /  ##  | ##  | ##  \   
  | #####   | ########  | ##  | ##             | #######\| ########| ##\## ##     \##\  ##   | ##  | #####   
  | ##      | ##  | ## _| ##_ | ##_____        | ##__/ ##| ##  | ##| ## \####      \## ##   _| ##_ | ##_____ 
  | ##      | ##  | ##|   ## \| ##     \ ______| ##    ##| ##  | ##| ##  \### ______\###   |   ## \| ##     \
   
   \##       \##   \## \###### \########|       \#######  \##   \## \##   \##|       \#     \###### \########
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
    ./fail_ban_vie.sh --config      Permet de créer ou de modifier le fichier de configuration du script
    ./fail_ban_vie.sh --github      Met à jour le fichier liste sur le dépot github

En root :
---------

crontab -e

Copier les lignes suivantes :

* * * * * /le chemin absolu/fail_ban_vie.sh --ban # Surveille toutes les minutes les logs de fail2ban
0 12 * * * /le chemin absolu/fail_ban_vie.sh --banlog # Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
@reboot /le chemin absolu/fail_ban_vie.sh --iptable # Remet les IP bannies dans iptables
"
}

#################################################################################################################
#################################################################################################################

# CETTE PARTIE CONCERNE LA TOTALITE DE L'OPTION --CONFIG
init () {
echo "Configuration :
===============

Cette option vous permet de configurer ce script afin de pouvoir l'utiliser
Pour utiliser l'option GITHUB vous devez avoir déjà un compte Github et y avoir créé un dépot pour la diffusion de la liste  
Pour utiliser l'option PUSHBULLET vous devez dipsoer d'un compte sur pushbullet et de sa clé API

"
rm config
echo "Voulez-vous activer l'option pushbullet ? (y\n) "
read reponse1
if [ "$reponse1" == "y" ]; then pushbullet; fi
echo "pushbullet=$reponse1" >> config
}

init2 () {


echo "
Voulez-vous activer l'option github ? (y\n) "
read reponse2
if [ "$reponse2" == "y" ]; then github; fi
echo "# GENERAL

github=$reponse2" >> config
}

github () {

echo "
Configuration de la partie GITHUB :
-----------------------------------
"

echo "Votre adresse mail : "
read mail
if [ "$mail" == "" ]; then echo "Entrée incorrect."; github; fi

echo "Votre nom : "
read nom
if [ "$nom" == "" ]; then echo "Entrée incorrect."; github; fi

echo "L'adresse du dépot Github : "
read depot
if [ "$depot" == "" ]; then echo "Entrée incorrect."; github; fi

echo "# GITHUB

mail=$mail
nom=$nom
depot=$depot
" >> config


ssh-keygen -t rsa -P "" -f /home/sadmin/.ssh/id_rsa -C "$mail" # Crée la clé rsa et l'affiche
echo ""
cat /$HOME/.ssh/id_rsa.pub
echo "
Veuiller copier cette clé et l'enregistrer sur votre compte github dans Settings puis SSH and GPG keys. New SSH key"
echo "Cette clé RSA est votre clé publique, elle servira à autoriser ce script à accéder à votre compte Github pour mettre à jour la liste."
echo "Une fois cela fait appuier sur entrer"
read

# Configuration de Github

git config --global user.name $nom
git config --global user.name $mail

echo "#SSH ATTAQUE
Vous trouverez dans se fichier l'ensemble des adresse IP qui mon attaquées qui sont donc à consiérer comme dangereuses." > README.md
}

pushbullet () {

echo "
Configuration de la partie PUSHBELLET :
---------------------------------------
"

echo "Clé API : "
read api
if [ "$api" == "" ]; then echo "Entrée incorrect."; pushbullet; fi

echo "Chmein d'accès au script Pushbullet : "
read script_push
if [ "$script_push" == "" ]; then echo "Entrée incorrect."; pushbullet; fi

echo "# PUSBULLET

API_key=$api
script_push=$script_push
" >> config

init2
}

#################################################################################################################
#################################################################################################################


#################################################################################################################
##############################################DECLARATION DES VARIABLES##########################################
#################################################################################################################

if [ -f ./config ]; then test; else init; fi # Si le fichier de configuration n'existe pas il passe en configuration

# Récupère les paramètre dans le fichier de configuration et initialise les variables
# PUSHBULLET (https://github.com/Scoob79/Pushbullet) <================================================================================================================
                                                                                                                                                                     #
API_Key=$(grep "api" config | sed 's/api=//')                                                                                                                        #
pushbullet=$(grep "pushbullet" config | sed 's/pushbullet=//') # Active les messages pushbullet !!! ATTENTION !!! Necessite une clé API pushbullet et le script pushbullet.sh 
script_pushbullet=/home/sadmin/script/pushbullet.sh # Définie le chemin d'accès au script pushbullet

# GITHUB

github=$(grep "github=" config | sed 's/github=//') # Active la diffusion sur github des résultats de la géolocalisation lors du bannissement d'une nouvelle IP
adresse_github=$(grep "depot" config | sed 's/depot=//')
depot_github=$(echo $adresse_github | cut -d "/" -f2 | cut -d '.' -f1) # Récupère uniquement le nom du dépôt depuis l'adresse

#################################################################################################################
#################################################################################################################


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
if [ "$pushbullet" == "y" ]; then 
$script_pushbullet --push_contact  $API_Key "..:: IP BANNIE ::.." "Nouvelle attaque :
IP : $ips
Ville : $vil
Code postal : $cp
Pays : $cnt
URL : $url" "scoob79mobile@gmail.com"
fi
        github
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
numero=0
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
    ip=$(cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f 11 | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connexion en root a été effectuée
    
    NBLIGNE=`cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f1 | wc -l`
    PROGRESS=`"$BCDIR" -l <<< "($I/$NBLIGNE)*100" | $CUTDIR -d"." -f1`
    echo -ne "Progression : $PROGRESS%\r"
    let "I=I+1"
    
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then 
            echo $ip":"$(cat /var/log/auth.log |  grep --binary-files=text "$rech" | grep "$ip"  | wc -l) >> /var/log/iptable_base  
            maj=y
        fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done

I=0

until [[ -z "$ip" ]]    # Tant que IP n'est pas égale à rien
    do 
    rech="Failed password for invalid user"
    ip=$(cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f 11 | cut -d '
' -f $numero) # Recherche la liste de toutes les IP dont une tentative de connaxion en root a été effectuée
    
    NBLIGNE=`cat /var/log/auth.log | grep "$rech" | cut -d ' ' -f1 | wc -l`
    PROGRESS=`"$BCDIR" -l <<< "($I/$NBLIGNE)*100" | $CUTDIR -d"." -f1`
    echo -ne "Progression : $PROGRESS%\r"
    let "I=$I+1"
    
    integre=$(echo $ip | grep [a-zA-Z]) # Vérifie que la chaine IP ne contienne que des chiffres 
    if [ "$ip" != "" ] && [ "$integre" == "" ];then   # Si IP n'est pas égale à rien
        ipt=$(/sbin/iptables -L INPUT -v -n | grep DROP | grep $ip) # Récupère la liste des IP bannies
        if [ "$ipt" == "" ]; then /sbin/iptables -I INPUT -s $ip -j DROP; fi # Control que l'IP ne soit pas déjà bannie si non elle l'a rajoute
        base=$(cat /var/log/iptable_base | grep $ip) # Récupère la liste des IP bannies dans la base
        if [ "$base" == "" ]; then 
            echo $ip":"$(cat /var/log/auth.log |  grep --binary-files=text "$rech" | grep "$ip"  | wc -l) >> /var/log/iptable_base 
            maj=y
        fi # Control que l'IP ne soit pas déjà dans la base si non elle l'a rajoute
    fi
done
if [ "$maj" == "y" ]; then github; fi
}

geoloc () { # Affiche la base en y ajoutant la geolocalisation
echo "============================================================================================================================================================================================================"
printf "%-20s %-25s %-15s %-35s %-25s %-52s %-7s %-20s %-20s %-3s\n" "| IP" "| Ville" "| CP" "| Province" "| Nombre d'attaque" "| Afficher la carte" "| Etat" "| pkts" "| bits" "|"
echo "============================================================================================================================================================================================================"
ip=0
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
        vil=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 5 | sed "s/\ //" | sed "s/ò/o/g; s/ê/e/g; s/é/e/g; s/è/e/g; s/ö/o/g; s/ó/o/g; s/ñ/n/g; s/á/a/g; s/ü/u/g; s/ø/o/g; s/Ü/U/g; s/ë/e/g")
        cp=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 6)
        cnt=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $ip | cut -d ',' -f 4 | sed "s/\ //") 
        drop=$(iptables -L INPUT -v -n | grep DROP | grep "$ip")
        if [ "$drop" != "" ]; then etat="DROP"; else etat="";fi
        pkts=$(iptables -L INPUT -v -n | grep DROP | grep "$ip" | cut -d ' ' -f1-5 | sed 's/DROP//g; s/\ //g')
        bits=$(iptables -L INPUT -v -n | grep DROP | grep "$ip" | cut -d ' ' -f6-10 | sed 's/DROP//g; s/\ //g')
        url=$(echo "http://trouver-ip.com/index.php?ip=$ip")
        
        printf "%-20s %-25s %-15s %-35s %-25s %-52s %-7s %-20s %-20s %-3s\n" "| $ip" "| $vil" "| $cp" "| $cnt" "| $nb" "| $url" "| $etat" "| $pkts" "| $bits" "|"
    fi
done
echo "============================================================================================================================================================================================================"
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


}

github () { # Diffusion sur github des résultats de la géolocalisation lors du bannissement d'une nouvelle IP
if [ "$github" == "y" ]; then
    git clone $adresse_github  > /dev/nul 2>&1 # Récupération du GIT
    ./fail_ban_vie.sh --geoloc > ./$depot_github/liste # Mise à jour de la liste
    echo $(date) >> $depot_github/liste   # Rajout de la date
    cd Attaque-SSH
    git add --all .  > /dev/nul 2>&1
    git commit -m "MAJ $(date)" > /dev/nul 2>&1
    git push $adresse_github master  > /dev/nul 2>&1 # Met à jour le dépôt distant
    cd ..
    rm -rf Attaque-SSH
fi
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then aide; exit 0; fi
if [ "$1" == "--ban" ]; then ban; exit 0; fi
if [ "$1" == "--banlog" ]; then ban_log; exit 0; fi
if [ "$1" == "--iptable" ]; then iptable; exit 0; fi
if [ "$1" == "--geoloc" ]; then geoloc; exit 0; fi
if [ "$1" == "--coh_base" ]; then base; iptable; exit 0; fi
if [ "$1" == "--config" ]; then init; fi
if [ "$1" == "--github" ]; then github; fi
