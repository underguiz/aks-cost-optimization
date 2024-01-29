import os
import time
from azure.identity import DefaultAzureCredential
from azure.servicebus import ServiceBusClient

HOST_NAME  = os.getenv('HOST_NAME')
QUEUE_NAME = os.getenv('QUEUE_NAME')
CLIENT_ID  = os.getenv('AZURE_CLIENT_ID')

credential = DefaultAzureCredential(managed_identity_client_id=CLIENT_ID)

servicebus_client = ServiceBusClient(HOST_NAME, credential)

with servicebus_client:
    receiver = servicebus_client.get_queue_receiver(queue_name=QUEUE_NAME)
    with receiver:
        for msg in receiver:
            print("Order ID Received: " + str(msg))
            receiver.complete_message(msg)
            time.sleep(0.1)