FROM python

RUN apt-get update &&\
    apt-get -y install cmake &&\
    pip install azure-servicebus

WORKDIR /app

COPY service-bus-consumer.py service-bus-producer.py /app/

CMD python -u service-bus-consumer.py