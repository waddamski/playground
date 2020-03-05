import json

with open('s3-bucket-world-Get-policy.json', 'r') as json_file:
    data = json.load(json_file)
    for i in data:
        print('')
        print('ID: ' + i['id'])
        print('Name: ' + i['name'])
        pol = i['policy']

        for stat in pol['Statement']:
            if isinstance(stat['Action'], str):
                if "Get" in stat['Action']:
                    print('ACTION = ', stat)
            elif isinstance(stat['Action'], list):
                for x in range(len(stat['Action'])):
                    if "Get" in stat['Action'][x]:
                        print('ACTION = ', stat)
