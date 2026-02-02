import boto3 
import os 
import datetime
import json

ec2_client = boto3.client('ec2')
sns_client = boto3.client('sns')

def lambda_handler(event, context):

    try: 
        if 'Records' in event:
            message = json.loads(event['Records'][0]['Sns']['Message'])
        else:
            message = event
        instance_id = message.get('instance_id',os.environ.get('INSTANCE_ID'))

    except Exception as e:
        print(f"Error parsing event {str(e)}")
        instance_id = os.environ.get('INSTANCE_ID')

    timestamp = datetime.datetime.now().isoformat()
    log_message = f"[{timestamp}] Restarting instance {instance_id} due to high response time."
    print(log_message)

    try:
        response = ec2_client.reboot_instances(InstanceIds=[instance_id],DryRun = False)
        print(f"EC2 reboot initiated: {response}")
        sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
        sns_response = sns_client.publish(TopicArn = sns_topic_arn, Subject = "Ec2 Instance Rebooted- Performance Alert", Message = f"""
                                          Alert: high response time detected
                                          Action: Instance restarted
                                          Instance: {instance_id}
                                          Trigger: /api/data response time >3s (for 5+ reuquests in 10m)
                                          Timestamp: {timestamp}
                                          """.strip() )
        print(f"SNS notification sent: {sns_response}")

        return {
            'statusCode': 200,
            'body': json.dumps('Success')
        }

    except Exception as e:
        error_message = (f"Error rebooting EC2 instance: {str(e)}")
        print(error_message)

        if sns_topic_arn:
            sns_response = sns_client.publish(TopicArn = sns_topic_arn, Subject = "Ec2 Instance Reboot Failed", Message = error_message)
            return {
                'statusCode': 500,
                'body': json.dumps('Error')
            
            }