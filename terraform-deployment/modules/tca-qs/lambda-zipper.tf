# Old - Lambda Functions replaced with Step Function Native Service API Calls

# IMPORTANT!!!
# Currently this file will only create the Lambda functions based on
# the content of the code when running 'terraform apply'
# If you make updates to the lambda function(s), you must delete the resource(s)
# and then run another 'terraform apply' - This will re-build the lambda functions
# with the new changes. To destroy just the lambda functions, run the following:
# terraform destroy -target RESOURCE_TYPE.NAME -target RESOURCE_TYPE2.NAME

# This can eventually be fixed by uploading the Lambda function .zip files to an
# S3 bucket and enabling versioning. This would then

#  Info - https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file
# data "archive_file" "tca_invoke_step_function_zip" {
#   type        = "zip"
#   source_file = "${path.module}/lambda-functions/py/tca_invoke_step_function.py"
#   output_path = "${path.module}/lambda-functions/zip/tca_invoke_step_function.zip"
# }
# data "archive_file" "tca_start_call_analytics_job_zip" {
#   type        = "zip"
#   source_file = "${path.module}/lambda-functions/py/tca_start_call_analytics_job.py"
#   output_path = "${path.module}/lambda-functions/zip/tca_start_call_analytics_job.zip"
# }
# data "archive_file" "tca_json_s3_to_s3_cp_zip" {
#   type        = "zip"
#   source_file = "${path.module}/lambda-functions/py/tca_json_s3_to_s3_cp.py"
#   output_path = "${path.module}/lambda-functions/zip/tca_json_s3_to_s3_cp.zip"
# }
# data "archive_file" "tca_s3_to_dynamodb_zip" {
#   type        = "zip"
#   source_file = "${path.module}/lambda-functions/py/tca_s3_to_dynamodb.py"
#   output_path = "${path.module}/lambda-functions/zip/tca_s3_to_dynamodb.zip"
# }
