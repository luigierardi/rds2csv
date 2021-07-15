#!/bin/bash

# Copyright (C) 2021  Luigi Erardi - All Rights Reserved
# 07/15/2021 - version 1.0

LOCAL_PATH=$(dirname $0)
LIB_PATH="${LOCAL_PATH}/lib"

. ${LOCAL_PATH}/etc/conf_file.cnf

function usage()
{
	echo "Usage:"
	echo "$(basename $0) REPO_CONF_FILE SOURCE_DIR"
	exit 1
}

if [ "x$1" == "x" -o "x$2" == "x" ]
then
	usage
fi

CONF_FILE="$1"
SOURCE="$2"

INFO='\033[0;34m'
WARNING='\033[0;33m'
ERROR='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f "$CONF_FILE" ]
then
	echo "Conf file $CONF_FILE doesn't exists"
	exit 2
fi

if [ ! -d "$SOURCE" ]
then
	echo "Source dir $SOURCE doesn't exists"
	exit 2
fi

while read STRING;
do
	DIR=$(echo $STRING | cut -d ";" -f 1)
	SOURCE_PATTERN=$(echo $STRING | cut -d ";" -f 2)
	SOURCE_FILE=$(echo $STRING | cut -d ";" -f 3)
	DEST_FILE=$(echo $STRING | cut -d ";" -f 3| sed 's/\.json/\.csv/g')
	if [ $(echo "$STRING" | $GREP -c "#") -eq 0 -a "x$STRING" != "x" ]
	then
		DEST_DIR=$(echo "${DIR}"| sed 's/\/\*//g' | sed 's/\\\*//g')

		if [ -f ${SOURCE}/${DEST_DIR}/${SOURCE_FILE} ]
		then
			echo -e "${INFO}INFO:$(basename $0 ):processing ${SOURCE}/${DEST_DIR}/${SOURCE_FILE} to file ${SOURCE}/${DEST_DIR}/${DEST_FILE}${NC}\c" | tr -s "/"
			OUTPUT=$(${PYTHON} ${LIB_PATH}/json2csv.py -o ${SOURCE}/${DEST_DIR}/${DEST_FILE}  -n data ${SOURCE}/${DEST_DIR}/${SOURCE_FILE})
			if [ $? -eq 0 ]
			then
				echo -e "\t${GREEN}[ OK ]${NC}"
			else
				echo -e "\t${ERROR}[ SEE DETAILS ]${NC}"
				echo "$OUTPUT"
			fi
		else
			echo -e "${WARNING}WARNING:$(basename $0 ):file ${SOURCE}/${DEST_DIR}/${SOURCE_FILE} doesn't exists${NC}"
		fi
	fi
done < $CONF_FILE

