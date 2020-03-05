# IAM: Inline role policy allows iam:PassRole * - id, name, policydocument.statement where action has 'PassRole'

import json


def iam_inline_policy_allows_pass_role():
    file = '../input_files/iam-inline-role-policy-allows-iam-PassRole.json'
    result = []
    with open(file, 'r') as json_file:
        raw_input = json.load(json_file)

        for i in range(len(raw_input)):
            new_dict = {'arn': raw_input[i]['arn'], 'id': raw_input[i]['id'], 'policy': dict()}
            inline_policies = raw_input[i]['inline_policies']
            for pol in inline_policies:
                new_dict['policy']['Statement'] = []

                for j in range(len(inline_policies[pol]['PolicyDocument']['Statement'])):
                    for act in inline_policies[pol]['PolicyDocument']['Statement'][j]['Action']:
                        if 'PassRole' in act:
                            new_dict['policy']['Statement'].append(inline_policies[pol]['PolicyDocument']['Statement'][j]['Action'])

                result.append(new_dict)

    print(json.dumps(result, indent=2))


iam_inline_policy_allows_pass_role()