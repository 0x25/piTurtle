#!/bin/bash

# check if ssh pid is up and running / and restart if not

scriptPath="/opt/remoteShell/"
sshPidPath="/tmp/sshTunnel.pid"
tunnelPidPath="/var/run/stunnel.pid"
psFilter="ssh -i /home/remote/.ssh/cert.key -R 2201:localhost:22 -p 2222 remote@localhost -f -N "

date
sshPid=$(cat $sshPidPath)

# no pid in file
if [ -z "$sshPid" ]; then
        echo "no sshPid ! - restart ..."
        echo "stop"
        ${scriptPath}stop.sh
        sleep 5
        echo "start"
        ${scriptPath}start.sh
        exit 1
fi

ps=$(ps $sshPid)
res=$?

# if ps exist
if [ "$res" -eq "0" ]; then

        #OK PID exist
        #echo "pid exist $sshPid [$ps]"
        psName=$(echo $ps | awk -F" " '{ s = ""; for (i = 10; i <= NF; i++) s = s $i " "; print s }')
        #echo "[$psFilter] [$psName]"

        # Burp ..... :D
        if [[ "$psName" == "$psFilter" ]]; then
                # OK nothing to do
                echo "pid and name ok"

                # check if tunnel work !
                ssh -i /home/remote/.ssh/cert.key -q -p 2222 remote@127.0.0.1 exit
                if [ "$?" -eq "0" ]; then

                        echo "tunnel OK"
                        exit 0
                else
                        echo "tunnel fail stop ..."
                        ${scriptPath}stop.sh
                        echo "start"
                        ${scriptPath}start.sh
                        exit 3

                fi


        else
                # KO pid exist but is not the right process
                echo "pid exist but no right name..."
                echo "stop"
                ${scriptPath}stop.sh
                echo "start"
                ${scriptPath}start.sh
                exit 2
        fi
else

        # no process !
        echo "no process - restart ..."
        echo "start"
        ${scriptPath}start.sh
        echo "stop"
        ${scriptPath}start.sh
        exit 1
fi
