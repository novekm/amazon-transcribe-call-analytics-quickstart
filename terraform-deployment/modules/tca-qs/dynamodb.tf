// TODO - Create TF code for DynamoDB
resource "random_uuid" "tca_output_uuid" {
}
resource "aws_dynamodb_table" "tca_output" {
  name           = "tca_output-${random_uuid.tca_output_uuid.result}" // No touchy
  billing_mode   = var.tca_output_billing_mode
  read_capacity  = var.tca_output_read_capacity
  write_capacity = var.tca_output_write_capacity
  hash_key       = "JobName" // Partition Key
  # range_key      = "-" // Sort Key

  attribute {
    name = "JobName"
    type = "S"
  }


  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

  # Workaround for "ValidationException: TimeToLive is already disabled"
  # when running terraform apply twice
  dynamic "ttl" {
    for_each = local.ttl
    content {
      enabled        = local.ttl[0].ttl_enable
      attribute_name = local.ttl[0].ttl_attribute
    }
  }

  # global_secondary_index {
  #   name               = "GameTitleIndex"
  #   hash_key           = "GameTitle"
  #   range_key          = "TopScore"
  #   write_capacity     = 10
  #   read_capacity      = 10
  #   projection_type    = "INCLUDE"
  #   non_key_attributes = ["UserId"]
  # }

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}
