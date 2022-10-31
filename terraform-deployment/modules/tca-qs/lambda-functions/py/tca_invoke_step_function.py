# TO DO - WRITE THIS FUNCTION !!!
# Testing


# import json
# import os
# import string
# import random
# from typing import Dict

# from aws_lambda_powertools.logging import Logger
# from aws_lambda_powertools.tracing import Tracer
# from aws_lambda_powertools.utilities.data_classes import S3Event

# from handlers import DataHandler

# logger = Logger(service="carbonlake", level="debug")
# tracer = Tracer()

# # arn =
# """
# INPUT: S3 PUT Event from the Landing S3 bucket
# PROCESS:
#     1. generate the initial hash id for the job (this will be the DL root_id for all child records)
#     2. determine the file type of the input to choose the correct process / DQ workflow
#     3. start the step function to orchestrate to CO2e calculation job workflow
# OUTPUT: None
# """
# @logger.inject_lambda_context(log_event=True)
# @tracer.capture_lambda_handler()
# def lambda_handler(event: Dict, context: Dict):
#     event = S3Event(event)

#     # setup data handler tp manage communication with other AWS services
#     data_handler = DataHandler(os.environ["STATEMACHINE_ARN"])

#     # alphabet used for generating uids randomly
#     alphabet = string.ascii_letters + string.digits

#     for record in event.records:

#         s3uri = f"s3://{event.bucket_name}/{record.s3.get_object.key}"
#         # TO-DO - Actually do a check to determine file type in s3 - for now, assuming csv
#         logger.info(f"Processing file: {s3uri}")

#         # root_id is the origin for all data lineage requests for this job batch
#         # since this is the first node in the graph, node is its own parent
#         root_id = "".join(random.choices(alphabet, k=12))

#         data_input = {
#             "root_id": root_id,
#             "storage_location": s3uri
#         }

#         # START STEP FUNCTION EXECUTION
#         sfn_payload = { "input": data_input }
#         data_handler.sfn.start_execution(json.dumps(sfn_payload))

#     return sfn_payload


import boto3
import os
import json
from datetime import datetime
from decimal import Decimal

s3_client=boto3.client('s3')
dynamodb=boto3.resource('dynamodb')
ssm_client = boto3.client('ssm')

# - Environmental Variables -
# The names of SSM Parameter store values will be used as environmental variables
# These will be passed into Lambda by Terraform with the aws_lambda resource in lambda.tf
# This is the only way to pass Terraform values into a Lambda function
# While using env variables is generally not recommended, the actual value will be
# secured by parameter store. Even if a user gains the name of your SSM parameter store
# resource, they cannot see the value unless they have necessary IAM permissions.

# The string MUST EXACTLY match the environment variable name in the lambda.tf file
# as that is the name of the environment variable defined in the Lambda TF resource
key_tca_input_bucket_name_ENV = os.environ['key_tca_input_bucket_name_name']

# lambda function to copy file from 1 s3 to another s3
def lambda_handler(event, context):
    # Use SSM Client to fetch the name (key) for the SSM Parameter for the TCA DynamoDB Output Table
    ssm_tca_input_bucket_name = ssm_client.get_parameter(Name = key_tca_input_bucket_name_ENV)
    value_tca_input_bucket_name = ssm_tca_input_bucket_name['Parameter']['Value']
    print(f'Transcribe Input Bucket:{value_tca_input_bucket_name}')

    # print(json.dumps(event))
    # record = event['Records'][0]
    # eventTime = record ['eventTime']

    # createdAt = {"createdAt":eventTime}
    # updatedAt = {"updatedAt":eventTime}

    # #specify source bucket
    # source_bucket_name=record['s3']['bucket']['name']

    # #get object that has been uploaded
    # file_name=record['s3']['object']['key']


    # # create new string with public/ and -transcript.json removed from s3 object key
    # new_file_name = file_name.replace('public/', '').replace('-transcript.json','')

    # filePath = {"filePath": new_file_name}

    # #get object from s3 bucket, read the body, and convert it into a dictionary
    # json_object = s3_client.get_object(Bucket=source_bucket_name,Key=file_name)


    # jsonFileReader = json_object['Body'].read()
    # # jsonDict = json.loads(jsonFileReader)
    # jsonDict = json.loads(jsonFileReader, parse_float=Decimal)

    # jsonDict.update(createdAt)
    # jsonDict.update(updatedAt)
    # jsonDict.update(filePath)

    # #reference dynamodb table, use json dictionary to put that item into dynamodb table
    # table = dynamodb.Table('Job-ha7q5znbp5hn5bkagbv3z7owiq-dev')
    # table.put_item(Item=jsonDict)

    return {
        'statusCode': 3000,
        # 'body': json.dumps(f'DynamoDB item has been successfully created. The timestamp is {createdAt}.'),
        'body': value_tca_input_bucket_name,

    }
