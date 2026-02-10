## Lambda IAM role

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "apigateway.amazonaws.com", "states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.app_name}-lambda-exec"
  tags               = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-lambda-exec" }))
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:ListAllMyBuckets",
      "s3:GetObjectTagging",
      "s3:ListBucket",
      "s3:PutObjectTagging",
      "s3:GetBucketLocation",
      "s3:PutObjectAcl",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "ssm:PutParameters",
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:DeleteParameters",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:PutSecretValue",
      "secretsmanager:RotateSecret"
    ]
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:secret:${var.app_name}-*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "secretsmanager:GetRandomPassword"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "logs:ListLogDeliveries",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:log-group:/aws/lambda/${var.app_name}*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "kms:ListAliases",
      "kms:ListKeyPolicies",
      "kms:ListResourceTags",
      "kms:ListGrants",
      "kms:ListKeys",
      "kms:ListRetirableGrants",
      "kms:DescribeCustomKeyStores",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetParametersForImport",
      "kms:GetKeyRotationStatus",
      "kms:GetPublicKey",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:CancelKeyDeletion",
      "kms:ConnectCustomKeyStore",
      "kms:CreateAlias",
      "kms:CreateCustomKeyStore",
      "kms:CreateKey",
      "kms:Decrypt",
      "kms:DeleteAlias",
      "kms:DeleteCustomKeyStore",
      "kms:DeleteImportedKeyMaterial",
      "kms:DisableKey",
      "kms:DisableKeyRotation",
      "kms:DisconnectCustomKeyStore",
      "kms:EnableKey",
      "kms:EnableKeyRotation",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyPair",
      "kms:GenerateDataKeyWithoutPlainText",
      "kms:GenerateDataKeyPairWithoutPlainText",
      "kms:GenerateMac",
      "kms:GenerateRandom",
      "kms:ImportKeyMaterial",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:ReplicateKey",
      "kms:ScheduleKeyDeletion",
      "kms:Sign",
      "kms:SynchronizeMultiRegionKey",
      "kms:UpdateAlias",
      "kms:UpdateCustomKeyStore",
      "kms:UpdateKeyDescription",
      "kms:UpdatePrimaryRegion",
      "kms:Verify",
      "kms:VerifyMac",
      "kms:CreateGrant",
      "kms:PutKeyPolicy",
      "kms:RetireGrant",
      "kms:RevokeGrant"
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:alias/*",
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:key/*"
    ]
  }
  statement {
    effect  = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunction",
      "lambda:GetAlias",
      "lambda:ListFunctions",
      "lambda:ListAliases",
      "lambda:ListVersionsByFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:function:${var.app_name}*"
    ]
  }
  # statement {
  #   effect    = "Allow"
  #   actions   = ["execute-api:Invoke"]
  #   resources = [
  #     "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:${aws_api_gateway_rest_api.api_gateway.id}/*/*/*"
  #   ]
  # }
  statement {
    effect  = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeStream",
      "dynamodb:GetShardIterator",
      "dynamodb:GetRecords",
      "dynamodb:DeleteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:table/${var.app_name}*",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:table/*/index/*",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:table/*/stream/*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "${var.app_name}-lambda-role-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}



