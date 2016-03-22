#!/bin/sh

load_dest() {
        if [ ! -f "$1/$2.config" ]; then
                echo "Please check your $1/$2.config..."
                exit 1
        fi
        unset dest
        k=0;
        while read line
        do
                dest[k++]=$line
        done < $1/$2.config
}

unset apparr
uniquify_app() {
	flag=true
	for appname in ${apparr[@]}
	do
		if [[ "$appname" == "$1" ]]; then
			flag=false
		fi
	done
	if [ "$flag" = true ]; then 
		length=${#apparr[*]}
		apparr[length]=$1
	fi
}
path=`dirname $0`
load_dest $path "dest"

read -p "Please enter your mis/relay account:" relay;
read -p "Please enter your mis password:" -s password;
echo ""

for server in ${dest[@]}
do
	if [[ "$server" == "relay.sankuai.com" || "$server" == "db24" ]]; then
		echo "vvvvvvvvvv"
		continue
        fi
        sleep 2
	servername=`echo ${server} | sed 's/\[.*\]//g'`
	echo $servername
        app=`curl -s http://ops.sankuai.com/releng/host_to_apps?host=$servername -u $relay:$password | sed 's/.*\[//g' | sed 's/\]}//g' | sed 's/"//g' | sed 's/ //g'| sed 's/,.*$//g'`
	echo $app
	uniquify_app $app
	echo ${apparr[@]}
done

OLD_IFS="$IFS"
IFS=","
cat /dev/null > dest.config
echo "relay.sankuai.com" >> dest.config
echo "db24" >> dest.config
for application in ${apparr[@]}
do
        sleep 2
	echo "" > $application.config
        servers=`curl -s http://ops.sankuai.com/releng/app_to_hosts?app=$application -u $relay:$password | sed 's/.*\[//g' | sed 's/\]}//g' | sed 's/"//g' | sed 's/ //g'`
        serverarr=($servers)
        for server in ${serverarr[@]}
        do
                echo $server >> dest.config
                echo $server >> $application.config
        done
done
IFS="$OLD_IFS"
