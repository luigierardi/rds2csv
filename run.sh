#!/bin/bash

# Copyright (C) 2021  Luigi Erardi - All Rights Reserved
# 07/15/2021 - version 1.0

LOCAL_PATH=$(dirname $0)
LIB_PATH="${LOCAL_PATH}/lib"


function usage()
{
	echo "Usage:"
	echo "$(basename $0) CONF_FILE SOURCE_DIR"
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

echo 
for ext in csv json
do
	echo -e "Verifing present of $ext file into source directory\c"
	OUTPUT=$(find ${SOURCE} -name \*.${ext})
	if [ "x$OUTPUT" = "x" ]
	then
		echo -e "\t[ ${GREEN}OK ${NC}]" 
	else
		echo -e "\t[ ${ERROR}FAIL ${NC}]" 
		echo "Please remove ${ext} files from the source directory"
		exit 2
	fi
done

echo
echo "===================================================="
echo "     Step 1/4 - Converting files from RDS format"
echo "===================================================="
echo
${LOCAL_PATH}/convert_from_rds.sh $SOURCE

echo
echo "===================================================="
echo "           Step 2/4 - Merging json files"
echo "===================================================="
echo
${LOCAL_PATH}/merge_json.sh $CONF_FILE $SOURCE

echo
echo "===================================================="
echo "         Step 3/4 - Generate CSV from json"
echo "===================================================="
echo
${LOCAL_PATH}/generate_csv.sh $CONF_FILE $SOURCE

echo
echo "===================================================="
echo "         Step 4/4 - Generate zip file"
echo "===================================================="
echo
ACTUAL_DIR=$(pwd)
cd ${SOURCE} 
find . -name \*.csv -exec zip -pr ${ACTUAL_DIR}/csv_files.zip {} \;
cd -
