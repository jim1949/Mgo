#!/bin/sh

read -p "Please enter your mis/relay account:" relay;
read -p "Please enter your mis password:" -s password;
echo ""
read -p "Please enter your applications' names separated by commas in order to config all servers that you want to add:" applications;

OLD_IFS="$IFS"
IFS=","
apparr=($applications)
for application in ${apparr[@]}
do
        sleep 2
        servers=`curl -s http://ops.sankuai.com/releng/app_to_hosts?app=$application -u $relay:$password | sed 's/.*\[//g' | sed 's/\]}//g' | sed 's/"//g' | sed 's/ //g'`
        serverarr=($servers)
        for server in ${serverarr[@]}
        do
                echo $server >> dest.config
                echo $server >> $application.config
        done
done
IFS="$OLD_IFS"

echo "Your server list is updated successfully."
