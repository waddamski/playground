import json

def iam_assume_role_lacks_ext_id_and_mfa():
    file = '../input_files/iam-assume-role-lacks-external-id-and-mfa.json'
    result= []
    with open(file, 'r') as json_file:
        raw_input = json.load(json_file)

        for i in range(len(raw_input)):
            # Construct a new stripped down bucket entry
            new_bucket = {'id': raw_input[i]['id'], 'arn': raw_input[i]['arn'], 'assume role policy': raw_input[i]['assume_role_policy']}
            result.append(new_bucket)

    print(json.dumps(result, indent=2))


iam_assume_role_lacks_ext_id_and_mfa()