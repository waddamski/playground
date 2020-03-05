import json

def access_key_check(file_name):
    result = []
    with open(file_name, 'r') as json_file:
        raw_input = json.load(json_file)

        # Loop through the access keys, check their status is 'Active' and print the details.
        for i in range(len(raw_input)):
            for s in range(len(raw_input[i]['AccessKeys'])):
                status = raw_input[i]['AccessKeys'][s]['Status']
                if 'Active' in status:
                    new_dict = {'Arn': raw_input[i]['arn'], 'Access Key ID': raw_input[i]['AccessKeys']}
                    result.append(new_dict)


    print(json.dumps(result, indent=2))


file_name='../input_files/iam-user-no-Active-key-rotation.json'
access_key_check(file_name)