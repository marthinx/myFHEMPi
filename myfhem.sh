#!/bin/bash
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

echo "myfhem installer"

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
