# IAM: Managed policy allows iam:PassRole * - name, id, policydocument.statement where action has 'PassRole'

import json


def iam_managed_policy_allows_pass_role():
    file = '../input_files/iam-managed-policy-allows-iam-PassRole.json'
    result = []
    with open(file, 'r') as json_file:
        raw_input = json.load(json_file)

        for i in range(len(raw_input)):
            new_dict = {'arn': raw_input[i]['arn'], 'policy': dict()}
            managed_policies = raw_input[i]['PolicyDocument']
            for pol in range(len(managed_policies['Statement'])):
                new_dict['policy']['Statement'] = []

                for j in range(len(managed_policies['Statement'])):
                    for act in managed_policies['Statement'][j]['Action']:
                        if 'PassRole' in act:
                            new_dict['policy']['Statement'].append(managed_policies['Statement'][j])

                result.append(new_dict)

    print(json.dumps(result, indent=2))


iam_managed_policy_allows_pass_role()