import boto3

sns = boto3.resource('sns')
topic = sns.Topic('arn:aws:sns:us-east-1:274251673384:aptos-test-notification')
topic.publish(
    Message='Successfully run the Aptos\' test case.',
    Subject='[AWS SNS] Aptos Test Notification'
)