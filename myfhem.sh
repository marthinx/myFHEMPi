#!/bin/bash

# -----------------------------------------------------------------------
# Installs myFHEM using pthsem_2.0.8 on the Raspberry Pi (Raspbian)
#
# Run from the web:
#   bash <(curl -s raw_script_url_here)
# -----------------------------------------------------------------------

# Set up variables
bold="\033[1m"
normal="\033[0m"

# Welcome message
echo -e "\n${bold}This will install myFHEM using pthsem_2.0.8."
echo -e "It can take about 20 minutes to compile on the Raspberry Pi.${normal}"

# Prompt to continue
read -p "  Continue? (y/n) " ans
if [[ $ans != "y" ]]; then
  echo -e "\nQuitting...\n"
  exit
fi
echo

# Time the install process
START_TIME=$SECONDS


















#myfhem installer









while [ "$1" != '' ]
  do
    [ $1 == "-b" ] && BACKUP="yes" && echo "Ok. Do a backup!" && shift
    [ $1 == "-r" ] && RESTORE="yes" && echo "Ok. Do a restore!" && shift
    [ $1 == "-c" ] && CLEAN="yes" && echo "Ok. Tidy up!" && shift
done

#!/bin/bash
# Ja oder Nein

dialog --yesno "Bist du ein FHEM Fan?" 15 60

# fhem installieren
sudo apt-get update && apt-get -y upgrade
sudo apt-get install apt-transport-https
sudo apt-get install -f
echo "myfhem installer"

sudo wget -qO - https://debian.fhem.de/archive.key | apt-key add -
sudo deb https://debian.fhem.de/stable ./ sudo apt-get update
sudo apt-get install -y fhem

# Zeitserver
sudo apt-get install -y ntpdate
sudo ntpdate -u de.pool.ntp.org

# Zusatzmodule z.B. Perl JSON
sudo apt-get install -y libjson-perl
sudo apt-get install -y samba cifs-utils
sudo apt-get install -y sendEmail
sudo apt-get install -y etherwake
sudo apt-get install -y libnet-telnet-perl
sudo apt-get install -y socat

#Begrüßung
# read -p „bitte den Namen eingeben:“ name
# echo Hallo: $name

# read -p "Programm A (a) oder B (b) starten? Geben Sie a oder b ein und die Eingabetaste, Abbruch mit jeder anderen Taste ...  " kommando; if [ $kommando == 'a' ]; then starte_programm_a; elif [ $kommando == 'b' ]; then starte_programm_b; else echo "Abbruch."; fi


sudo apt-get update
sudo apt-get install -y debhelper cdbs automake libtool libusb-1.0-0-dev git-core build-essential

# 2. lib pthsem herunterladen und installieren
wget https://www.auto.tuwien.ac.at/~mkoegler/pth/pthsem_2.0.8.tar.gz
tar xzf pthsem_2.0.8.tar.gz
cd pthsem-2.0.8
dpkg-buildpackage -b -uc
cd ..
sudo dpkg -i libpthsem*.deb

# 3. knxd herunterladen und installieren
echo "knxd herunterladen und installiere

n" 
git clone https://github.com/knxd/knxd.git
cd knxd
dpkg-buildpackage -b -uc
cd ..
sudo dpkg -i knxd_*.deb knxd-tools_*.deb

sudo cp fhem.cfg /opt/fhem/fhem.cfg
