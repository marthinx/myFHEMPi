#!/bin/bash

# -----------------------------------------------------------------------
# Installs myFHEM using pthsem_2.0.8 on the Raspberry Pi (Raspbian)
#
# Run from the web:
#   bash <(curl -s raw_script_url_here)
# -----------------------------------------------------------------------

do_check_arguments()
do_init()
do_begruessung()
do_show_menu()

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




#myfhem installer
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
options=("apt-get_update" "install FHEM" "timesync" "addons" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "apt-get_update")
            do_apt-get_update()
            ;;
        "install FHEM")
            do_install_fhem()
            ;;
        "timesync")
            echo "you chose choice 3"
			do_timesync()
            ;;
		"addons")
            echo "you chose choice 3"
					do_install_addons()
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
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

do_begruessung() {
	#Begrüßung
	# read -p „bitte den Namen eingeben:“ name
	# echo Hallo: $name

	# read -p "Programm A (a) oder B (b) starten? Geben Sie a oder b ein und die Eingabetaste, Abbruch mit jeder anderen Taste ...  " kommando; if [ $kommando == 'a' ]; then starte_programm_a; elif [ $kommando == 'b' ]; then starte_programm_b; else echo "Abbruch."; fi
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
	echo "knxd herunterladen und installiere
	n" 
	git clone https://github.com/knxd/knxd.git
	cd knxd
	dpkg-buildpackage -b -uc
	cd ..
	sudo dpkg -i knxd_*.deb knxd-tools_*.deb
}

do_move_fhem.cfg() {
	sudo cp fhem.cfg /opt/fhem/fhem.cfg
}

do_create_image() {
	# create image
}


