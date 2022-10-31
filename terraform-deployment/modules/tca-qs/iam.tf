# TODO - Add descriptions to all Roles, and Policies
# --- TRUST RELATIONSHIPS ---
# Cognito Trust Relationship (AuthRole)
data "aws_iam_policy_document" "tca_cognito_authrole_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
  }
}
# Cognito Trust Relationship (UnauthRole)
data "aws_iam_policy_document" "tca_cognito_unauthrole_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
  }
}
# Cognito Admin Group Trust Relationship
data "aws_iam_policy_document" "tca_cognito_admin_group_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
  }
}
# Cognito Standard Group Trust Relationship
data "aws_iam_policy_document" "tca_cognito_standard_group_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.tca_identity_pool.id]
    }
  }
}
# # Lambda Trust Relationship
# data "aws_iam_policy_document" "tca_lambda_trust_relationship" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#   }
# }

# Eventbridge Trust Relationship
data "aws_iam_policy_document" "tca_eventbridge_trust_relationship" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
# Step Function Trust Relationship
data "aws_iam_policy_document" "tca_step_function_trust_relationship" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com", "transcribe.amazonaws.com"]
    }
  }
}
# AppSync Trust Relationship
data "aws_iam_policy_document" "tca_appsync_trust_relationship" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }
}


# Amplify Trust Relationship
data "aws_iam_policy_document" "tca_amplify_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}


# --- CUSTOMER MANAGED POLICIES (RESTRICTED ACCESS) ---
# - S3 Policies-
# S3 Customer Managed Policy (Restricted Access)
data "aws_iam_policy_document" "tca_s3_restricted_access_policy" {
  count = var.create_restricted_access_roles ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    # Allows all S3 operations for files matching the below suffixes
    resources = [
      "${aws_s3_bucket.tca_landing_bucket.arn}",
      "${aws_s3_bucket.tca_landing_bucket.arn}/*",
      "${aws_s3_bucket.tca_input_bucket.arn}",
      "${aws_s3_bucket.tca_input_bucket.arn}/*",
      "${aws_s3_bucket.tca_output_bucket.arn}",
      "${aws_s3_bucket.tca_output_bucket.arn}/*",
      "${aws_s3_bucket.tca_app_storage_bucket.arn}",
      "${aws_s3_bucket.tca_app_storage_bucket.arn}/*",
      "${aws_s3_bucket.tca_quicksight_bucket.arn}",
      "${aws_s3_bucket.tca_quicksight_bucket.arn}/*",
      "${aws_s3_bucket.tca_s3_logging_bucket.arn}",
      "${aws_s3_bucket.tca_s3_logging_bucket.arn}/*",
    ]
  }
}
resource "aws_iam_policy" "tca_s3_restricted_access_policy" {
  count  = var.create_restricted_access_roles ? 1 : 0
  name   = "tca_s3_restricted_access_policy"
  policy = data.aws_iam_policy_document.tca_s3_restricted_access_policy[0].json
}

# - DynamoDB Policies -
# DynamoDB Customer Managed Policy (All Actions)
data "aws_iam_policy_document" "tca_dynamodb_restricted_access_policy" {
  count = var.create_restricted_access_roles ? 1 : 0
  # description = "Policy granting full DynamoDB permissions for the tca_output DynamoDB table."
  statement {
    effect  = "Allow"
    actions = ["dynamodb:*"]
    resources = [
      "${aws_dynamodb_table.tca_output.arn}",
    ]
  }
}
resource "aws_iam_policy" "tca_dynamodb_restricted_access_policy" {
  count       = var.create_restricted_access_roles ? 1 : 0
  name        = "tca_dynamodb_restricted_access_policy"
  description = "Policy granting full DynamoDB permissions for the tca_output DynamoDB table."
  policy      = data.aws_iam_policy_document.tca_dynamodb_restricted_access_policy[0].json

}

# DynamoDB Customer Managed Policy (Read Only Actions)
data "aws_iam_policy_document" "tca_dynamodb_restricted_access_read_only_policy" {
  count = var.create_restricted_access_roles ? 1 : 0
  # description = "Policy granting full DynamoDB permissions for the tca_output DynamoDB table."
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
    ]
    resources = [
      "${aws_dynamodb_table.tca_output.arn}",
    ]
  }
}
resource "aws_iam_policy" "tca_dynamodb_restricted_access_read_only_policy" {
  count       = var.create_restricted_access_roles ? 1 : 0
  name        = "tca_dynamodb_restricted_access_read_only_policy"
  description = "Policy granting restricted (read-only) DynamoDB permissions for the tca_output DynamoDB table."
  policy      = data.aws_iam_policy_document.tca_dynamodb_restricted_access_read_only_policy[0].json

}

# - SSM Policies -
# SSM Customer Managed Policy (Restricted Access)
data "aws_iam_policy_document" "tca_ssm_restricted_access_policy" {
  count = var.create_restricted_access_roles ? 1 : 0
  # description = "Policy granting full DynamoDB permissions for the tca_output DynamoDB table."
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
    ]
    resources = [
      "${aws_ssm_parameter.tca_input_bucket_name.arn}",
      "${aws_ssm_parameter.tca_output_bucket_name.arn}",
      "${aws_ssm_parameter.tca_app_storage_bucket_name.arn}",
      "${aws_ssm_parameter.tca_dynamodb_output_table_name.arn}",
    ]
  }
}
resource "aws_iam_policy" "tca_ssm_restricted_access_policy" {
  count  = var.create_restricted_access_roles ? 1 : 0
  name   = "tca_ssm_restricted_access_policy"
  policy = data.aws_iam_policy_document.tca_ssm_restricted_access_policy[0].json

}

# - Lambda Policies -
# Lambda Invoke Step Functions Customer Managed Policy (Restricted Access)
# Allows Lambda function to invoke Step Function State machine
# data "aws_iam_policy_document" "tca_lambda_invoke_sfn_state_machine_restricted_access_policy" {
#   count = var.create_restricted_access_roles ? 1 : 0
#   # description = "Policy granting full DynamoDB permissions for the tca_output DynamoDB table."
#   statement {
#     effect = "Allow"
#     actions = [
#       "states:*",
#     ]
#     resources = [
#       "${aws_sfn_state_machine.tca_sfn_state_machine.arn}",
#     ]
#   }
# }
# resource "aws_iam_policy" "tca_lambda_invoke_sfn_state_machine_restricted_access_policy" {
#   count  = var.create_restricted_access_roles ? 1 : 0
#   name   = "tca_lambda_invoke_sfn_state_machine_restricted_access_policy"
#   policy = data.aws_iam_policy_document.tca_lambda_invoke_sfn_state_machine_restricted_access_policy[0].json
# }



# - Eventbridge Policies -
# Eventbridge Invoke Custom TCA Event Bus Customer Managed Policy (Restricted Access)

data "aws_iam_policy_document" "tca_eventbridge_invoke_custom_tca_event_bus_restricted_access_policy" {
  count = var.create_restricted_access_roles ? 1 : 0
  # description = "Policy granting full DynamoDB permissions for the tca_output DynamoDB table."
  statement {
    effect = "Allow"
    actions = [
      "events:PutEvents",
    ]
    resources = [
      "${aws_cloudwatch_event_bus.tca_event_bus.arn}",
    ]
  }
}
resource "aws_iam_policy" "tca_eventbridge_invoke_custom_tca_event_bus_restricted_access_policy" {
  count  = var.create_restricted_access_roles ? 1 : 0
  name   = "tca_eventbridge_invoke_custom_tca_event_bus_restricted_access_policy"
  policy = data.aws_iam_policy_document.tca_eventbridge_invoke_custom_tca_event_bus_restricted_access_policy[0].json
}

# Eventbridge Invoke Step Functions Customer Managed Policy (Restricted Access)
# Allows EventBridge to invoke Step Function State machine
data "aws_iam_policy_document" "tca_eventbridge_invoke_sfn_state_machine_restricted_access_policy" {
  count = var.create_restricted_access_roles ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "states:*",
    ]
    resources = [
      "${aws_sfn_state_machine.tca_sfn_state_machine.arn}",
    ]
  }
}
resource "aws_iam_policy" "tca_eventbridge_invoke_sfn_state_machine_restricted_access_policy" {
  count  = var.create_restricted_access_roles ? 1 : 0
  name   = "tca_eventbridge_invoke_sfn_state_machine_restricted_access_policy"
  policy = data.aws_iam_policy_document.tca_eventbridge_invoke_sfn_state_machine_restricted_access_policy[0].json
}


# --- IAM ROLES ---
# - Cognito Roles -
# Cognito AuthRole Restricted Access
# Role granting restricted access permissions to Cognito authenticated users
resource "aws_iam_role" "tca_cognito_authrole_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count = var.create_restricted_access_roles ? 1 : 0

  name               = "tca_authRole_restricted_access"
  assume_role_policy = data.aws_iam_policy_document.tca_cognito_authrole_trust_relationship.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
    aws_iam_policy.tca_ssm_restricted_access_policy[0].arn
  ]

  force_detach_policies = true
  path                  = "/${var.app_name}/"
  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}
# Cognito UnAuth Role
# Role granting restricted access permissions to Cognito authenticated users
resource "aws_iam_role" "tca_cognito_unauthrole_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count              = var.create_restricted_access_roles ? 1 : 0
  name               = "tca_unauthRole_restricted_access"
  assume_role_policy = data.aws_iam_policy_document.tca_cognito_unauthrole_trust_relationship.json

  # Managed Policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]

  force_detach_policies = true
  path                  = "/${var.app_name}/"
  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

# Cognito Admin Group Role (Restricted Access)
resource "aws_iam_role" "tca_cognito_admin_group_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count = var.create_restricted_access_roles ? 1 : 0

  name               = "tca_cognito_admin_group_restricted_access"
  assume_role_policy = data.aws_iam_policy_document.tca_cognito_admin_group_trust_relationship.json
  description        = "Role granting full DynamoDB permissions for the tca_outputs DynamoDB table."
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
    aws_iam_policy.tca_dynamodb_restricted_access_policy[0].arn
  ]

  force_detach_policies = true
  path                  = "/${var.app_name}/"
  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

# Cognito Standard Group Role (Restricted Access)
resource "aws_iam_role" "tca_cognito_standard_group_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count = var.create_restricted_access_roles ? 1 : 0

  name               = "tca_cognito_standard_group_restricted_access"
  assume_role_policy = data.aws_iam_policy_document.tca_cognito_standard_group_trust_relationship.json
  description        = "Role granting restricted (read-only) DynamoDB permissions for the tca_outputs DynamoDB table."
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
    aws_iam_policy.tca_dynamodb_restricted_access_read_only_policy[0].arn
  ]

  force_detach_policies = true
  path                  = "/${var.app_name}/"
  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

# - AppSync Roles -
# AppSync Restricted Access Role
# Role granting AppSync DynamoDB restricted access, SSM restricted read-only access, and the ablity to access to CloudWatch Logs.
resource "aws_iam_role" "tca_appsync_dynamodb_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count              = var.create_restricted_access_roles ? 1 : 0
  name               = "tca_appsync_dynamodb_restricted_access"
  assume_role_policy = data.aws_iam_policy_document.tca_appsync_trust_relationship.json
  # Managed Policies
  managed_policy_arns = [
    aws_iam_policy.tca_dynamodb_restricted_access_policy[0].arn,
    aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ]
  force_detach_policies = true
  path                  = "/${var.app_name}/"
  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

# # - Lambda Roles -
# # Lambda Transcribe Restricted Access
# # Role granting Lambda function S3 restricted access, SSM full read-only access, Transcribe Full Access, and the ablity to access to CloudWatch Logs.
# resource "aws_iam_role" "tca_lambda_transcribe_restricted_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_restricted_access_roles ? 1 : 0
#   name               = "tca_lambda_transcribe_restricted_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json

#   # Managed Policies
#   managed_policy_arns = [
#     aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
#     aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
#     "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess",
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"
#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }
# # Lambda Transcribe Full Access
# # Role granting Lambda function S3 full access, SSM full read-only access, Transcribe Full Access, and the ablity to access to CloudWatch Logs.
# resource "aws_iam_role" "tca_lambda_transcribe_full_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_full_access_roles ? 1 : 0
#   name               = "tca_lambda_transcribe_full_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json

#   # Managed Policies
#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess",
#     "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"
#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }

# Lambda S3 to DynamoDB Restricted Access
# Role granting Lambda function S3 restricted access, SSM restricted read-only access, and the ablity to access to CloudWatch Logs.
# resource "aws_iam_role" "tca_lambda_s3_to_dynamodb_restricted_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_restricted_access_roles ? 1 : 0
#   name               = "tca_lambda_s3_to_dynamodb_restricted_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json
#   managed_policy_arns = [
#     aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
#     aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"

#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }
# # Lambda S3 to DynamoDB Full Access
# # Role granting Lambda function S3 full access, SSM full read-only access, and the ablity to access to CloudWatch Logs.
# resource "aws_iam_role" "tca_lambda_s3_to_dynamodb_full_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_full_access_roles ? 1 : 0
#   name               = "tca_lambda_s3_to_dynamodb_full_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json

#   # Managed Policies
#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"

#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }

# Lambda S3 Restricted Access
# Role granting Lambda function S3 restricted access, SSM restricted read-only access, and the ablity to access to CloudWatch Logs.
# resource "aws_iam_role" "tca_lambda_s3_restricted_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_restricted_access_roles ? 1 : 0
#   name               = "tca_lambda_s3_restricted_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json

#   # Managed Policies
#   managed_policy_arns = [
#     aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
#     aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"

#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }
# # Lambda S3 Full Access
# # Role granting Lambda function S3 full access, SSM full read-only access, and the ablity to access to CloudWatch Logs.
# resource "aws_iam_role" "tca_lambda_s3_full_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_full_access_roles ? 1 : 0
#   name               = "tca_lambda_s3_full_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json

#   # Managed Policies
#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"

#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }

# Lambda Functions Invoke State Machine Restricted Access
# Role granting Lambda function S3 restricted access, SSM restricted read-only access, and the ablity to access to CloudWatch Logs.
# Role allows Lambda Function to invoke Step Function state machine
# resource "aws_iam_role" "tca_lambda_invoke_sfn_state_machine_restricted_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_restricted_access_roles ? 1 : 0
#   name               = "tca_lambda_invoke_sfn_state_machine_restricted_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json
#   # Managed Policies
#   managed_policy_arns = [
#     aws_iam_policy.tca_lambda_invoke_sfn_state_machine_restricted_access_policy[0].arn,
#     aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
#     aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"

#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }
# # Lambda Functions Invoke State Machine Full Access
# # Role granting Lambda function S3 full access, SSM full read-only access, and the ablity to access to CloudWatch Logs.
# # Role allows Lambda Function to invoke Step Function state machine
# resource "aws_iam_role" "tca_lambda_invoke_step_functions_state_machine_full_access" {
#   # Conditional create of the role - default is 'TRUE'
#   count              = var.create_full_access_roles ? 1 : 0
#   name               = "tca_lambda_invoke_step_functions_state_machine_full_access"
#   assume_role_policy = data.aws_iam_policy_document.tca_lambda_trust_relationship.json
#   # Managed Policies
#   managed_policy_arns = [
#     aws_iam_policy.tca_lambda_invoke_step_functions_state_machine_full_access_policy[0].arn,
#     "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
#     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#   ]

#   force_detach_policies = true
#   path                  = "/${var.app_name}/"

#   tags = merge(
#     {
#       "AppName" = var.app_name
#     },
#     var.tags,
#   )
# }


# - Eventbridge Roles -

# Eventbrige Invoke Step Functions Restricted Access
# Role granting Eventbridge S3 restricted access, SSM restricted read-only access, and the ablity to access to CloudWatch Logs.
# Role allows Eventbridge to invoke step functions
resource "aws_iam_role" "tca_eventbridge_invoke_custom_tca_event_bus_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count              = var.create_restricted_access_roles ? 1 : 0
  name               = "tca_eventbridge_invoke_custom_tca_event_bus_restricted_access"
  assume_role_policy = data.aws_iam_policy_document.tca_eventbridge_trust_relationship.json
  # Managed Policies
  managed_policy_arns = [
    aws_iam_policy.tca_eventbridge_invoke_custom_tca_event_bus_restricted_access_policy[0].arn,
    # aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
    # aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ]

  force_detach_policies = true
  path                  = "/${var.app_name}/"

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}
# Eventbrige Invoke Step Functions Restricted Access
# Role granting Eventbridge S3 restricted access, SSM restricted read-only access, and the ablity to access to CloudWatch Logs.
# Role allows Eventbridge to invoke step functions
resource "aws_iam_role" "tca_eventbridge_invoke_sfn_state_machine_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count              = var.create_restricted_access_roles ? 1 : 0
  name               = "tca_eventbridge_invoke_sfn_state_machine_restricted_access"
  assume_role_policy = data.aws_iam_policy_document.tca_eventbridge_trust_relationship.json
  # Managed Policies
  managed_policy_arns = [
    aws_iam_policy.tca_eventbridge_invoke_sfn_state_machine_restricted_access_policy[0].arn,
    aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
    aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ]

  force_detach_policies = true
  path                  = "/${var.app_name}/"

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

# - Step Function Roles -
# Step Functions Master Role Restricted Access
# Role granting Step Functions S3 restricted access, SSM restricted read-only access,
# DynamoDB restricted access, Transcribe full access and the ablity to access to CloudWatch Logs.
# Role allows Step Function to invoke lambda functions
resource "aws_iam_role" "tca_step_functions_master_restricted_access" {
  # Conditional create of the role - default is 'TRUE'
  count              = var.create_restricted_access_roles ? 1 : 0
  name               = "tca_step_functions_master_restricted_access"
  description        = "Master step function role that grants S3 restricted access, SSM restricted access, DynamoDB restricted access as well as Transcribe and CloudWatch full access. "
  assume_role_policy = data.aws_iam_policy_document.tca_step_function_trust_relationship.json
  # Managed Policies
  managed_policy_arns = [
    aws_iam_policy.tca_s3_restricted_access_policy[0].arn,
    aws_iam_policy.tca_ssm_restricted_access_policy[0].arn,
    aws_iam_policy.tca_dynamodb_restricted_access_policy[0].arn,
    "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ]

  force_detach_policies = true
  path                  = "/${var.app_name}/"

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

# Amplify

resource "aws_iam_role" "tca_amplify_codecommit" {
  name                = "tca_amplify_codecommit"
  assume_role_policy  = data.aws_iam_policy_document.tca_amplify_trust_relationship.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"]
}

# GitLab
resource "aws_iam_user" "tca_gitlab_mirroring" {
  count         = var.tca_enable_gitlab_mirroring ? 1 : 0
  name          = var.tca_gitlab_mirroring_iam_user_name
  path          = "/${var.app_name}/"
  force_destroy = true // prevents DeleteConflict Error

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}

resource "aws_iam_user_policy" "tca_gitlab_mirroring_policy" {
  count = var.tca_enable_gitlab_mirroring ? 1 : 0
  name  = var.tca_gitlab_mirroring_policy_name
  user  = aws_iam_user.tca_gitlab_mirroring[0].name


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "MinimumGitLabMirroringPermissions"
      Action = ["codecommit:GitPull", "codecommit:GitPush"]
      Effect = "Allow"
      Resource = [
        "${aws_codecommit_repository.tca_codecommit_repo[0].arn}"
      ]
    }]

  })

}







