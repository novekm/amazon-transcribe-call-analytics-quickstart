# TO DO - EDIT THIS FUNCTION TO WORK PROPERLY !!!
# Testing


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
key_tca_dynamodb_output_table_name_ENV = os.environ['key_tca_dynamodb_output_table_name']

# lambda function to copy file from 1 s3 to another s3
def lambda_handler(event, context):
    # Use SSM Client to fetch the name (key) for the SSM Parameter for the TCA DynamoDB Output Table
    ssm_tca_dynamodb_output_table_name = ssm_client.get_parameter(Name = key_tca_dynamodb_output_table_name_ENV)
    value_dynamodb_output_table_name = ssm_tca_dynamodb_output_table_name['Parameter']['Value']
    print(f'DynamoDB Table Name:{value_dynamodb_output_table_name}')

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
    # table = dynamodb.Table(value_dynamodb_output_table_name)
    # table.put_item(Item=jsonDict)

    return {
        'statusCode': 3000,
        # 'body': json.dumps(f'DynamoDB item has been successfully created. The timestamp is {createdAt}.'),
        'body': value_dynamodb_output_table_name,

    }
