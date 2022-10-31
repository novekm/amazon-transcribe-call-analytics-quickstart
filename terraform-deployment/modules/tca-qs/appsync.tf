# TODO - Consider replacing 'Scan' DynamoDB operations with 'Query'
# https://docs.aws.amazon.com/appsync/latest/devguide/resolver-mapping-template-reference-dynamodb.html#aws-appsync-resolver-mapping-template-reference-dynamodb-getitem
# https://docs.aws.amazon.com/appsync/latest/devguide/security-authz.html#amazon-cognito-user-pools-authorization
# API Data Source
resource "aws_appsync_datasource" "tca_appsync_dynamodb_datasource" {
  api_id           = aws_appsync_graphql_api.tca_appsync_graphql_api.id
  name             = "tca_output_dynamodb_datasource"
  service_role_arn = aws_iam_role.tca_appsync_dynamodb_restricted_access[0].arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.tca_output.name
  }
}
# API
resource "aws_appsync_graphql_api" "tca_appsync_graphql_api" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  name                = var.tca_appsync_graphql_api_name

  user_pool_config {
    aws_region     = data.aws_region.current.name
    default_action = "ALLOW"
    user_pool_id   = aws_cognito_user_pool.tca_user_pool.id
  }


  schema = <<EOF
type Job  @aws_auth(cognito_groups: ["Admin", "Standard"])  {
  JobName: String!
  AccountId: String
  Categories: AWSJSON
  Channel: String
  ContentMetadata: AWSJSON
  ConversationCharacteristics: AWSJSON
  JobStatus: String
  LanguageCode: String
  Participants: AWSJSON
  Transcript: AWSJSON
  CreatedAt: String
  CompletedAt: String
  FilePath: String
  SampleRate: String
  MediaFormat: String
}

type JobPaginated {
  items: [Job]
  nextToken: String
  @aws_auth(cognito_groups: ["Admin", "Standard"])
}


type Query {
  getAllJobs(limit: Int, nextToken: String): JobPaginated @aws_auth(cognito_groups: ["Admin", "Standard"])
  getAllJobsPaginated(limit: Int, nextToken: String): JobPaginated @aws_auth(cognito_groups: ["Admin", "Standard"])
  getOneJob(JobName: String!): Job @aws_auth(cognito_groups: ["Admin", "Standard"])
  }

type Mutation {
  deleteOneJob(JobName: String!): Job
  @aws_auth(cognito_groups: ["Admin",])
}

schema {
  query: Query
  mutation: Mutation
}
EOF
}


# Resolvers
# UNIT type resolver (default)

# Query - Get One Job
resource "aws_appsync_resolver" "tca_appsync_resolver_query_get_one_job" {
  api_id = aws_appsync_graphql_api.tca_appsync_graphql_api.id
  field  = "getOneJob"
  type   = "Query"
  # data_source = [aws_appsync_datasource.tca_appsync_dynamodb_datasource.name]
  data_source = aws_appsync_datasource.tca_appsync_dynamodb_datasource.name

  request_template = <<EOF
{
    "version" : "2017-02-28",
    "operation" : "GetItem",
    "key" : {
       "JobName" : $util.dynamodb.toDynamoDBJson($ctx.args.JobName)
    },
    "consistentRead" : false
}
EOF

  response_template = <<EOF
    $util.toJson($ctx.result)
EOF
}
# Scan - Get All Jobs (Limit of 1,000,000)
resource "aws_appsync_resolver" "tca_appsync_resolver_query_get_all_jobs" {
  api_id      = aws_appsync_graphql_api.tca_appsync_graphql_api.id
  field       = "getAllJobs"
  type        = "Query"
  data_source = aws_appsync_datasource.tca_appsync_dynamodb_datasource.name

  request_template = <<EOF

{
    "version" : "2017-02-28",
    "operation" : "Scan",
    "limit" : 1000000,
    "consistentRead" : false,
    "nextToken" : $util.toJson($util.defaultIfNullOrEmpty($ctx.args.nextToken, null)),
}
EOF

  response_template = <<EOF
   $util.toJson($ctx.result)
EOF
}
# Scan - Get All Jobs Paginated
resource "aws_appsync_resolver" "tca_appsync_resolver_query_get_all_jobs_paginated" {
  api_id      = aws_appsync_graphql_api.tca_appsync_graphql_api.id
  field       = "getAllJobsPaginated"
  type        = "Query"
  data_source = aws_appsync_datasource.tca_appsync_dynamodb_datasource.name

  request_template = <<EOF

{
    "version" : "2017-02-28",
    "operation" : "Scan",
    "limit" : 20,
    "consistentRead" : false,
    "nextToken" : $util.toJson($util.defaultIfNullOrEmpty($ctx.args.nextToken, null)),
}
EOF

  response_template = <<EOF
   $util.toJson($ctx.result)
EOF
}


# Mutation - Delete One Job
resource "aws_appsync_resolver" "tca_appsync_resolver_mutation_delete_one_job" {
  api_id      = aws_appsync_graphql_api.tca_appsync_graphql_api.id
  field       = "deleteOneJob"
  type        = "Mutation"
  data_source = aws_appsync_datasource.tca_appsync_dynamodb_datasource.name

  request_template = <<EOF
{
    "version" : "2017-02-28",
    "operation" : "DeleteItem",
    "key" : {
        "JobName" : $util.dynamodb.toDynamoDBJson($ctx.args.JobName)
    }
}
EOF

  response_template = <<EOF
   $util.toJson($ctx.result)
EOF
}







