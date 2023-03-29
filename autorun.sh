#!/bin/bash

if [ "$#" == 0 ] || [ "$1" == "--help" ] ; then
    echo "Usage: [sudo] autorun [options] executable"
    echo "Options:"
    echo -e "\t--help\t\tDisplay this information"
    echo -e "\t--list\t\tDisplay services"
    echo -e "\t--info name\tPrint name.service info"
    echo -e "\t-u username\tRun service as username"
    echo -e "\t-n name\t\tName of service (required)"
    echo -e "\t-d\t\tDelete service"
    echo -e "\t-s\t\tStart service after creation"
    echo "Note: use this script with sudo"
    exit 0
elif [ "$1" == "--list" ] ; then
    echo "`ls /etc/systemd/system | grep .service$`"
    exit 0
elif [ "$1" == "--info" ] ; then
    if [ "$#" == 1 ] ; then
	echo "Specify a name of a service"
	exit 1
    fi
    echo "`cat /etc/systemd/system/$2.service`"
    exit 0
fi

while getopts "n:u:ds" opt
do
   case "$opt" in
      n ) name="$OPTARG"    ;;
      u ) user="$OPTARG"    ;;
      d ) delete=true       ;;
      s ) startService=true ;;
   esac
done

if [ -z "$name" ]
then
    echo "Specify a name of a service"
    exit 1
fi

filename="/etc/systemd/system/$name.service"
if [ -e "$filename" ]
then
    if [ "$delete" = true ] ; then
        echo -n `systemctl stop $name.service`
        echo -n `systemctl disable $name.service`
        echo -n `rm $filename`
        echo "Service $filename was deleted"
        exit 0
    fi
    echo "$name.service already exists"
    exit 1
fi

executable="${@: -1}"

IFS=' ' read -r -a array <<< "$executable"
if [ ! -z `which ${array[0]}` ] ; then
    for index in "${!array[@]}"
    do
	if [ "$index" == 0 ] ; then
	    executable="`which ${array[0]}`"
	else
	    if [ ! -z `realpath ${array[index]}` ] ; then
		executable="$executable `realpath ${array[index]}`"
	    else
		executable="$executable ${array[index]}"
	    fi
	fi
    done
elif [ ! -x "$executable" ] ; then
    echo "Error: No such file / file is not executable"
    exit 1
fi

echo "Executable: $executable"

echo "[Unit]" > "$filename"
echo "Description=$name service, created with autorun" >> "$filename"
echo -e "After=network.target\n" >> "$filename"
echo "[Service]" >> "$filename"
echo "Type=simple" >> "$filename"

if [ ! -z "$user" ] ; then
    echo "User=$user" >> "$filename"
fi

echo "Restart=on-failure" >> "$filename"
echo "RestartSec=1" >> "$filename"
echo "StartLimitBurst=5" >> "$filename"
echo "StartLimitIntervalSec=10" >> "$filename"
echo -e "ExecStart=$executable\n" >> "$filename"
echo "[Install]" >> "$filename"
echo "WantedBy=multi-user.target" >> "$filename"

echo `systemctl enable $name.service`
if [ "$start" = true ] ; then
    echo `systemctl start $name.service`
fi
echo "Service $filename created"
