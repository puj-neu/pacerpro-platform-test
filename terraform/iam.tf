resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}--lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
            Sid = ""
            Effect = "Allow"
        },
    ]
  })

}

resource "aws_iam_policy" "ec2_reboot" {
  name = "${var.project_name}--ec2-reboot"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = ["ec2:RebootInstances"]
            Resource = aws_instance.web_app.arn
            Effect = "Allow"
        },
        {
            Action = ["ec2:DescribeInstances","ec2:DescribeInstanceStatus"]
            Resource = "*"
            Effect = "Allow"
        }
        
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ec2_reboot.arn
}


resource "aws_iam_policy" "sns_publish" {
  name = "${var.project_name}--sns-publish"
  policy = jsonencode({

    Version = "2012-10-17"
    Statement = [
        {
            Action = ["sns:Publish"]
            Resource = aws_sns_topic.alerts.arn
            Effect = "Allow"
        }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "sns" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.sns_publish.arn
}

resource "aws_iam_policy" "lambda_logging" {
  name = "${var.project_name}--lambda-logging"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
            Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}--restart-ec2:*"
            Effect = "Allow"
        }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.lambda_logging.arn
}


  
  