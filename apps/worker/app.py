"""
Worker to consume from specified queue.

Worker then publishes message to the provided Cloud Map service.
"""
import os
import logging

import boto3
from botocore.client import Config
import requests


logging.basicConfig(level=os.environ.get("LOG_LEVEL", "INFO"))
logger = logging.getLogger(__name__)

SQS_CLIENT = boto3.client('sqs',
                          region_name='us-west-2',
                          config=Config(connect_timeout=20, retries={'max_attempts': 0}))
SD_CLIENT = boto3.client('servicediscovery',
                         region_name='us-west-2',
                         config=Config(connect_timeout=20, retries={'max_attempts': 0}))


def validate():
    """
    Validate vars are provided at runtime
    """
    required_envvars = [
        "AWS_REGION",
        "QUEUE_NAME",
        "ACCOUNT_ID",
        "SERVER_PORT",
    ]

    missing_envvars = []
    for required_envvar in required_envvars:
        if not os.environ.get(required_envvar, ''):
            missing_envvars.append(required_envvar)

    if missing_envvars:
        message = "Required environment variables are missing: " + \
            repr(missing_envvars)
        raise AssertionError(message)



def process_message(message_body):
    """
    Get api service instance and publish message via HTTP
    """
    logger.info("Processing message: %s", message_body)
    instances = SD_CLIENT.discover_instances(NamespaceName='development_dns',
                                             ServiceName='development_discovery_service',
                                             HealthStatus='HEALTHY',
                                             QueryParameters={ 'ECS_SERVICE_NAME': 'api' })
    logger.info("instances found: %s", instances)
    ip = instances['Instances'][0]['Attributes']['AWS_INSTANCE_IPV4']
    # from https://docs.aws.amazon.com/cloud-map/latest/api/API_DiscoverInstances.html
    # - `return is randomized to evenly distribute traffic`. Seems imperfect since
    # we'd like to distribute traffic based on something like round robin or CPU utilization.
    port = os.environ["SERVER_PORT"]
    url = "http://{}:{}/message".format(ip, port)
    logger.info("publishing to url: %s", url)
    response = requests.get(url, params={'message': message_body}, timeout=10)
    logger.info("published message response: %s", response)


def main():
    """
    Persistent query of queue with long polling. Process messages and remove from queue
    """
    logger.info("Starting SQS consumer")
    try:
        validate()
    except AssertionError as e:
        logger.error(str(e))
        raise

    try:
        queue = os.environ["QUEUE_NAME"]
        url = SQS_CLIENT.get_queue_url(
            QueueName=queue,
            QueueOwnerAWSAccountId=os.environ["ACCOUNT_ID"]
        )['QueueUrl']
        logger.info("Consuming from queue %s", url)
    except Exception as e:
        logger.error("Failed to get queue %s", e)
        raise

    while True:
        response = SQS_CLIENT.receive_message(
            QueueUrl=url,
            VisibilityTimeout=180,
            MaxNumberOfMessages=5,
            WaitTimeSeconds=20,
        )
        for message in response.get("Messages", []):
            try:
                process_message(message['Body'])
            except Exception as e:
                logger.error("Error processing message: %s ", e)
                continue

            # trying to delete the message
            dlt_response = SQS_CLIENT.delete_message(
                QueueUrl=queue,
                ReceiptHandle=message['ReceiptHandle']
                )
            logger.info("delete response %s", dlt_response)


if __name__ == "__main__":
    main()
