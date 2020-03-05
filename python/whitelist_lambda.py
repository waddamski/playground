from __future__ import print_function
from datetime import datetime
import os
import json
import csv
import boto3
import botocore
from collections import defaultdict
from copy import copy
import smtplib, ssl
import email
from os.path import basename
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders
from email.utils import COMMASPACE, formatdate
import io
from io import BytesIO
from io import StringIO
import zipfile
import tempfile

ec2 = boto3.client('ec2', region_name='eu-west-2')
waf = boto3.client('waf', region_name='eu-west-2')


def get_security_groups_ips():
    result = []
    new_dict = defaultdict()
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
    print("AT GET_WAF_IPS")
    rule_list = list_rules()
    iprules = get_rule_ids(rule_list)
    ruleinfo = get_ip_sets(iprules)
    return (ruleinfo)


def list_rules():
    print("AT LIST_RULES")
    # rule_ids = []
    print("PASSED RULEIDS")
    rules = waf.list_rules()
    print(rules)
    # for rule in rules['Rules']:
        # print("RULE = ", rule)
        # rule_ids.append(rule['RuleId'])
    # return (rule_ids)


def get_rule_ids(rules):
    print("AT GET_RULE_IDS")
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
    return (rule_info)


def get_ip_sets(rule_info):
    print("AT GET_IP_SETS")
    set_array = []
    # set_dict = defaultdict()
    for i in range(len(rule_info)):
        ipset = waf.get_ip_set(
            IPSetId=rule_info[i]['Rule_set_id']
        )
        set_dict = {'RuleId': rule_info[i]['RuleId'], 'RuleName': rule_info[i]['Name'],
                    'IPSetID': ipset['IPSet']['IPSetId'], 'IPSetName': ipset['IPSet']['Name'], 'CIDRS': []}
        ip_array = []
        for set in ipset['IPSet']['IPSetDescriptors']:
            if 'IPV4' in set['Type']:
                ip_array.append(set['Value'])
        set_dict.update({'CIDRS': ip_array})
        set_array.append(set_dict)
    return (set_array)


def create_archive(strs, prefix):
    mf = io.BytesIO()
    with zipfile.ZipFile(mf, mode="a", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(f'{prefix}.csv', str.encode(str(strs), 'utf-8'))
    return mf


def convert_to_csv(json_strs):
    data = json.loads(json_strs)
    buffer = io.StringIO()
    csv_w = csv.writer(buffer)
    csv_w.writerow(data[0].keys())
    for row in data:
        print(row)
        csv_w.writerow(row.values())
    results = buffer.getvalue()
    # buffer.close
    return results

def lambda_handler(event, context):
    # file_prefixes = ["security_groups", "waf"]
    file_prefixes = ["waf"]
    methods = {"security_groups": get_security_groups_ips, "waf": get_waf_ips}
    for fp in file_prefixes:
        if fp in methods:
            json_strs = json.dumps([fp]())
            csv_strs = convert_to_csv(json_strs)
            archive = create_archive(csv_strs, fp)
        else:
            raise Exception("Method %s not implemented" % fp)
        # function = ("get_" + fp + "_ips")
        # json_strs = json.dumps(function())
        # Convert json to csv
            # csv_strs = convert_to_csv(json_strs)
        # Convert the strings into a series of csv files in a zip archive
            # archive = create_archive(csv_strs, fp)
    # rewind to the start of the file so we read it all into the payload
    archive.seek(0)

    # Set the email metadata
    email = MIMEMultipart()
    email['To'] = str(os.environ['SMTP_TO'])
    email['From'] = str(os.environ['SMTP_FROM'])

    # Add the zip file to the email
    msg = MIMEBase('application', 'zip')
    msg.set_payload(archive.read())
    encoders.encode_base64(msg)
    msg.add_header('Content-Disposition', 'attachment', filename='whitelisted_ips.zip')
    msg.add_header('Subject', 'Test Email from Lambda2')
    email.attach(msg)
    archive.close()
    
    # Send it out
    server = smtplib.SMTP(os.environ['SMTP_SERVER'])
    try:
        server.set_debuglevel(True)

        server.ehlo()
        if server.has_extn('STARTTLS'):
            server.starttls()
            server.ehlo()

        server.login(os.environ['SMTP_USER'], os.environ['SMTP_PASS'])
        server.sendmail([os.environ['SMTP_FROM']], [os.environ['SMTP_TO']], msg.as_string())
    finally:
        server.quit()
