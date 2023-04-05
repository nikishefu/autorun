#!/bin/bash
VERSION="0.5.1"
RED="\e[0;31m"
GREEN="\e[0;32m"
CYAN="\e[0;36m"
ENDCOLOR="\e[0m"
customListPath="/etc/autorun/services.list"

if [ "$#" == 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ] ; then
    echo -e "autorun is a script to manage systemd services\n"
    echo -e "Usage: autorun [options] \"executable\""
    echo    "Options:"
    echo -e "\t--help\t\tDisplay this information"
    echo -e "\t-v\t\tDisplay version information"
    echo -e "\t-l\t\tDisplay all system services"
    echo -e "\t-L\t\tDisplay services created with autorun"
    echo -e "\t-i\t\tPrint name.service info"
    echo -e "\t-s\t\tPrint name.service status"
    echo -e "\t-u username\tRun service as username"
    echo -e "\t-n name\t\tName of service"
    echo -e "\t-d\t\tDelete service"
    echo -e "\t-r\t\tRun service"
    echo    "Note:"
    echo -e "\t- Some operations require superuser privilege"
    echo -e "\t- Executable can be either a file or a command"
    echo -e "\t- If executable contains spaces, surround this parameter by \""
    exit 0
fi

while getopts "n:u:dsrivlL" opt ; do
case "$opt" in
    n ) name="$OPTARG"    ;;
    u ) user="$OPTARG"    ;;
    d ) delete=true       ;;
    s ) printStatus=true  ;;
    i ) printInfo=true    ;;
    r ) startService=true ;;
    l ) listServices=true ;;
    L ) listCustom=true   ;;
    v ) printVersion=true ;;
esac
done


# Nameless options
if [ "$printVersion" = true ] ; then
    echo "autorun version $VERSION"
    exit 0
elif [ "$listServices" = true ] ; then
    echo -e "All system services (${RED}●$ENDCOLOR not running / ${GREEN}●$ENDCOLOR running):"
    
    while read line
    do
	if [ -z "`systemctl status $line | sed -n '3p' | grep running`" ] ; then
	    line="$RED●$ENDCOLOR $line"
	else
	    line="$GREEN●$ENDCOLOR $line"
	fi
	echo -e "\t$line"
    done <<< "`ls /etc/systemd/system | grep .service$`"

    # echo "`ls /etc/systemd/system | grep .service$ | sed 's/^/	/'`"
    exit 0
elif [ "$listCustom" = true ] ; then
    if [ -z "`cat $customListPath`" ] ; then
	echo "No services created with autorun"
	echo "Use 'autorun -l' to see all system services"
	exit 0
    fi
    echo -e "Services created with autorun (${RED}●$ENDCOLOR not running / ${GREEN}●$ENDCOLOR running):"

    while read line
    do
	if [ -z "`systemctl status $line | sed -n '3p' | grep running`" ] ; then
	    line="$RED●$ENDCOLOR $line"
	else
	    line="$GREEN●$ENDCOLOR $line"
	fi
	echo -e "\t$line.service"
    done < $customListPath

    # echo "`sed 's/^/	/; s/$/.service/' $customListPath`"
    exit 0
fi

# The rest of the options require name
if [ -z "$name" ]
then
    echo -e "${RED}Error:$ENDCOLOR Specify a name of a service" 1>&2
    exit 1
fi
filename="/etc/systemd/system/$name.service"

# Extra options
if [ "$printStatus" = true ] ; then
    echo -e "`systemctl status $name.service`"
    exit 0
elif [ "$printInfo" = true ] ; then
    echo "`cat $filename`"
    exit 0
fi

if [ "$EUID" -ne 0 ] ; then
    echo -e "${RED}Error:$ENDCOLOR this operation requires superuser privilege" 1>&2
    exit 1
fi

if [ "$delete" = true ] ; then
    if [ -e "$filename" ] ; then
	echo -n `systemctl stop $name.service`
	echo -n `systemctl disable $name.service`
	echo -n `rm $filename`
	echo "Service $name was deleted"

	# Delete entry in list of custom files
	`sed -i "/^$name$/d" $customListPath`
	exit 0
    else
	echo -e "${RED}Error:$ENDCOLOR Service $name doesn't exist" 1>&2
	exit 1
    fi
fi

# From here: main option - service creation
if id -u "$user" >/dev/null 2>&1 || [ -z "$user" ] ; then
  echo "Creating a service"
else
  echo -e "${RED}Error:$ENDCOLOR User '$user' does not exist"
  exit 1
fi


if [ -e "$filename" ]
then
    if [ "$startService" = true ] ; then
	echo "Starting $name.service"
	echo -n `systemctl start $name.service`
	exit 0
    fi
    echo -e "${RED}Error:$ENDCOLOR $name.service already exists" 1>&2
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
	    path=`realpath ${array[index]}`
	    if [ ! -z $path ] && [ -e $path ]; then
		executable="$executable $path"
	    else
		executable="$executable ${array[index]}"
	    fi
	fi
    done
elif [ ! -x "$executable" ] ; then
    echo -e "${RED}Error:$ENDCOLOR No such file / file is not executable" 1>&2
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

`systemctl enable $name.service`
echo "Service $filename created"
if [ "$startService" = true ] ; then
    `systemctl start $name.service`
    echo "Service $filename started"
fi

# Add name to the list of services, created with autorun
echo "$name" >> "$customListPath"
