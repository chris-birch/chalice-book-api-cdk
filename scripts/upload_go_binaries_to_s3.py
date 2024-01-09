#!/bin/python3

#
# Script to upload to S3 bucket and make available Go binary artifact to Terraform deploy  
#

import boto3
import os
import sys
import subprocess
from botocore.exceptions import ClientError

from pathlib import Path

S3_BUCKET_NAME = "github-actions-artifact-store-14z4a60uvvx3r" #This should remain globally unique
AWS_REGION = os.getenv("AWS_DEFAULT_REGION", "eu-west-2")

# Check that a folder has been given in app args
if (args_count := len(sys.argv)) > 2:
    print(f"One argument expected, got {args_count - 1}")
    raise SystemExit(2)
elif args_count < 2:
    print("You must specify the target directory")
    raise SystemExit(2)

target_dir = Path(sys.argv[1])

if not target_dir.is_dir():
    print("The target directory doesn't exist")
    raise SystemExit(1)


print("Starting Go artifact sync with S3")

client = boto3.client('s3')

def create_s3_bucket():
    try:
        client.create_bucket(Bucket=S3_BUCKET_NAME, CreateBucketConfiguration={'LocationConstraint': AWS_REGION})    
    
    except ClientError as e:
        print(e)


def artifact_bucket_exists():
    bucket_list = client.list_buckets()
    
    go_buckets = []

    for bucket in bucket_list['Buckets']:
        if S3_BUCKET_NAME in bucket['Name']:
            go_buckets.append(bucket['Name'])

    if len(go_buckets) != 0:
        return True
    else:
        return False

# Check artifacts exist
if len(os.listdir()) == 0:
    print("No artifact files found, exiting.")
    sys.exit(1)

# Upload to S3
if not artifact_bucket_exists():
    create_s3_bucket()

subprocess.run(["aws", "s3", "sync", target_dir, "s3://"+S3_BUCKET_NAME+"/", "--delete"])