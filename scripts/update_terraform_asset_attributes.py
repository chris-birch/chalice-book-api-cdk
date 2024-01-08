#!/bin/python3

#
# Script to update Terraform assets with Chalice app outputs
#

import boto3
import json
from botocore.exceptions import ClientError

from devtools import debug

print("Updating Terraform assets with Chalice outputs")

session = boto3.Session()

def updateLambdaEnvars(lambda_name, envar, value):

    lambdaFunction = boto3.client('lambda')
    
    lambdaFunction.update_function_configuration(
         FunctionName=lambda_name,
         Environment={
            'Variables': {
                envar: value + "books"
            }
        },
    )

def createApiAccessPolicy(rest_api_execute_arn, csv_processor_function_role_name):
    admin_api_access_policy = {
        "Statement": [
            {
                "Action": [
                    "execute-api:Invoke",
                    "execute-api:ManageConnections"
                ],
                "Effect": "Allow",
                "Resource": rest_api_execute_arn
            }
        ],
        "Version": "2012-10-17"
    }


    iam = boto3.client('iam')

    iam.put_role_policy (
        RoleName=csv_processor_function_role_name,
        PolicyName='csv_processor_invoke_admin_api',
        PolicyDocument=json.dumps(admin_api_access_policy)
    )

try:
    ssm = session.client('ssm')
    rest_api_execute_arn = ssm.get_parameter(Name='/chalice_cdk_project/outputs/restApi/execute_arn', WithDecryption=False).get('Parameter').get('Value')
    csv_processor_function_name = ssm.get_parameter(Name='/chalice_cdk_project/outputs/csv_processor/function_name', WithDecryption=False).get('Parameter').get('Value')
    admin_api_URL = ssm.get_parameter(Name='/chalice_cdk_project/outputs/EndpointURL', WithDecryption=False).get('Parameter').get('Value')
    csv_processor_function_role_name = ssm.get_parameter(Name='/chalice_cdk_project/outputs/csv_processor/function_role_name', WithDecryption=False).get('Parameter').get('Value')
    

except ClientError as err:
        if err.response['Error']['Code'] == 'AccessDeniedException':
            print("ERROR: " + e.response['Error']['Message'])
        if err.response['Error']['Code'] == 'ParameterNotFound':
            print(err.args[0])

        else:
            raise err


# Update CSV processor function with Admin API invoke URL
updateLambdaEnvars(csv_processor_function_name, 'APIURL', admin_api_URL)

# Allow the CSV Processor Function to invoke the Admin API
createApiAccessPolicy(rest_api_execute_arn, csv_processor_function_role_name)