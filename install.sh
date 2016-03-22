#!/bin/sh

read -p "Please enter your mis/relay account:" relay;
read -p "Please enter your mis password:" -s password;
echo ""
read -p "Please enter your all application names separated by commas in order to config all servers:" applications;
dir=`pwd -P` 
relay_config=$dir"/relay.config"
echo "relay="$relay > $relay_config 

echo "Host relay.sankuai.com
ControlPath ~/.ssh/master-%r@%h:%p
ControlMaster auto" >> ~/.ssh/config

if [ -f "dest.config" ]; then
	mv dest.config dest.config.bak
fi

echo "relay.sankuai.com" >> dest.config
echo "db24" >> dest.config
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

if [ -n "`grep 'zsh' $SHELL`" ]; then
	profile=$HOME"/.zshrc"
elif [ -n "`grep 'bash' $SHELL `" ]; then
	profile=$HOME"/.bash_profile" 
else 
	echo "Please enter \"alias mgo='sh $dir/mgo.sh'\" into your shell profile"
fi

if [ ! -f "$profile" ]; then
	echo "Fail to install Mgo... Please check your .bash_profile..."
else if [ -z "`grep 'alias mgo' $profile`" ]; then
		echo "alias mgo='sh $dir/mgo.sh'" >> $profile 
		sleep 1
		source $profile
	fi
fi

IFS="OLD_IFS"

echo "MgO is installed successfully."
