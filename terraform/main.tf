terraform {
  required_version = ">=1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
  }
  archive = {
    source = "hashicorp/archive"
    version = "~>2.4"
  }
}
}

provider "aws" {
    region = var.aws_region
}

resource "aws_instance" "web_app" {
  ami = var.ec2_ami_id
  instance_type = var.ec2_instance_type

  tags = {
    Name = "${var.project_name}--web-app"
    ManagedBy = "terraform"

}
}

resource "aws_sns_topic" "alerts" {
  name="${var.project_name}--alerts"
}

resource "aws_sns_topic_subscription" "email" {
    topic_arn = aws_sns_topic.alerts.arn
    protocol = "email"
    endpoint = var.alert_email
}
  
resource "aws_sns_topic" "sumo_logic_alerts" {
  name = "${var.project_name}--sumo-logic-alerts"
}

data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "${path.module}/../lambda_function/lambda_function.py"
    output_path = "${path.module}/../lambda_function.zip"
}


resource "aws_lambda_function" "restart_ec2" {
 filename = data.archive_file.lambda_zip.output_path
 function_name = "${var.project_name}--restart-ec2"
 role = aws_iam_role.lambda_role.arn
 handler = "lambda_function.lambda_handler"
 runtime = "python3.10"
 timeout = 30
 source_code_hash = data.archive_file.lambda_zip.output_base64sha256
 environment {
   variables = {
    INSTANCE_ID = aws_instance.web_app.id
    SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
   }
 }
}

resource "aws_lambda_permission" "allows-sns" {
    statement_id = "AllowExecutionFromSns"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.restart_ec2.function_name
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.alerts.arn
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.sumo_logic_alerts.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.restart_ec2.arn
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.restart_ec2.function_name}"
  retention_in_days = 7
}


