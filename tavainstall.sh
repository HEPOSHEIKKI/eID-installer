#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
for i in "$@"; do
  case $i in
    -h|--help)
      echo "This is a script that automates removing firefox snap and installing firefox from Mozilla's own image."
      echo "Why? The snap version of firefox breaks support for the eID ID card reader used in Estonia"
      echo ""
      printf "${RED}Args:${NC}\n"
      echo "-a (--abi): 				Prints out this help-page in Estonian"
      echo "-h (--help):				Prints out this help-page"
      exit 1
      ;;
    -a|--abi)
			echo "See skript automatiseerib firefoxi snapi desinstallimise ja firefoxi installimise Mozilla omast pakendist"
			echo "Miks? Firefoxi snapi versioon ei toeta eID tuvastamist ID-kaardilugejaga."
			echo ""
			printf "${RED}Argumentid:${NC}\n"
			echo "-a (--abi): 				Printib välja selle abiteksti"
			echo "-h (--help): 				Printib välja selle abiteksti inglise keeles"
			exit 1
			;;
		-e|--english)
			english=YES
			shift
			;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done
if [[ $english = YES ]]; then
	if [ "$EUID" -ne 0 ]
	  then echo "Please run the script as root (sudo ./tavainstall.sh)"
	  exit
	fi
	USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
	echo "Firefox snap will now be uninstalled, is that okay?"
	echo "Please type YES or NO"
	read consent
	if [ $consent != "YES" ]; then
		echo "Script halted, uninstalling firefox was not permitted."
		exit
	fi
	echo "Removing firefox"
	sudo snap remove firefox
	mkdir ./tulerebane
	cd ./tulerebane
	echo "Downloading firefox version-103"
	echo "Please wait"
	sleep 2s
	wget "$(curl -ls "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64" | grep -oP '"(.*?)"' | sed 's/"//g')" -nv --show-progress
	sleep 2s
	echo "Extracting the firefox archive"
	echo "Please wait"
	sudo tar -xf firefox-*.tar.bz2
	rm firefox-103.0.2.tar.bz2
	echo "Finishing up"
	echo "Please wait"
	sudo mv firefox /opt
	sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
	wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications
	wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P $USER_HOME/Desktop/
	#sudo chown $USER_HOME/Desktop/firefox.desktop $SUDO_USER:$SUDO_USER
	sudo chmod +x $USER_HOME/Desktop/firefox.desktop
	echo "Firefox is generating the user configuration, please wait"
	timeout 4s su $SUDO_USER -c "firefox"
	echo "Firefox is now installed"
	echo "Do you wish to install the eID extension for firefox?"
	echo "YES/NO:"
	read consent
	if [ $consent = "YES" ]; then
		USER="$(ls $USER_HOME/.mozilla/firefox/ | grep -v ".default-release-1" | grep default-release)"
		sudo touch $USER_HOME/.mozilla/firefox/$USER/user.js
		sudo echo "user_pref(\"extensions.autoDisableScopes\", 0);" >> $USER_HOME/.mozilla/firefox/$USER/user.js
		sudo mkdir $USER_HOME/.mozilla/firefox/$USER/extensions
		wget https://addons.mozilla.org/firefox/downloads/file/3963431/web_eid_webextension-2.2.1.xpi -O $USER_HOME/.mozilla/firefox/$USER/extensions/{e68418bc-f2b0-4459-a9ea-3e72b6751b07}.xpi
		wget https://addons.mozilla.org/firefox/downloads/file/3439907/pkcs11_module_loader-1.0.5.xpi -O $USER_HOME/.mozilla/firefox/$USER/extensions/{02274e0c-d135-45f0-8a9c-32b35110e10d}.xpi
		echo "eID installed"
	fi
	echo "Good bye!"
	exit
else
		if [ "$EUID" -ne 0 ]
	  then echo "palun jooksuta skript SUDOna (sudo ./tavainstall.sh)"
	  exit
	fi
	USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
	echo "Kas lubad firefoxi SNAPi versiooni desinstallimise?"
	echo "Palun kirjuta 'JAH', või 'EI'"
	read consent
	if [ $consent != "JAH" ]; then
		echo "Skript peatatud, firefoxi desinstallimist ei lubatud."
		exit
	fi
	echo "Kustutan firefoxi"
	sudo snap remove firefox
	mkdir ./tulerebane
	cd ./tulerebane
	echo "Laetagse alla firefoxi versioon-103"
	echo "Palun oota"
	sleep 2s
	wget "$(curl -ls "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64" | grep -oP '"(.*?)"' | sed 's/"//g')" -nv --show-progress

	sleep 2s
	echo "Pakin firefoxi arhhiivi lahti"
	echo "Palun oota"
	sudo tar -xf firefox-*.tar.bz2
	rm firefox-103.0.2.tar.bz2
	echo "Viimistlen firefoxi installatsiooni"
	echo "Palun oota"
	sudo mv firefox /opt
	sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
	wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications
	wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P $USER_HOME/Desktop/
	#sudo chown $USER_HOME/Desktop/firefox.desktop $SUDO_USER:$SUDO_USER
	chmod +x $USER_HOME/Desktop/firefox.desktop
	echo "Firefox genereerib kasutajakonfiguratsiooni, palun oota"
	timeout 4s su $SUDO_USER -c "firefox"
	echo "Firefox on nüüd installitud"
	echo "Kas soovite ka eID plugini installida?"
	echo "JAH/EI:"
	read consent
	if [ $consent = "JAH" ]; then
		USER="$(ls $USER_HOME/.mozilla/firefox/ | grep -v ".default-release-1" | grep default-release)"
		sudo touch $USER_HOME/.mozilla/firefox/$USER/user.js
		sudo echo "user_pref(\"extensions.autoDisableScopes\", 0);" >> $USER_HOME/.mozilla/firefox/$USER/user.js
		sudo mkdir $USER_HOME/.mozilla/firefox/$USER/extensions
		wget https://addons.mozilla.org/firefox/downloads/file/3963431/web_eid_webextension-2.2.1.xpi -O $USER_HOME/.mozilla/firefox/$USER/extensions/{e68418bc-f2b0-4459-a9ea-3e72b6751b07}.xpi
		wget https://addons.mozilla.org/firefox/downloads/file/3439907/pkcs11_module_loader-1.0.5.xpi -O $USER_HOME/.mozilla/firefox/$USER/extensions/{02274e0c-d135-45f0-8a9c-32b35110e10d}.xpi
		echo "eID installed"
	fi
	echo "Head aega!"
	exit
fi
