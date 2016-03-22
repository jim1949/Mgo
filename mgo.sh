#!/bin/bash

usage() {
	echo
  	echo "Usage: mgo.sh [-r] [-d] [-h]"
  	echo
  	echo "-r - Get your depolyment server by the name of application."
  	echo "-d - Go to the depolyment server directly by the number of server list."
  	echo "-h - This help text."
  	echo
}

load_relay() {
	while read line
	do
		eval $line
	done < $1/relay.config
}

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


path=`dirname $0`
load_relay $path
load_dest $path "dest"
host=$relay@relay.sankuai.com
PS3="MgO is short for Meituan Go... =====> "

while getopts "r:d:h" arg
do
	case $arg in
		r)
			load_dest $path $OPTARG
			;;
		d)
			n=`echo $OPTARG | grep "[^0-9]"`
			if [ -n "$n" ]; then
				echo "Please enter a number as param..."
				exit 1
			fi
			if [[ "(($OPTARG-1))" -ge "${#dest[*]}" ]]; then
				echo "Please enter a number which is in the range of destation array as param..."
                                exit 1
                        fi
			direct=`echo ${dest[(($OPTARG-1))]} | sed 's/\[.*\]//g'`
			if [[ "$direct" == "relay.sankuai.com" ]]; then
				ssh $host
			else
				ssh -t $host ssh $direct
			fi
			exit 0
			;;
		h)
			usage
			exit 0
			;;
		?)
			echo "ERROR: Unknow option..."
			usage
			exit 1
			;;
	esac
done

select selected in ${dest[@]};
do
	d=`echo ${selected} | sed 's/\[.*\]//g'`
	echo "\033[32mlogin to ${selected}\033[0m"
        case $d in
		relay.sankuai.com)
			ssh $host
			break
			;;
		$d) 
			ssh -t $host ssh $d
			break
			;;
		*) 	echo "There is someting wrong with your enter."
			;;
        esac
done
