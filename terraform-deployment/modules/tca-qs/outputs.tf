# AWS Current Region
output "aws_current_region" {
  value = data.aws_region.current

}

# S3
output "tca_input_bucket_id" {
  value       = aws_s3_bucket.tca_input_bucket
  description = "The name of the S3 input bucket"
}
output "tca_input_bucket_arn" {
  value       = aws_s3_bucket.tca_input_bucket
  description = "The Arn of the S3 input bucket"
}
output "tca_output_bucket_id" {
  value       = aws_s3_bucket.tca_output_bucket
  description = "The name of the S3 output bucket"
}
output "tca_output_bucket_arn" {
  value       = aws_s3_bucket.tca_output_bucket
  description = "The Arn of the S3 input bucket"
}
output "tca_app_storage_bucket_id" {
  value       = aws_s3_bucket.tca_app_storage_bucket
  description = "The name of the S3 app storage bucket"
}
output "tca_app_storage_bucket_arn" {
  value       = aws_s3_bucket.tca_app_storage_bucket
  description = "The ARN of the S3 app storage bucket"
}
output "tca_quicksight_bucket_id" {
  value       = var.create_tca_quicksight_bucket ? aws_s3_bucket.tca_quicksight_bucket : null
  description = "The name of the S3 app storage bucket"
}
output "tca_quicksight_bucket_arn" {
  value       = var.create_tca_quicksight_bucket ? aws_s3_bucket.tca_quicksight_bucket : null
  description = "The ARN of the S3 app storage bucket"
}
output "tca_s3_logging_bucket_id" {
  value       = var.create_tca_s3_logging_bucket ? aws_s3_bucket.tca_s3_logging_bucket : null
  description = "The name of the S3 logging bucket"
}
output "tca_s3_logging_bucket_arn" {
  value       = aws_s3_bucket.tca_s3_logging_bucket
  description = "The ARN of the S3 logging bucket"
}

# Amplify

# Step Function
output "tca_step_function_arn" {
  value = aws_sfn_state_machine.tca_sfn_state_machine.arn

}

# IAM

# DynamoDB
output "tca_dynamodb_output_table_name" {
  value = aws_dynamodb_table.tca_output.name
}



# Cognito
output "tca_user_pool_region" {
  value = data.aws_region.current
}
output "tca_user_pool_id" {
  value = aws_cognito_user_pool.tca_user_pool
}
output "tca_user_pool_client_id" {
  value = aws_cognito_user_pool_client.tca_user_pool_client
}
output "tca_identity_pool_id" {
  value = aws_cognito_identity_pool.tca_identity_pool
}


# AppSync (GraphQL)
output "tca_appsync_graphql_api_region" {
  value = data.aws_region.current
}
output "tca_appsync_graphql_api_id" {
  value = aws_appsync_graphql_api.tca_appsync_graphql_api
}
output "tca_appsync_graphql_api_uris" {
  value = aws_appsync_graphql_api.tca_appsync_graphql_api
}
