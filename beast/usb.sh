#!/bin/bash

PARTIMAG=$(lsblk -o name,serial | grep S5VWNG0 | cut -d' ' -f1)
USB_LIST=""
RED=`tput setaf 1`
GREEN=`tput setaf 2`
CYAN=`tput setaf 14`
NC=`tput sgr0`

# Check to see if patriot USB is connected
if [ "${PARTIMAG}" == "" ]; then
	echo "${RED}ERROR: SAMSUNG SSD is not connected to beast!${NC}"
	exit 1
fi

# Check to see if Western Digital Elements HDD is connected
if [ "$(lsblk -o name,serial | grep 575857 | cut -d' ' -f1)" != "" ]; then
	echo "${RED}ERROR: WD Elements drive is connected!${NC}"
	exit 1
fi

# Check to see if CLONER USB is connected
if [ "$(lsblk -o name,serial | grep 07013A | cut -d' ' -f1)" != "" ]; then
	echo "${RED}ERROR: CLONER USB is connected!${NC}"
	exit 1
fi

# Mount "partimag" from  SAMSUNG SSD onto /home/partimag
if [ "$(df -P /home/partimag | tail -1 | cut -d' ' -f1)" != "/dev/${PARTIMAG}1" ]; then
	echo "Mounting /dev/${PARTIMAG}1 onto /home/partimag"
	sudo mount /dev/${PARTIMAG}1 /home/partimag
fi

# Grab a potential list of "images" by excluding files
ls -l /home/partimag | grep ^d | awk '{print $9}' > /tmp/list_of_images.txt

# Exit if no director(y/ies) found
if [ "$(ls -hal /tmp/list_of_images.txt | awk '{print $5}')" == "0" ]; then
	echo "${RED}ERROR: NO IMAGES AVAILABLE IN /home/partimag!${NC}"
	exit 1
fi

# Put list of valid clonezilla images into an array
i=0
while read line
do
	# Not all folders contain clonezilla images
	if [ -f "/home/partimag/${line}/Info-dmi.txt" ]; then
		AVAILABLE_IMGS[$i]="$line"
		i=$((i+1))
	fi
done < /tmp/list_of_images.txt

TOTAL_AVAILABLE_IMGS=$(expr ${i} - 1)
i=0

# List valid images
echo "================================================"
echo " Choose an image available from the list below: "
echo "================================================"
echo ""
for i in $(seq 0 ${TOTAL_AVAILABLE_IMGS}); do 
	echo "${i} = ${AVAILABLE_IMGS[$i]}"
done
echo ""
read -p "Enter the image #> " number
echo ""

if [ ${number} -lt 0 ] || [ ${number} -gt ${TOTAL_AVAILABLE_IMGS} ]; then
	echo "${RED}ERROR: Invalid image number!${NC}"
	exit 1
fi

CLONEZILLA_IMAGE=${AVAILABLE_IMGS[${number}]}

if [ ! -d /home/partimag/${CLONEZILLA_IMAGE} ]; then
	echo "${RED}ERROR: Image not found in /home/partimag!${NC}"
	exit 1
fi

# Look for all available drives to image. This only excludes  partimag, so be careful!
for i in {a..z}; do
	if [ -b /dev/sd${i} ] && [ "sd${i}" != "${PARTIMAG}" ]; then
		USB_LIST=$USB_LIST"sd$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done

for i in {a..z}; do
	if [ -b /dev/sda${i} ] && [ "sdaa${i}" != "${PARTIMAG}" ]; then
		USB_LIST=$USB_LIST"sda$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done


if [ "${USB_LIST}" == "" ]; then
	echo "${RED}ERROR: No USB drives found to image?${NC}"
	exit 1
fi

echo "I will image the following drives: $USB_LIST"
echo "${RED}MAKE SURE NO OTHER USB DEVICES ARE CONNECTED! (e.g. Toshiba/WD Element HDD)${NC}"
echo ""
echo "Image name: ${CYAN}${CLONEZILLA_IMAGE}${NC}"
echo "Total # of drives: ${CYAN}${NUMBER_OF_DRIVES}${NC}"
echo ""
echo "Is this correct?"
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"

echo "==================================================================================================================================================================================================================="
echo "EXECUTING: sudo osc-restore-mdisks -batch -p '-batch -p true' ${CLONEZILLA_IMAGE} ${USB_LIST}"
echo "==================================================================================================================================================================================================================="
echo ""
echo ""
sudo osc-restore-mdisks -batch -p '-batch -p true' ${CLONEZILLA_IMAGE} ${USB_LIST}
echo ""
echo "======================="
echo " UUID SHOULD ALL MATCH"
echo "======================="
echo ""
sync
sudo blkid | grep -v 'CLONER' | grep -v 'partimag' | grep -v 'PARTIMAG' | grep -v 'squashfs'
echo ""
echo "Image name: ${CYAN}${CLONEZILLA_IMAGE}${NC}"
echo "Total # of drives: ${CYAN}${NUMBER_OF_DRIVES}${NC}"
exit 0
