# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule

resource "aws_cloudwatch_event_bus" "tca_event_bus" {
  name = "tca_event_bus"
  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}
resource "aws_cloudwatch_event_rule" "default_event_bus_to_tca_event_bus" {
  name        = "default_event_bus_to_tca_event_bus"
  description = "Send all S3 bucket events for tca buckets from default event bus to tca_event_bus"
  // default event bus is used if event_bus_name is not specificed
  # role_arn = var.create_full_access_roles ? aws_iam_role.tca_eventbridge_invoke_step_functions_state_machine_full_access[0].arn : aws_iam_role.tca_eventbridge_invoke_sfn_state_machine_restricted_access[0].arn
  role_arn = aws_iam_role.tca_eventbridge_invoke_custom_tca_event_bus_restricted_access[0].arn
  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail-type = [
      "Object Access Tier Changed",
      "Object ACL Updated",
      "Object Created",
      "Object Deleted",
      "Object Restore Completed",
      "Object Restore Expired",
      "Object Restore Initiated",
      "Object Storage Class Changed",
      "Object Tags Added",
    "Object Tags Deleted"],
    detail = {
      bucket = {
        name = [
          "${aws_s3_bucket.tca_landing_bucket.id}",
          "${aws_s3_bucket.tca_input_bucket.id}",
          "${aws_s3_bucket.tca_output_bucket.id}",
          "${aws_s3_bucket.tca_app_storage_bucket.id}",
          "${aws_s3_bucket.tca_quicksight_bucket.id}",
          "${aws_s3_bucket.tca_s3_logging_bucket.id}",
        ]
      }
    }
  })

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}
resource "aws_cloudwatch_event_rule" "sns_default_event_bus_to_tca_event_bus" {
  name        = "sns_default_event_bus_to_tca_event_bus"
  description = "Send all SNS events for tca sfn failures from default event bus to tca_event_bus"
  // default event bus is used if event_bus_name is not specificed
  # role_arn = var.create_full_access_roles ? aws_iam_role.tca_eventbridge_invoke_step_functions_state_machine_full_access[0].arn : aws_iam_role.tca_eventbridge_invoke_sfn_state_machine_restricted_access[0].arn
  role_arn = aws_iam_role.tca_eventbridge_invoke_custom_tca_event_bus_restricted_access[0].arn
  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail-type = [
      "Object Access Tier Changed",
      "Object ACL Updated",
      "Object Created",
      "Object Deleted",
      "Object Restore Completed",
      "Object Restore Expired",
      "Object Restore Initiated",
      "Object Storage Class Changed",
      "Object Tags Added",
    "Object Tags Deleted"],
    detail = {
      bucket = {
        name = [
          "${aws_s3_bucket.tca_landing_bucket.id}",
          "${aws_s3_bucket.tca_input_bucket.id}",
          "${aws_s3_bucket.tca_output_bucket.id}",
          "${aws_s3_bucket.tca_app_storage_bucket.id}",
          "${aws_s3_bucket.tca_quicksight_bucket.id}",
          "${aws_s3_bucket.tca_s3_logging_bucket.id}",
        ]
      }
    }
  })

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}
resource "aws_cloudwatch_event_rule" "tca_landing_bucket_object_created" {
  name           = "tca_landing_bucket_object_created"
  description    = "Capture each object creation in S3 tca_landing_bucket"
  event_bus_name = aws_cloudwatch_event_bus.tca_event_bus.name
  # role_arn       = var.create_full_access_roles ? aws_iam_role.tca_eventbridge_invoke_step_functions_state_machine_full_access[0].arn : aws_iam_role.tca_eventbridge_invoke_sfn_state_machine_restricted_access[0].arn
  role_arn = aws_iam_role.tca_eventbridge_invoke_sfn_state_machine_restricted_access[0].arn
  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        name = ["${aws_s3_bucket.tca_landing_bucket.id}"]
      }
    }
  })

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

resource "aws_cloudwatch_event_target" "default_event_bus" {
  rule      = aws_cloudwatch_event_rule.default_event_bus_to_tca_event_bus.name
  target_id = "default_event_bus_to_tca_event_bus"
  arn       = aws_cloudwatch_event_bus.tca_event_bus.arn
  role_arn  = aws_iam_role.tca_eventbridge_invoke_custom_tca_event_bus_restricted_access[0].arn
}
resource "aws_cloudwatch_event_target" "tca_step_function" {
  rule           = aws_cloudwatch_event_rule.tca_landing_bucket_object_created.name
  event_bus_name = aws_cloudwatch_event_bus.tca_event_bus.name
  target_id      = "tca_landing_bucket_object_created"
  arn            = aws_sfn_state_machine.tca_sfn_state_machine.arn
  role_arn       = aws_iam_role.tca_eventbridge_invoke_sfn_state_machine_restricted_access[0].arn
}
