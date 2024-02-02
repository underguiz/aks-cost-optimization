import os
import random
import string
import time
from azure.identity import DefaultAzureCredential
from azure.servicebus import ServiceBusClient, ServiceBusMessage

HOST_NAME = os.getenv('HOST_NAME')
QUEUE_NAME = os.getenv('QUEUE_NAME')
CLIENT_ID  = os.getenv('AZURE_CLIENT_ID')

credential = DefaultAzureCredential(workload_identity_client_id=CLIENT_ID)

def send_message(sender, content):
    message = ServiceBusMessage(content)
    sender.send_messages(message)
    print("Sent Order ID: " + content)

servicebus_client = ServiceBusClient(HOST_NAME, credential)

with servicebus_client:
    sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)
    with sender:
        chars = string.digits
        while (True):
            content = ''.join(random.choice(chars) for i in range(10))
            send_message(sender, content)
            time.sleep(0.1)