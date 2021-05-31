data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = var.name
  tags = var.tags
}

resource "aws_iam_role" "this" {
  name_prefix        = "LambdaExecRole-UpdateSGForCF"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:DescribeVpcs",
      "ec2:CreateTags",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:DescribeNetworkInterfaces"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "LambdaExecRolePolicy-UpdateSGForCF"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  filename         = "${path.module}/.archive_files/lambda.zip"
  source_code_hash = data.archive_file.this.output_base64sha256
  handler          = "main.lambda_handler"
  role             = aws_iam_role.this.arn
  runtime          = "python3.8"
  timeout          = 60
  tags             = var.tags

  environment {
    variables = {
      REGION      = var.region
      VPC_ID      = var.vpc_id
      PORTS       = var.ports
      DEBUG       = var.debug
      PREFIX_NAME = var.prefix_name
      SERVICE     = var.service
    }
  }
}

data "archive_file" "this" {
  type        = "zip"
  output_path = "${path.module}/.archive_files/lambda.zip"
  source_file = "main.py"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = "arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged"
}
