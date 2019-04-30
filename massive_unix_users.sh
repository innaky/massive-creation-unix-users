#!/bin/bash

SCRIPTNAME=$(basename $0)
VERSION="0.1.0"

function check_root () {
    if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user." 2>&1
	exit 1
    fi
}

function usage () {
    echo >&2 "$SCRIPTNAME Create unix users from a file.
    Version: $VERSION
    Usage: $SCRIPTNAME -f file"
    exit 1
}

[ $# -lt 1 ] && usage

function read_users_from_file () {
    check_root()
    while read LINE; do
	cat /etc/passwd | awk -F ":" '{ print $1 }' | grep -q $LINE
	if [ $? -eq 0 ]; then
	    echo "User already exists."
	else
	    useradd -d /home/${LINE} -m -g users -s /bin/bash $LINE
	    echo -e "$LINE\n$LINE" | passwd $LINE > /dev/null 2>&1
	fi
    done
}

case $1 in
    -f | --file)
	read_users_from_file < $2
	;;
    *)
	usage
	;;
esac
