
# Copyright (C) 2021  Luigi Erardi - All Rights Reserved
# 07/15/2021 - version 1.0

# Exit codes:
# 0 - OK
# 1 - WARNING and or ERRORS

import json, getopt, sys, os

inputfile = []
outputfile = ""
node = ""
data = []
items = []
finaljson = []
result=0

def usage():
   print ('Usage:')
   print (os.path.basename(sys.argv[0]), '[ -o <output_file_name> ] -n <node> file1 file2 file3 data*.json .....')

class bcolors:
    HEADER = '\033[35m'
    OKBLUE = '\033[34m'
    OKCYAN = '\033[36m'
    OKGREEN = '\033[32m'
    WARNING = '\033[33m'
    FAIL = '\033[31m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

options, remainder = getopt.getopt(sys.argv[1:], 'n:o:', ['node=', 'output=' ])

for opt, arg in options:
    if opt in ('-o', '--output'):
       outputfile = arg
    elif opt in ('-n', '--node'):
        node = arg

if ( node == "" ):
   usage()
   sys.exit(2)

finaljson = {node : []}

for file_name in remainder:
    with open(file_name) as f:
        try:
            data = json.load(f)
        except ValueError as e:
            f.close ()
            continue
        if ( node in data and data[node] ):
            items = data[node]
            finaljson[node].extend(items)
            f.close ()
        elif ( 'error' in data ):
            print (bcolors.WARNING + "WARNING:", os.path.basename(sys.argv[0]), ":file", file_name, " has error code", data['error']['code'], " - ",  data['error']['message']+ bcolors.ENDC, sep="")
            result = 1
        else:
            print (bcolors.WARNING + "WARNING:",os.path.basename(sys.argv[0]),":file", file_name, " has no data"+ bcolors.ENDC, sep="")
            result = 1

if ( node in finaljson and finaljson[node] ):
    if ( outputfile == "" ):
        print (json.dumps(finaljson, indent=2))
    else:
        with open(outputfile, "w") as f:
            f.write(json.dumps(finaljson, indent=2))

sys.exit(result)
