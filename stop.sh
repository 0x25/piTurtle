#!/bin/bash

stunnelPidPath="/var/run/stunnel.pid"
sshPidPath="/tmp/sshTunnel.pid"

date

# get ssh pid
sshPid=$(cat $sshPidPath)
echo "pid ssh [$sshPid]"

# kill ssh pid
kill -9 $sshPid &>/dev/null

# wait ...
sleep 2
ps -p $sshPid &>/dev/null

if [ $? -eq 1 ]; then
        echo "no ssh pid"
fi

# get stunnel pid
stunnelPid=$(cat $stunnelPidPath)

echo "tunnel pid [$stunnelPid]"

# kill stunnel pid
kill -9 $stunnelPid &>/dev/null

# wait ...
sleep 2
ps -p $stunnelPid &>/dev/null
if [ $? -eq 1 ]; then
        echo "no more stunnel pid"
fi
