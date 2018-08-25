#!/bin/bash

# Written by: Connor McMillan

if [ $# -lt 1 ]; then
	echo "ERROR: Not enough arguments."
	echo "${0} [target] [target] [target] [target] ..."
	echo "Example: ${0} a b c d e f g h i j k l"
	echo "Example: IMG=company_part#_version ${0} a b c d"
	echo "IMG=biotechne_103-0039_v01 by default"
	echo "IMG must be located in /home/partimag"
	exit 1
fi

if [ "x${IMG}x" = "xx" ]; then
	IMG=biotechne_103-0039_v01
fi

if [ ! -d "/home/partimag/${IMG}" ]; then
	echo "ERROR: /home/partimg/${IMG} does not exist!!"
	echo "       Did you mount the HDD onto /home/partimag containing ${IMG}?"
	exit 1
fi

echo ""
echo ""
echo "=================================================================="
echo " BE SURE /home/partimag/${IMG} IS YOUR MASTER!!"
echo "=================================================================="
echo ""
echo ""

lsblk -o name,serial
echo ""
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"


for i in "${@}"; do
	echo ""
	echo ""
	echo "=================================================================================================================================="
	echo "EXECUTING: sudo ocs-sr -batch -nogui -g auto -e1 auto -e2 -c -r -j2 -scr -p true restoredisk ${IMG} sd${i} | tee /tmp/sd${i}.txt"
	echo "=================================================================================================================================="
	echo ""
	echo ""
	sudo ocs-sr -batch -nogui -g auto -e1 auto -e2 -c -r -j2 -scr -p true restoredisk ${IMG} sd${i} | tee /tmp/sd${i}.txt
done

for i in "${@}"; do
	echo "============================================"
	echo "/dev/sd${i} completed: "
	cat /tmp/sd${i}.txt | grep "error"
	echo "============================================"
done

echo ""
echo ""
echo "==========================================="
echo " LOGS OF IMAGED DRIVES ARE LOCATED IN /tmp"
echo "==========================================="
echo ""

