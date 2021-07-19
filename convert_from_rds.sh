#!/bin/bash

# Copyright (C) 2021  Luigi Erardi - All Rights Reserved
# 07/15/2021 - version 1.0

LOCAL_PATH=$(dirname $0)
LIB_PATH="${LOCAL_PATH}/lib"

. ${LOCAL_PATH}/etc/conf_file.cnf

function usage()
{
	echo "Usage:"
	echo "$(basename $0) SOURCE_DIR"
	exit 1
}

if [ "x$1" == "x" ]
then
	usage
fi

SOURCE="$1"

if [ ! -d "$SOURCE" ]
then
	echo "Source dir $SOURCE doesn't exists"
	exit 2
fi

for FILE_NAME in $($FIND $1 -name \*.rds)
do
	echo -e "${INFO}INFO:$(basename $0 ):converting RDS file ${FILE_NAME}${NC}\c"
	OUTPUT=$($RSCRIPT ${LIB_PATH}/read.r ${FILE_NAME} 2>&1)
	if [ $? -eq 0 ]
	then
		echo -e "\t${GREEN}[ OK ]${NC}"
	else
		echo -e "\t${ERROR}[ SEE DETAILS ]${NC}"
		echo "$OUTPUT"
	fi
done


