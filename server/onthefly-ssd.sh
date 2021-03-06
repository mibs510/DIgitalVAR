#!/bin/bash


# Written by: Connor McMillan

if [ $# -lt 2 ]; then
	echo "ERROR: Not enough arguments."
	echo "${0} [master/from] [target] [target] [target] [target] ..."
	echo "Example: ${0} a b c d e f g h i j k l"
	echo "Example: ${0} f a b c d e g h i j k l"
	exit 1
fi

# Check to see if partimag is connected
if [ "${PARTIMAG}" != "" ]; then
	echo "${RED}ERROR: Remove or disconnect partimag SSD/HDD!${NC}"
	exit 1
fi

# Check to see if CLONER USB is connected
if [ "${CLONER}" != "" ]; then
	echo "${RED}ERROR: Remove or disconnect CLONER USB!${NC}"
	exit 1
fi

if [ ! -b /dev/sd${1} ]; then
	echo ""
	echo ""
	echo "ERROR: /dev/sd${1} DOES NOT EXIST!"
	echo ""
	echo ""
fi

echo ""
echo ""
echo "======================================="
echo " BE SURE /dev/sd${1} IS YOUR MASTER!!"
echo "======================================="
echo ""
echo ""

lsblk -o name,serial
echo ""
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"

for i in "${@:2}"; do
	echo ""
	echo ""
	echo "========================================================================================================================================================"
	echo "EXECUTING: sudo ocs-onthefly -fsck-src-part-y -batch -nogui -pa command -g auto -e1 auto -e2 -r -j2 -f sd${1} -t sd${i} | tee /tmp/sd${i}.txt"
	echo "========================================================================================================================================================"
	echo ""
	echo ""
	sudo ocs-onthefly -fsck-src-part-y -batch -nogui -pa command -g auto -e1 auto -e2 -r -j2 -f sd${1} -t sd${i} | tee /tmp/sd${i}.txt
done

for i in "${@:2}"; do
	echo "============================================"
	echo "/dev/sd${i} completed: "
	cat /tmp/sd${i}.txt | grep "error"
done | less

echo ""
echo ""
echo "==========================================="
echo " LOGS OF IMAGED DRIVES ARE LOCATED IN /tmp"
echo "==========================================="
echo ""
