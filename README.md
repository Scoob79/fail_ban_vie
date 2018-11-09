Ce script permet de récupérer les adresse IP bannies par fail2ban de les ajouter à iptables et de les intergrer dans un fichier iptable_base que la fonction --iptables les ajoute au redémarrage dans iptable. 

# Installation

- `nano fail_ban_vie.sh`
- copie collé du code
- Modifier la valeurs en haut (API_Key)
- ctrl+x

Le rendre executable
- `chmod +x ./fail_ban_vie.sh`
                                                                                                             
# Fonctionnement :

une fois les deux scripts copier et mis en execution sur la machine il ne vous reste plus qu'a les ajouter
dans la table cron de root.

    ./fail_ban_vie.sh --ban     Surveille toutes les minutes les logs de fail2ban
    ./fail_ban_vie.sh --banlog  Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
    ./fail_ban_vie.sh --iptable Cherche actuellement bannies par fail2ban et les rajoute dans iptables
    ./fail_ban_vie.sh --geoloc  Affiche la base en y ajoutant la geolocalisation
    ./fail_ban_vie.sh --coh_base    Remet en cohérencela base par rapport à iptables

### En root :

crontab -e

Copier les deux lignes suivantes :

    * * * * * /le chemin absolu/fail_ban_vie.sh --ban # Surveille toutes les minutes les logs de fail2ban
    0 12 * * * /le chemin absolu/fail_ban_vie.sh --banlog # Cherche toutes les ip dans /var/log/auth.log qui on tentées de se connecter en root et les rajoute dans iptables
    @reboot /le chemin absolu/fail_ban_vie.sh --iptable # Remet les IP bannies dans iptables
