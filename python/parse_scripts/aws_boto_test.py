#import json
import sys
import boto3
import botocore


#    s3 = boto3.resource('s3')

def set_aws_cli_connection():
    config = read_config('ds-prod')
    assumed_role_object = authenticate_assume_role(config)
    credentials = assumed_role_object['Credentials']
    return credentials


def get_launch_configuration():
    ec2 = boto3.resource('ec2')

    creds = set_aws_cli_connection()

    client = boto3.client('autoscaling', 'eu-west-2',
                          aws_access_key_id=creds['AccessKeyId'],
                          aws_secret_access_key=creds['SecretAccessKey'],
                          aws_session_token=creds['SessionToken'],
                          )
    instance = 'i-042f5fef5c297d572'
    # instance = ec2.Instance(instance_id)
    asg_inst = client.describe_auto_scaling_instances(
        InstanceIds=[instance]
    )
    for asg in asg_inst['AutoScalingInstances']:
         launch_config = asg['LaunchConfigurationName']
         print(launch_config)


def read_config(profile):
    """
    Reads the aws config and credentials files for the given profile and returns
    a combined configuration object
    """
    profiles = botocore.session.get_session().full_config.get('profiles', {})

    if profile not in profiles:
        sys.exit(2)

    return profiles[profile]


def authenticate_assume_role(config):
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

get_launch_configuration()

