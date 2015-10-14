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
    options=("apt-get_update" "install FHEM" "timesync" "addons" "feste IP" "Tastaturlayout" "Stromzaehler" "Gaszaehler" "Homebridge" "EnOcean" "Scipt_Automatik" "smartVISU" "checkin" "checkout" "install_myFHEM" "Quit")
    select opt in "${options[@]}"
    do
    case $opt in
        "apt-get_update")
            do_apt-get_update
            ;;
        "install FHEM")
            do_install_fhem
            ;;
        "timesync")
            echo "you chose timesync"
            do_timesync
            ;;
        "addons")
            echo "you chose addons"
            do_install_addons
            ;;
        "feste IP")
            echo "you chose feste IP"
            do_setIP
            ;;
        "Tastaturlayout")
            echo "you chose do_internationalisation_menu"
            do_internationalisation_menu
            ;;
        "Stromzaehler")
            echo "you chose Stromzaehler"
            do_installStromzahler
            ;;
        "Gaszaehler")
            echo "you chose Gaszaehler"
            do_installGaszahler
            echo "define GasverbrauchStdNoti notify Gasverbrauch {"
            echo "my $GasUmlaufzeit=ReadingsVal("Gasverbrauch","pauseTimeEdge","0")+ReadingsVal("Gasverbrauch","pulseTimeEdge","0"); "
            echo "my $GasProStd=36/$GasUmlaufzeit; ";
            echo "my $GasProStdRounded=int(100 * $GasProStd + 0.5) / 100; "

            echo "fhem("set GasverbrauchStd $GasProStdRounded");; "
            echo "fhem("delete tmp_time_gas");; "
            echo "fhem("define tmp_time_gas at +00:02:00 set GasverbrauchStd 0");; "
            echo "}"
            ;;
        "Homebridge")
            echo "you chose Homebridge"
            do_installHomebridger
            ;;
        
        "EnOcean")
            echo "you chose EnOcean"
            do_installEnOcean
            ;;
        
        "Scipt_Automatik")
            echo "define Gast_Automatik dummy"
            echo "attr Gast_Automatik devStateIcon ja:general_an_fuer_zeit nein:general_aus_fuer_zeit"
            echo "attr Gast_Automatik eventMap ja nein"
            echo "attr Gast_Automatik webCmd ja:nein"

            echo "define Gast_Jal_auf at *{sunrise(0,"05:00","08:00")} {"
            echo "my $OG = Value("Gast_Automatik");;"
            echo "if ( $OG eq "ja" )"
 	            echo "{fhem ("set Gast_Jal on")}"
            echo "}"
            ;;
        
        "smartVISU")
            echo "you chose smartVISU"
            do_install_smartVISU
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
    echo "http://www.elektronik-kompendium.de/sites/raspberry-pi/1912151.htm"
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

do_installStromzahler() {
    # in FHEM.cfg: define Stromzaehler SMLUSB /dev/ttyAMA0@9600
    cat /dev/ttyUSB0
}

do_installGaszahler() {
    # in FHEM.cfg: define Stromzaehler SMLUSB /dev/ttyAMA0@9600
    cat /dev/ttyUSB0
}

do_installHomebridge() {
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install build-essential libssl-dev
        
    # aus package.json entfernt werden: 
    # "harmonyhubjs-client": "^1.1.4",
    # "harmonyhubjs-discover": "git+https://github.com/swissmanu/harmonyhubjs-discover.git"
            
    # Python, g++, MDNS installieren
    sudo apt-get install python
    sudo apt-get install g++
    sudo apt-get install libavahi-compat-libdnssd-dev
            
    #homebridge installieren
    git clone https://github.com/nfarina/homebridge.git
    cd homebridge
    npm install
            
    # homebridge konfigurieren
    #nano config.json
            
    # homebridge starten
    npm run start
            
    echo "nun IOS einrichten "
}

do_installEnOcean() {
    echo "define TCM_ESP3_0 TCM ESP3 /dev/ttyAMA0@57600"       
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


do_install_smartVISU() {
    # create image
    echo "smartVISU wird installiert"
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
