#!/bin/bash

# Copyright (C) 2021  Luigi Erardi - All Rights Reserved
# 07/15/2021 - version 1.0

LOCAL_PATH=$(dirname $0)
LIB_PATH="${LOCAL_PATH}/lib"

RSCRIPT="Rscript"

INFO='\033[0;34m'
WARNING='\033[0;33m'
ERROR='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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

for FILE_NAME in $(find $1 -name \*.rds)
do
	echo -e "${INFO}INFO:$(basename $0 ):converting RDS file ${FILE_NAME}${NC}\c"
	OUTPUT=$($RSCRIPT ${LIB_PATH}/read.r ${FILE_NAME})
	if [ $? -eq 0 ]
	then
		echo -e "\t${GREEN}[ OK ]${NC}"
	else
		echo -e "\t${ERROR}[ SEE DETAILS ]${NC}"
		echo "$OUTPUT"
	fi
done


