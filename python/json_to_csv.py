import csv, json, sys

files = ['whitelisted_ips', 'prod_whitelisted_ips', 'waf_ips', 'prod_waf_ips']

for file in files:
    jsonfile = (file + '.json')
    csvfile = (file + '.csv')
    print(jsonfile)
    print(csvfile)
#sys.setdefaultencoding("UTF-8") #set the encode to utf8
    inputFile = open(jsonfile) #open json file
    outputFile = open(csvfile, 'w') #load csv file
    data = json.load(inputFile) #load json content
    inputFile.close() #close the input file
    output = csv.writer(outputFile) #create a csv.write
    output.writerow(data[0].keys())  # header row
    for row in data:
        output.writerow(row.values()) #values row
