#!/bin/bash 

# Copyright (C) 2021  Luigi Erardi - All Rights Reserved
# 07/15/2021 - version 1.0

LOCAL_PATH=$(dirname $0)
LIB_PATH="${LOCAL_PATH}/lib"

. ${LOCAL_PATH}/etc/conf_file.cnf

function usage()
{
	echo "Usage:"
	echo "$(basename $0) CONF_FILE SOURCE_DIR [ DEST_DIR ]"
	exit 1
}

function question()
{
	while true; 
	do
		read -d '' -t 0.1 -n 10000
    		read -p "Please answer yes or no." yn
    		case $yn in
       			[Yy]* ) return 1
				;;
       			[Nn]* ) return 0
				;;
       			* ) 	continue
				;;
    		esac
	done

}

if [ "x$1" == "x" -o "x$2" == "x" ]
then
	usage
fi

CONF_FILE="$1"
SOURCE="$2"
if [ "x$3" = "x" ]
then
	DEST_DIR=""
else
	DEST_DIR="$3"
	if [ ! -d "$DEST_DIR" ]
	then
		echo "Destination direcory doesn'e exist"
		echo "Do you want to create it ?"
		question
		RESULT=$?
		if [ $RESULT -eq 1 ]
		then
			mkdir -p "$DEST_DIR"
		elif [ $RESULT -eq 0 ]
		then
			echo "Please create the destination directory"
			exit 2
		else
			echo "Undefined error"
			exit 255
		fi
	else
		if [ $(ls -1 "$DEST_DIR" | wc -l) -gt 0 ]
		then
			echo "Destination direcory must be empty"
			exit 2
		fi
	fi
fi

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

{
echo 
for ext in csv json
do
	echo -e "Verifing present of $ext file into source directory\c"
	OUTPUT=$($FIND ${SOURCE} -name \*.${ext})
	if [ "x$OUTPUT" = "x" ]
	then
		echo -e "\t[ ${GREEN}OK ${NC}]" 
	else
		echo -e "\t[ ${ERROR}FAIL ${NC}]" 
		echo "Do you want to remove all ${ext} files ?"
		question 
		RESULT=$?
		if [ $RESULT -eq 1 ]
		then
			echo "Removing files..."
			$FIND ${SOURCE} -name \*.${ext} > /dev/null 2>&1
		elif [ $RESULT -eq 0 ]
		then
			echo "Please remove ${ext} files from the source directory"
			exit 2
		else
			echo "Undefined error"
			exit 255
		fi
	fi
done

echo
echo "====================================================" 
echo "     Step 1/4 - Converting files from RDS format" 
echo "====================================================" 
echo
${LOCAL_PATH}/convert_from_rds.sh $SOURCE $DEST_DIR 

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
if [ "x$DEST_DIR" = "x" ]
then
	echo "         Step 4/4 - Generate zip file"
else
	echo "       Step 4/4 - Move file to $DEST_DIR"
fi
echo "===================================================="
echo
ACTUAL_DIR=$(pwd)
if [ "x$DEST_DIR" = "x" ]
then
	cd ${SOURCE} 
	${FIND} . -name \*.csv -exec ${ZIP} -pr ${ACTUAL_DIR}/csv_files.zip {} \;
	#${FIND} . -name \*.csv | ${ZIP} -pr ${ACTUAL_DIR}/csv_files.zip  -@
	cd $ACTUAL_DIR
else
	${FIND} ${SOURCE}/ -name \*.csv -exec cp {} ${DEST_DIR}/ \;
fi
} | $TEE  output.log
