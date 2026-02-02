# PacerPro Platform Engineer - Coding Test
**Author:** Puja Kalivarapu | **Date:** February 2026

## Overview
Automated infrastructure remediation system that detects performance degradation via Sumo Logic monitoring and self-heals by restarting affected EC2 instances with operator notifications.

## Architecture
```
Sumo Logic Alert → SNS Topic → Lambda Function
                                      ├─→ EC2 Restart (RebootInstances)
                                      └─→ Email Notification (SNS)
```

## Technical Context
This solution demonstrates production platform engineering practices developed through:
- 3+ years at Hewlett Packard Enterprise R&D building distributed systems (1M+ concurrent users)
- GoLang microservices with Kafka messaging and event-driven architectures
- Hands-on experience with Terraform, AWS Lambda, CI/CD pipelines, and infrastructure monitoring
- Current work at Fidelity Investments on ETL pipelines and cloud automation

## Features
✅ **Event-Driven Automation** - Serverless Lambda triggered by monitoring alerts  
✅ **Infrastructure as Code** - Complete Terraform configuration with modular design  
✅ **Least-Privilege Security** - Resource-specific IAM policies (no wildcard permissions)  
✅ **Production-Ready** - Comprehensive error handling, logging, and monitoring  
✅ **Cost-Optimized** - Free-tier eligible architecture  

## Tech Stack
- **AWS Lambda** (Python 3.11 + boto3) - Serverless automation
- **Terraform** (v1.0+) - Infrastructure as Code
- **AWS IAM** - Least-privilege security with resource-specific ARNs
- **CloudWatch Logs** - Centralized monitoring and audit trail
- **SNS** - Event routing and email notifications
- **Sumo Logic** - Log aggregation and alerting

## Project Structure
```
.
├── README.md                    # This file
├── sumo_logic_query.txt        # Part 1: Sumo Logic query and alert config
├── lambda_function/
│   ├── lambda_function.py      # Part 2: Lambda automation code
│   └── requirements.txt
├── terraform/
│   ├── main.tf                 # Part 3: Core infrastructure
│   ├── iam.tf                  # Least-privilege IAM policies
│   ├── variables.tf            # Input configuration
│   └── outputs.tf              # Resource outputs
└── recordings/
    └── links.md                # Links to screen recordings
```

## Quick Start

### Prerequisites
- AWS CLI configured with credentials
- Terraform >= 1.0 installed
- Valid email for SNS notifications

### Deployment
```bash
# 1. Update configuration
cd terraform
# Create terraform.tfvars with your values:
# alert_email = "your-email@example.com"
# ec2_ami_id = "ami-XXXXX"

# 2. Deploy infrastructure
terraform init
terraform plan
terraform apply

# 3. Confirm SNS email subscription (check inbox)

# 4. Test Lambda
aws lambda invoke \
  --function-name $(terraform output -raw lambda_function_name) \
  --payload '{}' \
  response.json

cat response.json

# 5. Check logs
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_name) --since 5m
```

### Cleanup
```bash
terraform destroy
```

## Assumptions & Design Decisions

### Part 1: Sumo Logic Query
- **Log Format**: JSON with `endpoint` and `response_time_ms` fields
- **Alert Mechanism**: Webhook to SNS topic
- **Time Window**: 10 minutes (rolling) with 5-request threshold

### Part 2: Lambda Function
- **Trigger**: SNS subscription from Sumo Logic alerts
- **Configuration**: Environment variables for instance ID and SNS topic
- **Error Handling**: Comprehensive try-catch with failure notifications
- **Logging**: CloudWatch Logs with ISO-formatted timestamps

### Part 3: Terraform
- **Security**: Least-privilege IAM with resource-specific ARNs
- **Modularity**: Separated IAM policies in dedicated file
- **Automation**: Environment variables auto-injected by Terraform
- **Cost**: 7-day log retention, free-tier eligible resources

## Security Best Practices (Bonus)

### Least-Privilege IAM Implementation
✅ **EC2 Permissions**: Only `RebootInstances` on specific instance ARN  
✅ **SNS Permissions**: Only `Publish` to specific topic ARN  
✅ **CloudWatch**: Scoped to Lambda function's log group  
✅ **No Wildcards**: All policies use explicit resource identifiers  

**Example - EC2 Reboot Policy:**
```hcl
{
  "Effect": "Allow",
  "Action": "ec2:RebootInstances",
  "Resource": "arn:aws:ec2:region:account:instance/i-SPECIFIC-ID"
}
```

**Why this matters:** Limits blast radius if credentials are compromised. An attacker could only restart one specific instance, not the entire infrastructure.

## Testing Performed
1. ✅ Sumo Logic query syntax validated
2. ✅ Lambda function manual invocation - successful EC2 restart
3. ✅ SNS email notifications received and verified
4. ✅ CloudWatch Logs showing complete execution trail
5. ✅ Terraform deployment successful - all 15 resources created
6. ✅ IAM policies validated with resource-specific ARNs
7. ✅ End-to-end flow tested and verified


## Contact
**Email:** pkalivarapu@gmail.com  
