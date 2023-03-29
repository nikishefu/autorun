#!/bin/bash

if [ "$#" == 0 ] || [ "$1" == "--help" ]
then
    echo "Usage: autorun [options] file"
    echo "Options:"
    echo -e "\t--help\t\tDisplay this information"
    echo -e "\t--list\t\tDisplay services"
    echo -e "\t-u username\tRun service as username"
    echo -e "\t-n name\t\tName of service"
    echo -e "\t-d\t\tDelete service"
    echo -e "\t-s\t\tStart service after creation"
    exit 0
elif [ "$1" == "--list" ]
then
    echo "`ls -l /etc/systemd/system`"
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

executable=`realpath "${@: -1}"`
if [ -x "$executable" ]
then
    echo -n "Executable "
    echo "$executable"
else
    echo "Error: No such file / file is not executable"
fi

echo "[Unit]" > "$filename"
echo "Description=$name service, created with autorun" >> "$filename"
echo -e "After=network.target\n" >> "$filename"
echo "[Service]" >> "$filename"
echo "Type=simple" >> "$filename"
echo "User=$user" >> "$filename"
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
