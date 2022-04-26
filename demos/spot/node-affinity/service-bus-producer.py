import os
import random
import string
from azure.servicebus import ServiceBusClient, ServiceBusMessage

CONNECTION_STR = os.getenv('CONNECTION_STR')
QUEUE_NAME = os.getenv('QUEUE_NAME')

def send_message(sender, content):
    message = ServiceBusMessage(content)
    sender.send_messages(message)
    print("Sent Order ID: " + content)

servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)

with servicebus_client:
    sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)
    with sender:
        letters = string.digits
        while (True):
            content = ''.join(random.choice(letters) for i in range(10))
            send_message(sender, content)