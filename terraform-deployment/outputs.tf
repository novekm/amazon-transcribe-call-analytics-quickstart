# AWS Current Region
output "aws_current_region" {
  value = "AWS Region: ${module.tca-qs.aws_current_region.name}"
}

# S3
output "tca_input_bucket" {
  value       = module.tca-qs.tca_input_bucket_id.id
  description = "The name of the S3 input bucket"
}
output "tca_output_bucket" {
  value       = module.tca-qs.tca_output_bucket_id.id
  description = "The name of the S3 output bucket"
}
output "tca_app_storage_bucket" {
  value       = module.tca-qs.tca_app_storage_bucket_id.id
  description = "The name of the S3 app storage bucket"
}
# output "tca_quicksight_bucket" {
#   value       = var.create_tca_quicksight_bucket ? aws_s3_bucket.tca_quicksight_bucket.arn : null
#   description = "The name of the S3 Quicksight storage bucket"
# }
# output "tca_quicksight_bucket" {
#   value       = var.create_tca_quicksight_bucket ? aws_s3_bucket.tca_quicksight_bucket.arn : null
#   description = "The name of the S3 Quicksight storage bucket"
# }


output "tca_s3_logging_bucket" {
  value       = module.tca-qs.tca_s3_logging_bucket_id.id
  description = "The name of the S3 logging bucket"

}


# Amplify

# Step Function

# IAM

# DynamoDB

# Cognito
output "tca_user_pool_region" {
  value = module.tca-qs.tca_user_pool_region.name
}
output "tca_user_pool_id" {
  value = module.tca-qs.tca_user_pool_id.id
}
output "tca_user_pool_client" {
  value = module.tca-qs.tca_user_pool_client_id.id
}
output "tca_identity_pool" {
  value = module.tca-qs.tca_identity_pool_id.id
}

# AppSync (GraphQL)
output "tca_appsync_graphql_api_region" {
  value = module.tca-qs.tca_appsync_graphql_api_region.name
}
output "tca_appsync_graphql_api_id" {
  value = module.tca-qs.tca_appsync_graphql_api_id.id
}
output "tca_appsync_graphql_api_uris" {
  value = module.tca-qs.tca_appsync_graphql_api_uris.uris
}

