#!/bin/bash
# Basic StakePool Node Restart script after stuck_notifier is received
# Created by Straightpool (https://straightpool.github.io/about/) 
# Script version: 2.1.1

# This script assumes you have setup your pool as a systemd service
# Run script with sudo rights, to put into the background at the same time: nohup sudo ./stuck_check.sh 2>&1 &
# If you want the script to restart your node on other log keywords but stuck_notifier replace optionalsecondkeyword with the keyword you want to check for

journalctl -u <SHELLEYD>.service -n 1 -f | grep --line-buffered 'stuck_notifier\|optionalsecondkeyword' | while read LINE
do
  if [[ -n $LINE ]]; then
    NOW=$(date +"%Y-%m-%d_%H:%M:%S_%Z")  
    Uptime=`/home/<USER>/.cargo/bin/jcli rest v0 node stats get -h http://127.0.0.1:<REST_PORT>/api | grep 'uptime'`
    LastBlockHeight=`/home/<USER>/.cargo/bin/jcli rest v0 node stats get -h http://127.0.0.1:<REST_PORT>/api | grep 'lastBlockHeight'`
    echo "Restarting due to stuck_notifier with $Uptime at $LastBlockHeight at $NOW" >> /home/<USER>/logs/stuck_check.log
    systemctl stop <jormungandr.service>
    sleep 5
    systemctl start <jormungandr.service>
  fi

sleep 60
done
