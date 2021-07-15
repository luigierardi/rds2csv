
# Copyright (C) 2021  Luigi Erardi - All Rights Reserved
# 07/15/2021 - version 1.0

import sys, json, csv, io, getopt, os

# Separatore di nodo
node_separator="::"

# Separatore di array
array_separator="#"

outputfile = ""
node = ""
new_data = []
csv_header = []

def usage():
    print ("\nUsage:", os.path.basename(sys.argv[0]), "[ -o <output_file_name> ] -n <node> <source_file>\n")
    sys.exit(1)

# Forzo l'encoding se necessario
def string_normalize(s):
    try:
        return str(s)
    except:
        return s.encode('utf-8')


# Riorganizzazione degli item
def item_recursion(key, value):
    global items
    
    # Creo l'etichetta dell'array
    if type(value) is list:
        i=0
        for sub_item in value:
            item_recursion(key+array_separator+string_normalize(i), sub_item)
            i=i+1

    # Creo l'etichetta del nodo
    elif type(value) is dict:
        sub_keys = value.keys()
        for sub_key in sub_keys:
            item_recursion(key+node_separator+string_normalize(sub_key), value[sub_key])
    
    # Carico il dato finale
    else:
        items[string_normalize(key)] = string_normalize(value)


# MAIN
options, remainder = getopt.getopt(sys.argv[1:], 'n:o:', ['node=', 'output=' ])

for opt, arg in options:
    if opt in ('-o', '--output'):
       outputfile = arg
    elif opt in ('-n', '--node'):
        node = arg

if ( node == "" ):
   usage()
   sys.exit(2)

for file_name in remainder:
    with io.open(file_name, 'r', encoding='utf-8-sig') as fp:
        json_entry = fp.read()
        raw_data_full = json.loads(json_entry)
        if ( node in raw_data_full and raw_data_full != "" ):
            raw_data = raw_data_full[node]
        else:
            continue

    try:
        data = raw_data[node]
    except:
        data = raw_data

    for item in data:
        items = {}
        item_recursion(node, item)

        csv_header += items.keys()

        new_data.append(items)

    csv_header = list(set(csv_header))
    csv_header.sort()

if ( outputfile == "" ):
    f = sys.stdout 
else:
    f = open(outputfile, 'w+')

writer = csv.DictWriter(f, csv_header, quoting=csv.QUOTE_ALL)
writer.writeheader()
for row in new_data:
    writer.writerow(row)

print ("INFO:", os.path.basename(sys.argv[0]), ": File", outputfile, "is composed by %d columns" % len(csv_header), "and %d rows" % len(new_data))
