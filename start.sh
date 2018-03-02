#!/bin/bash

# stunnel conf
stunnelPath="stunnel"
stunnelConf="/etc/stunnel/stunnel.conf"
stunnelPidPath="/var/run/stunnel.pid"

# ssh conf
certPath="/home/remote/.ssh/cert.key"
user="remote"
remotePortOpen="2201"
sshPidPath="/tmp/sshTunnel.pid"

debug=1
G="\e[32m" #green color
R="\e[39m" # reset

if [ "$debug" -eq "1" ]; then echo -e "${G}Start stunnel ...${R}"; fi
date

# check if conf file exist
if [ ! -f $stunnelConf ]; then
    echo "File not found!"
    exit 1
fi

if [ "$debug" -eq "1" ]; then echo "check config file ok"; fi

# grep ip:port in conf
filter=$(cat /etc/stunnel/stunnel.conf | grep accept | awk -F"=" '{print $2}' | tr -d ' ')

if [ "$debug" -eq "1" ]; then echo "accept $filter"; fi

# start stunnel
stunnel $tunnelConf

# wait to stunnel ...
sleep 5

stunnelPid=$(cat $stunnelPidPath)
if [ "$debug" -eq "1" ]; then echo "stunnel pid [$stunnelPid]"; fi
ps -p $stunnelPid
netstat -tanlp | grep $filter

if [ "$debug" -eq "1" ]; then echo -e "${G}start SSH ...${R}"; fi

# start remote SSH
ssh -i $certPath -R $remotePortOpen:localhost:22 -p 2222 $user@localhost -f -N

sleep 3

sshPid=$(pgrep -f "ssh.*-R")
if [ "$debug" -eq "1" ]; then echo "ssh pid [$sshPid]"; fi

echo $sshPid > $sshPidPath

ps -p $sshPid
netstat -tanlp | grep ":22"

if [ "$debug" -eq "1" ]; then echo "end ..."; fi
