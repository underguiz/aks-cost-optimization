import os
import random
import string
import time
from azure.servicebus import ServiceBusClient, ServiceBusMessage

CONNECTION_STR = os.getenv('CONNECTION_STR')
QUEUE_NAME = os.getenv('QUEUE_NAME')

servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)

with servicebus_client:
    receiver = servicebus_client.get_queue_receiver(queue_name=QUEUE_NAME)
    with receiver:
        for msg in receiver:
            print("Order ID Received: " + str(msg))
            receiver.complete_message(msg)
            time.sleep(1)