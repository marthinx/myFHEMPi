#!/bin/bash

# -----------------------------------------------------------------------
# Installs myFHEM using pthsem_2.0.8 on the Raspberry Pi (Raspbian)
#
# Run from the web:
#   bash <(curl -s raw_script_url_here)
# -----------------------------------------------------------------------



do_init() {
# Set up variables
bold="\033[1m"
normal="\033[0m"

# Welcome message
echo -e "\n${bold}This will install myFHEM using pthsem_2.0.8."
echo -e "It can take about 10 minutes to compile on the Raspberry Pi.${normal}"

# Prompt to continue
read -p "  Continue? (y/n) " ans
if [[ $ans != "y" ]]; then
echo -e "\nQuitting...\n"
exit
fi
echo
# Time the install process
START_TIME=$SECONDS
}


do_check_arguments() {
    while [ "$1" != '' ]
    do
    [ $1 == "-b" ] && BACKUP="yes" && echo "Ok. Do a backup!" && shift
    [ $1 == "-r" ] && RESTORE="yes" && echo "Ok. Do a restore!" && shift
    [ $1 == "-c" ] && CLEAN="yes" && echo "Ok. Tidy up!" && shift
    done
}


do_show_menu() {
    # Bash Menu Script Example

    PS3='Please enter your choice: '
    options=("apt-get_update" "install FHEM" "Siri" "timesync" "addons" "checkin" "checkout" "install_myFHEM" "Quit")
    select opt in "${options[@]}"
    do
    case $opt in
        "apt-get_update")
            do_apt-get_update
            ;;
        "install FHEM")
            do_install_fhem
            ;;
        "Siri")
            echo "you chose Siri"
            do_installSiri
            ;;
        "timesync")
            echo "you chose timesync"
            do_timesync
            ;;
        "FHEM_NAS_Backup")
            echo "you chose FHEM_NAS_Backup"
            do_FHEM_NAS_Backup
            ;;
        "addons")
            echo "you chose addons"
            do_install_addons
            ;;
        "checkout")
            echo "you chose checkout"
            do_checkout
            ;;
        "checkin")
            echo "you chose checkin"
            do_checkin
            ;;
        "install_myFHEM")
            echo "you chose myFHEM"
            do_apt-get_update
            do_timesync
            do_install_addons
            do_install_fhem
            do_move_fhem_cfg
            # do_install_knxd
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
    done
}

do_internationalisation_menu() {
  FUN=$(whiptail --title "Raspberry Pi Software Configuration Tool (raspi-config)" --menu "Internationalisation Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "I1 Change Locale" "Set up language and regional settings to match your location" \
    "I2 Change Timezone" "Set up timezone to match your location" \
    "I3 Change Keyboard Layout" "Set the keyboard layout to match your keyboard" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      I1\ *) do_change_locale ;;
      I2\ *) do_change_timezone ;;
      I3\ *) do_configure_keyboard ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}

do_apt-get_update() {
    sudo -y apt-get update
    sudo apt-get install -y debhelper cdbs automake libtool libusb-1.0-0-dev git-core build-essential
}


do_install_fhem() {
    # fhem installieren
    sudo apt-get update && apt-get -y upgrade
    sudo apt-get install apt-transport-https
    sudo apt-get install -f
    echo "myfhem installer"

    sudo wget -qO - https://debian.fhem.de/archive.key | apt-key add -
    sudo deb https://debian.fhem.de/stable ./ sudo apt-get update
    sudo apt-get install -y fhem
}

do_installSiri() {
	echo "~ Die Homebridge wird nun installiert und konfiguriert"
	sudo apt-get update && sudo apt-get -y install libavahi-compat-libdnssd-dev
	wget http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-arm-pi.tar.gz -P /tmp && cd /usr/local && sudo tar xzvf /tmp/node-v0.10.28-linux-arm-pi.tar.gz --strip=1
	echo /usr/bin/env node --version
	echo "=v0,10,28?"
	cd /home/pi && git clone https://github.com/nfarina/homebridge.git && cd homebridge && sudo npm install
	echo "sudo nano ~/homebridge/config.json eingeben"
	
	
 apt-get install lighttpd
 cp ~/homebridge/config.json ~/homebridge/config.json.backup
 rm -f ~/homebridge/config.json
 touch ~/homebridge/config.json
 echo '{
"bridge": {
"name": "Homebridge",
"username": "CC:22:3D:E3:CE:30",
"port": 51826,
"pin": "031-45-154"
},
 
"platforms": [
{
"platform": "FHEM",
"name": "FHEM",
"server": "127.0.0.1",
"port": "8083",
"filter": "room=Homekit",
"auth": {"user": "FHEMUser", "pass": "FHEMPass"}
}
],
 
"accessories": []
}
' >> ~/homebridge/config.json
 sleep 1
	
	sudo npm install forever -g	 
	sudo chmod 755 /etc/init.d/homebridge
	sudo update-rc.d homebridge defaults
	echo "nun Homekit auf iOS installieren z.B. elgato eve"
	echo "Pin lautet standardmässig: 031-45-154"



# autostart homebridge einrichten
# /etc/init.d/homebridge erstellen 
 cp /etc/init.d/homebridge /etc/init.d/homebridge.backup
 rm -f /etc/init.d/homebridge
 touch /etc/init.d/homebridge
 echo '
#!/bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

dir="/home/pi/homebridge"
cmd="DEBUG=* node app.js"
user="root"

name=`basename $0`
pid_file="/var/run/$name.pid"
stdout_log="/var/log/$name.log"
stderr_log="/var/log/$name.err"

get_pid() {
    cat "$pid_file"
}

is_running() {
    [ -f "$pid_file" ] && ps `get_pid` > /dev/null 2>&1
}

case "$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting $name"
        cd "$dir"
        if [ -z "$user" ]; then
            sudo $cmd >> "$stdout_log" 2>> "$stderr_log" &
        else
            sudo -u "$user" $cmd >> "$stdout_log" 2>> "$stderr_log" &
        fi
        echo $! > "$pid_file"
        if ! is_running; then
            echo "Unable to start, see $stdout_log and $stderr_log"
            exit 1
        fi
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping $name.."
        kill `get_pid`
        for i in {1..10}
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "$pid_file" ]; then
                rm "$pid_file"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    $0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    $0 start
    ;;
    status)
    if is_running; then
        echo "Running"
    else
        echo "Stopped"
        exit 1
    fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0 
' >> /etc/init.d/homebridge

# 
sudo chmod 755 /etc/init.d/homebridge
sudo update-rc.d homebridge defaults
sudo /etc/init.d/homebridge start
}

do_timesync() {
    # Zeitserver
    # Zeitsync: Ntp-Systemdienst installieren
    # siehe http://www.meintechblog.de/2015/06/ungenaue-fhem-systemzeit-berichtigen-und-uhrzeit-angelernter-geraete-updaten/

    sudo apt-get install -y ntpdate
    sudo ntpdate -u de.pool.ntp.org
    sudo ntpd -q -g
    # neuer String:
    # sed -e "s/alterString/neuer String/g" /etc/ntp.conf > /etc/ntp.conf_neu
    # sudo nano /etc/crontab
    cat <(crontab -l) <(echo "0 5     * * *   root    ntpd -q -g -x -n") | crontab -
    sudo service cron restart
    # Zeitzone einstellen
    # dpkg-reconfigure tzdata
    TIMEZONE="Europe/Berlin"      
    echo $TIMEZONE > /etc/timezone                     
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime   # This sets the time
    
}

do_setIP() {
    sudo ifconfig eth0 down
    sudo ifconfig eth0 192.168.188.10
    sudo ifconfig eth0 up
}

do_FHEM_NAS_Backup() {
    sudo echo "fhem ALL=(ALL) NOPASSWD:/opt/fhem/FHEM/backup.sh" >> /etc/sudoers
    sudo apt-get update && sudo dpkg --configure -a && sudo apt-get -f install && sudo apt-get -y install cifs-utils curl libcurl3
    sudo touch /opt/fhem/FHEM/backup.sh && sudo chmod 700 /opt/fhem/FHEM/backup.sh && sudo chown -R fhem:root /opt/fhem/FHEM/backup.sh


 echo '#!/bin/bash
 
mountIp="192.168.3.10"
mountDir="backup"
mountUser="admin"
mountPass="password"
mountSubDir="rpi/fhem"
localMountPoint="/Q/backup"
 
#optional
backupsMax="0"
localBackupDir="/backup"
pushoverUser=""
pushoverToken=""
###################################
 
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup info backup starting now"
 
if [ ! -e "$localBackupDir" ]
then
echo "$localBackupDir wird erstellt"
mkdir -p "$localBackupDir"
else
echo "$localBackupDir bereits vorhanden"
fi
 
tar --exclude=backup -cvzf "/$localBackupDir/$(date +%y%m%d_%H%M%S)_fhem_backup.tar.gz" "/opt/fhem" &>/dev/null
 
if ! ping -c 1 $mountIp
then
echo "$mountIp nicht erreichbar, stop"
perl /opt/fhem/fhem.pl 7072 "set FHEM.Backup error"
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup info $mountIp not found"
exit
else
echo "$mountIp erreichbar"
fi
 
localIp=$(hostname -I|sed 's/\([0-9.]*\).*/\1/')
 
if [ ! -e "$localMountPoint" ]
then
echo "$localMountPoint wird erstellt"
mkdir -p "$localMountPoint"
else
echo "$localMountPoint bereits vorhanden"
fi
 
if [ "$(ls -A $localMountPoint)" ]
then
echo "$localMountPoint nicht leer, kein Mounten notwendig"
else
echo "$localMountPoint leer, Mounten starten"
vorhanden="0"
while read line
do
mountComplete="//$mountIp/$mountDir $localMountPoint cifs username=$mountUser,password=$mountPass,iocharset=utf8,sec=ntlm 0 0"
echo "mountComplete: $mountComplete"
if [ `echo "$line" | grep -c "$mountComplete"` != 0 ]
then
echo "/etc/fstab: Eintrag bereits vorhanden: $mountComplete"
vorhanden="1"
break
fi
done < "/etc/fstab"
if [ "$vorhanden" != "1" ]
then
echo "/etc/fstab: Eintrag wird ergänzt: $mountComplete"
echo "$mountComplete" >> "/etc/fstab"
fi
echo "Mounts werden aktualisiert"
mount -a
sleep 3
fi
 
if [ "$(ls -A $localMountPoint)" ]
then
if [ ! -e "$localMountPoint/$mountSubDir/$localIp" ]
then
mkdir -p "$localMountPoint/$mountSubDir/$localIp"
else
echo "$localMountPoint/$mountSubDir/$localIp existiert bereits"
fi
find "$localBackupDir" -name '*fhem_backup.tar.gz' | while read file
do
fileSize="0"
fileSizeMB=$(du -h $file)
fileSizeMB=${fileSizeMB%%M*}
filename=${file##*/}
echo "$filename ($fileSizeMB MB) wird in den Backupordner verschoben"
if [[ "$pushoverToken" != "" && "pushoverUser" != "" ]]
then
curl -s -F "token=$pushoverToken" -F "user=$pushoverUser" -F "title=FHEM $localIp" -F "message=Backup mit $fileSizeMB MB wird erstellt" https://api.pushover.net/1/messages.json
fi
#mv "$file" "$localMountPoint/$mountSubDir/$localIp/$filename"
cp "$file" "$localMountPoint/$mountSubDir/$localIp/$filename"
rm "$file"
perl /opt/fhem/fhem.pl 7072 "set FHEM.Backup off"
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup backup $filename"
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup backupMB $fileSizeMB"
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup info backup done"
done
else
echo "Mounten hat anscheinend nicht geklappt, skip."
exit
fi
 
#Löschen alter Backups
if [[ "$backupsMax" != "" && "$backupsMax" != "0" ]]
then
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup backupFilesMax $backupsMax"
backupsCurrent=`ls -A "$localMountPoint/$mountSubDir/$localIp" | grep -c "_fhem_backup.tar.gz"`
backupsDelete=$(($backupsCurrent-$backupsMax))
if [ "$backupsDelete" -gt "0" ]
then
echo "$backupsCurrent Backups vorhanden - nur $backupsMax aktuelle Backups werden vorgehalten - $backupsDelete Backups werden gelöscht"
ls -d "/$localMountPoint/$mountSubDir/$localIp/"* | grep "_fhem_backup.tar.gz" | head -$backupsDelete | xargs rm
else
echo "$backupsCurrent Backups vorhanden - bis $backupsMax aktuelle Backups werden vorgehalten"
fi
else
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup backupFilesMax no limit"
fi
 
backupsCurrent=`ls -A "$localMountPoint/$mountSubDir/$localIp" | grep -c "_fhem_backup.tar.gz"`
perl /opt/fhem/fhem.pl 7072 "setreading FHEM.Backup backupFiles $backupsCurrent"
 
 
echo "Mount wieder unmounten"
umount "$localMountPoint"


' >> /opt/fhem/FHEM/backup.sh

# fhem.cfg anpassen
 sudo echo '#dummy FHEM.Backup
define FHEM.Backup dummy
attr FHEM.Backup event-on-change-reading state
attr FHEM.Backup room FHEM
attr FHEM.Backup webCmd on:off
define FHEMBackupOn notify FHEM.Backup:on {system ("sudo -u root /opt/fhem/FHEM/backup.sh &")}
 
#Automatisches Backup um 06:00 Uhr starten
define FHEMBackup at *06:00:00 set FHEM.Backup on
' >> /opt/fhemcfg


   echo "editierbar mit: http://192.168.3.97:8083/fhem?cmd=style%20edit%20backup.sh"
}

do_install_addons() {
    # Zusatzmodule z.B. Perl JSON
    sudo apt-get install -y libjson-perl
    sudo apt-get install -y samba cifs-utils
    sudo apt-get install -y sendEmail
    sudo apt-get install -y etherwake
    sudo apt-get install -y libnet-telnet-perl
    sudo apt-get install -y socat
    sudo apt-get install -y debhelper cdbs automake libtool libusb-1.0-0-dev git-core build-essential
}

do_move_fhem_cfg() {
    sudo cp fhem.cfg /opt/fhem/fhem.cfg
}


do_install_knxd() {
    # 1. lib pthsem herunterladen und installieren
    wget https://www.auto.tuwien.ac.at/~mkoegler/pth/pthsem_2.0.8.tar.gz
    tar xzf pthsem_2.0.8.tar.gz
    cd pthsem-2.0.8
    dpkg-buildpackage -b -uc
    cd ..
    sudo dpkg -i libpthsem*.deb

    # 2. knxd herunterladen und installieren
    echo "knxd herunterladen und installieren"
    git clone https://github.com/knxd/knxd.git
    cd knxd
    dpkg-buildpackage -b -uc
    cd ..
    sudo dpkg -i knxd_*.deb knxd-tools_*.deb
}
_
do_move_fhem_cfg() {
    sudo cp fhem.cfg /opt/fhem/fhem.cfg
}


do_create_image() {
    # create image
    echo "Image wird erstellt"
}


do_checkout()  {
    git clone https://github.com/marthinx/myFHEMPi.git
    chmod +x fhem_config.sh
}

do_checkin()  {
    git config --global user.name "Martin"
    git add fhem_config.sh
    read -p "Beschreibung der Anpassung: " anpassung
    git commit -m $anpassung
    git push origin master
}

do_check_arguments
do_init
# do_begruessung
do_show_menu
