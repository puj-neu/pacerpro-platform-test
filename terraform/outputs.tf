output "ec2_instance_id" {
    description = "ID of ec2 instance"
    value = aws_instance.web_app.id
}

output "lambda_function_name" {
    description = "Lambda function name"
    value = aws_lambda_function.restart_ec2.function_name
}

output "sns_alert_topic_arn" {
    description = "ARN of SNS topic alerts"
    value = aws_sns_topic.alerts.arn
}

output "aws_sumo_logiv_topic_arn" {
    description = "ARN of SNS topic for sumo logic"
    value = aws_sns_topic.sumo_logic_alerts.arn
}

