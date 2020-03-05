import json
import sys
import boto3
import botocore
from ipwhois import IPWhois
import re
import pprint
import argparse


def set_aws_cli_connection():
    # sets up a connection details for aws.
    config = read_config()
    assumed_role_object = authenticate_assume_role(config)
    credentials = assumed_role_object['Credentials']
    return credentials


def read_config():
    # Reads the aws config and credentials files for the given profile and returns
    # a combined configuration object

    profiles = botocore.session.get_session().full_config.get('profiles', {})

    global profile
    if profile not in profiles:
        sys.exit("The profile (%s) you entered is not in your ~/.aws/config file. It needs to be a valid profile." % profile)

    return profiles[profile]


def authenticate_assume_role(config):
    # I'd love to say I fully know what this does, but it's nicked from another script.
    # It came from the awssudo code and sorts out the role switching magic.
    sts_client = boto3.client('sts')

    if 'mfa_serial' in config:
        token_code = input("Enter MFA code: ")

        response = sts_client.assume_role(
            RoleArn=config['role_arn'],
            RoleSessionName='AWS_SESSION_NAME',
            SerialNumber=config['mfa_serial'],
            TokenCode=token_code,
            DurationSeconds=3600
        )
    else:
        response = sts_client.assume_role(
            RoleArn=config['role_arn'],
            RoleSessionName='AWS_SESSION_NAME',
            DurationSeconds=3600
        )
        if 'region' in config:
            response['Credentials']['DefaultRegion'] = config['region']

    return response


def match_file_to_function(file_name):
    # This matches a filename to a function to run.
    # It relies on Scout exporting files with consistent naming!
    matched_func = None

    files_to_functions = {
        "ec2-instance-with-user-data-secrets": user_data_parse,
        "s3-bucket-world-Get-policy": s3_bucket_policy_parse,
        "iam-assume-role-lacks-external-id-and-mfa": iam_no_id_mfa,
        "ec2-security-group-whitelists-aws2": parse_sg_ip_file,
        "iam-inline-role-policy-allows-iam-PassRole": iam_inline_policy_allows_pass_role,
        "iam-user-no-Active-key-rotation": access_key_check,
        "iam-managed-policy-allows-iam-PassRole": iam_managed_policy_allows_pass_role
    }

    for match in files_to_functions:
        if match in file_name:
            matched_func = files_to_functions.get(match)


    return matched_func


def get_launch_configuration(inst_ids):
    # Take an array of inst_ids and get the launch configuration name for each ID.
    # It connects to AWS API, so requires MFA if that's needed by the user.

    launch_configs = dict()
    global creds
    # Instantiate connnection to AWS
    # creds = set_aws_cli_connection()
    client = boto3.client('autoscaling', 'eu-west-2',
                          aws_access_key_id=creds['AccessKeyId'],
                          aws_secret_access_key=creds['SecretAccessKey'],
                          aws_session_token=creds['SessionToken'],
                          )

    # Run through instance ids and get the autoscaling group details for each instance,
    # pluck out the launch config name.
    for instance in inst_ids:
        asg_inst = client.describe_auto_scaling_instances(
            InstanceIds=[instance]
        )
        # Check that a launch config exists for each instance. Set 'lc' to 'NONE' if there is not one.
        for asg in asg_inst['AutoScalingInstances']:
            if not asg.get('LaunchConfigurationName'):
                lc = "NONE"
            else:
                lc = asg['LaunchConfigurationName']
        # Build the dictionary of instance IDs and launch configs.
        launch_configs[instance] = lc
    return launch_configs


def user_data_parse(file_name):
    # Retrieves the user-data for each given instance ID along with the launch config.
    out_file = 'user_data_secrets_results.json'
    with open(file_name, 'r') as json_file:
        data = json.load(json_file)
        result = []

    # Build new array for the instance_ids to pass to get_launch_configuration()
    inst_ids = []
    for i in range(len(data)):
        inst_ids.append(data[i]['id'])
    # Pass IDs to get_launch_configuration() and populate new dict (id_lc) with the output
    id_lc = get_launch_configuration(inst_ids)
    for i in range(len(data)):
        launch_config_name = id_lc[data[i]['id']]
        new_array = {'instance id': data[i]['id'], 'instance name': data[i]['name'], 'Launch Config Name': launch_config_name,
                     'user data': data[i]['user_data']}
        result.append(new_array)
    return result, out_file


def s3_bucket_policy_parse(file_name):
    # Pulls out the ID and bucketname along with the offending 'Get%' statement.
    out_file = 's3_buck_pol_results.json'
    with open(file_name) as json_file:
        raw_buckets = json.load(json_file)
        result = []

        for bi in range(len(raw_buckets)):
            # Construct a new stripped down bucket entry
            new_bucket = {'id': raw_buckets[bi]['id'], 'name': raw_buckets[bi]['name'], 'policy': dict()}
            policy = raw_buckets[bi]['policy']
            new_bucket['policy']['Statement'] = []

            # Iterate over each Statement in source policy
            for pi in range(len(policy['Statement'])):
                # if Action is a string
                if isinstance(policy['Statement'][pi]['Action'], str) and 'Get' in policy['Statement'][pi]['Action']:
                    # Append to new_bucket if a Get Action
                    new_bucket['policy']['Statement'].append(policy['Statement'][pi])
                # if Action is a string array
                elif isinstance(policy['Statement'][pi]['Action'], list):
                    for si in range(len(policy['Statement'][pi]['Action'])):
                        # Append to new_bucket if a Get Action
                        if 'Get' in policy['Statement'][pi]['Action'][si]:
                            new_bucket['policy']['Statement'].append(policy['Statement'][pi])

            result.append(new_bucket)

    return result, out_file


def iam_no_id_mfa(file_name):
    # Returns stripped down results of input file with ID, ARN and the offending Assume_role policy.
    out_file = 'no_id_mfa_results.json'
    with open(file_name, 'r') as json_file:
        raw_input = json.load(json_file)
        result = []
        for i in range(len(raw_input)):
            # Build a new dictionary with the stripped down input.
            new_dict = {'id': raw_input[i]['id'], 'arn': raw_input[i]['arn'], 'assume role policy': raw_input[i]['assume_role_policy']}
            result.append(new_dict)
    return result, out_file


def iam_inline_policy_allows_pass_role(file_name):
    # Strips the input down to just give the arn, id and relevant PassRole policy.
    result = []
    out_file = 'inline_pol_pass_role_results.json'
    with open(file_name, 'r') as json_file:
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

    return result, out_file


def iam_managed_policy_allows_pass_role(file_name):
    # Strips the input down to just give the arn, id and relevant PassRole policy.
    out_file = 'man_pol_pass_role_results.json'
    result = []
    with open(file_name, 'r') as json_file:
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

    return result, out_file


def whois_lookup(addresses):
    # Performs a whois lookup on a given list of IP addresses.
    result = dict()
    for address in addresses:
        # Tries to get results but if can't, it suggests looking the IP up manually and continues unabated.
        try:
            obj = IPWhois(address)
            res = obj.lookup_rdap()
            res_array = {'ASN CIDR': res['asn_cidr'], 'CIDR': res['network']['cidr'], 'Organisation': res['asn_description'],  'Net Name': res['network']['name'], 'Parent Handle': res['network']['parent_handle']}
        except:
            res_array = {'ADDRESS': address, 'ERROR': 'Unable to lookup this address. Please do it manually'}
        finally:
            result[address] = res_array
    return result


def parse_sg_ip_file(file_name):
    # Pulls the IP addresses out of the json file and loads them into a set (which ensures no duplicates).
    # It sorts them and then passes them to whois_lookup() for results.
    out_file = 'whois_results.json'
    with open(file_name, 'r') as json_file:
        raw_input = json.load(json_file)
        ips = set() # Use a set to avoid duplicates.
        with open('/tmp/output.txt', 'w') as out:
            pp = pprint.PrettyPrinter(stream=out)
            for line in raw_input:
                pp.pprint(str(line))
        with open('/tmp/output.txt', 'r') as tmp_file:
            for line in tmp_file:
                ip = re.findall(r'[0-9]+(?:\.[0-9]+){3}', line)
                # sanitise the ip array by removing the square brackets.
                for each in ip:
                    clean_ip = each.replace("[]", "")
                    ips.add(clean_ip)

    output = whois_lookup(sorted(ips))
    return output, out_file


def access_key_check(file_name):
    # Returns the user ARN and access key details of each flagged key.
    result = []
    out_file = 'active_key_check.json'
    with open(file_name, 'r') as json_file:
        raw_input = json.load(json_file)

        # Loop through the access keys, check their status is 'Active' and print the details.
        for i in range(len(raw_input)):
            for s in range(len(raw_input[i]['AccessKeys'])):
                status = raw_input[i]['AccessKeys'][s]['Status']
                if 'Active' in status:
                    new_dict = {'Arn': raw_input[i]['arn'], 'Access Key ID': raw_input[i]['AccessKeys']}
                    result.append(new_dict)

    return result, out_file


def parse_options():
    parser = argparse.ArgumentParser(
        description='''Parses json files generated by ScoutSuite and returns a more manageable amount of data.
    The intention is that it provides enough info to decide whether it warrants investigation and the
    relenvant data to conduct that investigation.
    It should also provide enough meaningful data to raise Jira tickets to pass to the SWG.

    It is a work in progress and will need more functions added to it over time in order to be useful
    for all the issues that ScoutSuite raises.''',
        usage='''python3 scout_results_summary.py <json_file_path> <aws_cli profile name>
        e.g python3 scout_results_summary.py s3-bucket-world-Get-policy.json ds-prod''')
    parser.add_argument("-f", "--file", help='the name of the input file')
    parser.add_argument("-p", "--awsprofile", help="the name of your aws_cli profile - generally ds-prod or ds-nonprod")
    args = parser.parse_args()
    return args


def main():
    args = parse_options()
    file_name = args.file
    global profile
    profile = args.awsprofile
    global creds
    creds = set_aws_cli_connection()
    matched_function = match_file_to_function(file_name)
    if matched_function is None:
        print("No suitable function exists for parsing this file.")
    else:
        results, out_file = matched_function(file_name)
        with open('/tmp/%s' % out_file, 'w') as res_file:
            json.dump(results, res_file, indent=2)
        print('The file /tmp/%s has been created. Push it through jq or something similar.' % out_file)


profile = ""
creds = None
if __name__ == '__main__':
    main()
