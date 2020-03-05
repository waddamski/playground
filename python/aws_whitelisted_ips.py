import json
import boto3
import botocore
import argparse
import sys
from collections import defaultdict
from copy import copy
from datetime import datetime
import time
import calendar

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
    # I'd love to say I fully know what this does, but it's nicked from Dave Kirk ultimately I think.
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


def get_all_security_groups():

    result = []
    new_dict = defaultdict()
    global creds
    # Instantiate connnection to AWS
    ec2 = boto3.client('ec2', 'eu-west-2',
                          aws_access_key_id=creds['AccessKeyId'],
                          aws_secret_access_key=creds['SecretAccessKey'],
                          aws_session_token=creds['SessionToken'],
                          )

    # Get group name, group id, environment tag, service name and logical component where an explict CIDR exists.

    sec_groups = ec2.describe_security_groups()
    security_groups = sec_groups['SecurityGroups']
    for i in range(len(security_groups)):
        ing_cidr_array = []
        egr_cidr_array = []
        ips = 'false'
        new_dict.update(group_name=security_groups[i]['GroupName'], group_id=security_groups[i]['GroupId'])
        if 'Tags' in security_groups[i]:
            tags = security_groups[i]['Tags']
            for tag in tags:
                if 'Environment' == tag['Key']:
                    new_dict['environment_tag'] = tag['Value']
                if 'ServiceName' == tag['Key']:
                    new_dict['service_name'] = tag['Value']
                if 'LogicalComponent' == tag['Key']:
                    new_dict['logical_component'] = tag['Value']
        else:
            new_dict['environment_tag'] = None
            new_dict['service_name'] = None
            new_dict['logical_component'] = None

        if 'IpPermissions' in security_groups[i]:
            ingressips = security_groups[i]['IpPermissions']
            for ing in range(len(ingressips)):
                if any(ingressips[ing]['IpRanges']):
                    ing_cidr_array.append(ingressips[ing]['IpRanges'])
                    ips = 'true'
        if 'IpPermissionsEgress' in security_groups[i]:
            egressips = security_groups[i]['IpPermissions']
            for egr in range(len(egressips)):
                if any(egressips[egr]['IpRanges']):
                    egr_cidr_array.append(egressips[egr]['IpRanges'])
                    ips = 'true'

    # Build the dictionary of SG group names, ID and IPs.

        if ips == 'true':
            new_dict.update({'ingress_cidrs': ing_cidr_array, 'egress_cidrs': egr_cidr_array})
            result.append(copy(new_dict))
    return result


def get_waf_ips():
    waf = boto3.client('waf', 'eu-west-2',
                       aws_access_key_id=creds['AccessKeyId'],
                       aws_secret_access_key=creds['SecretAccessKey'],
                       aws_session_token=creds['SessionToken'],
                       )
    rule_list = list_rules(waf)
    iprules = get_rule_ids(waf, rule_list)
    ruleinfo = get_ip_sets(waf, iprules)

    return(ruleinfo)


def list_rules(waf):
    rule_ids = []
    rules = waf.list_rules()
    # for r in range(len(rules)):
    for rule in rules['Rules']:
        rule_ids.append(rule['RuleId'])

    return(rule_ids)


def get_rule_ids(waf, rules):
    r_ids = rules
    rule_info = []
    for id in r_ids:
        rule_array = waf.get_rule(
            RuleId=id
        )
        for pred in rule_array['Rule']['Predicates']:
            if 'IPMatch' in pred['Type']:
                ip_rule_array = {'RuleId': rule_array['Rule']['RuleId'], 'Name': rule_array['Rule']['Name'],
                                 'Rule_set_id': pred['DataId']}
                rule_info.append(ip_rule_array)

    return(rule_info)


def get_ip_sets(waf, rule_info):
    set_array = []
    # set_dict = defaultdict()
    for i in range(len(rule_info)):
        ipset = waf.get_ip_set(
            IPSetId=rule_info[i]['Rule_set_id']
        )
        set_dict = {'RuleId': rule_info[i]['RuleId'], 'RuleName': rule_info[i]['Name'],
                    'IPSetID': ipset['IPSet']['IPSetId'], 'IPSetName': ipset['IPSet']['Name'], 'CIDRS':[]}
        ip_array = []
        for set in ipset['IPSet']['IPSetDescriptors']:
            if 'IPV4' in set['Type']:
                ip_array.append(set['Value'])
        set_dict.update({'CIDRS': ip_array})
        set_array.append(set_dict)

    return(set_array)


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
    parser.add_argument("-p", "--awsprofile", help="the name of your aws_cli profile - generally ds-prod or ds-nonprod")
    args = parser.parse_args()
    return args


def main():
    # ts1 = time.time()
    # print(ts1)
    # ts2 = datetime.now().timestamp()
    # print(ts2)
    # ts3 = calendar.timegm(time.gmtime())
    # print(ts3)
    # exit(0)

    args = parse_options()
    global profile
    # profile = args.awsprofile
    profile = 'ds-nonprod'
    global creds
    creds = set_aws_cli_connection()
    sec_group_results = get_all_security_groups()
    waf_results = get_waf_ips()
    with open('/tmp/whitelisted_ips.json', 'w') as sec_file:
        json.dump(sec_group_results, sec_file, indent=2)
    with open('/tmp/waf_ips.json', 'w') as waf_file:
        json.dump(waf_results, waf_file, indent=2)
    print('The files /tmp/whitelisted_ips.json and /tmp/waf_ips.json have been created. Push it through jq or something similar.')

profile = ""
creds = None
if __name__ == '__main__':
    main()