#!/bin/bash

# Written by: Connor McMillan

if [ $# -lt 1 ]; then
	echo "ERROR: Not enough arguments."
	echo "${0} [target] [target] [target] [target] ..."
	echo "Example: ${0} a b c d e f g h i j k l"
	echo "Example: IMG=company_part#_version ${0} a b c d"
	echo "IMG=fluorchem-mfg-master-2017-11-27 by default"
	echo "IMG must be located in /home/partimag"
	exit 1
fi

if [ "x${IMG}x" = "xx" ]; then
	IMG=fluorchem-mfg-master-2017-11-27
fi

if [ "$(mount | grep '/home/partimag')" == "" ]; then
	HDD=$(lsblk -o name,serial | grep 575857 | cut -d' ' -f1)
	if [ -b /dev/${HDD}1 ]; then
		sudo mount /dev/${HDD}1 /home/partimag
	fi
fi

if [ ! -d "/home/partimag/${IMG}" ]; then
	echo "ERROR: /home/partimg/${IMG} does not exist!!"
	exit 1
fi

echo ""
echo ""
echo "=================================================================="
echo " BE SURE /home/partimag/${IMG} IS YOUR MASTER!!"
echo "=================================================================="
echo ""
echo ""

echo ""
echo ""
echo "=================================================================="
echo " THE FOLLOWING DRIVES WILL BE IMAGED!!"
echo "=================================================================="
echo ""
echo ""

for i in "${@}:2"; do
	lsblk -o name,serial | grep sd${i}

done

echo ""
echo ""
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"


for i in "${@}"; do
	echo ""
	echo ""
	echo "=================================================================================================================================="
	echo "EXECUTING: pv /home/partimag/${IMG} > /dev/sd${i} && sudo xxhsum /dev/sd${i} &>> /tmp/xxhsum.log &"
	echo "=================================================================================================================================="
	echo ""
	echo ""
	sudo pv /home/partimag/${IMG} > /dev/sd${i} && sudo xxhsum /dev/sd${i} &>> /tmp/xxhsum.log &
done

echo ""
echo ""
echo "=================================================================="
echo " ${IMG} has a sum of ade06eeaf7bcad46"
echo " LOGS OF IMAGED DRIVES ARE LOCATED IN /tmp/xxhsum.log"
echo "=================================================================="
echo ""
echo ""
echo "Press Ctrl+C to exit"
read -p "Press Enter to view /tmp/xxhsum.log"
less /tmp/xxhsum.log
