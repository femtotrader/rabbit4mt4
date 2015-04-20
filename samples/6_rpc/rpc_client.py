#!/usr/bin/env python
import pika
import uuid
import logging
import click

class FibonacciRpcClient(object):
    def __init__(self, host, username, password, queue):
        credentials = pika.PlainCredentials(username, password)
        parameters = pika.ConnectionParameters(host=host, credentials=credentials)
        self.connection = pika.BlockingConnection(parameters)

        self.channel = self.connection.channel()
        
        self.queue = queue

        result = self.channel.queue_declare(exclusive=True)
        self.callback_queue = result.method.queue

        self.channel.basic_consume(self.on_response, no_ack=True,
                                   queue=self.callback_queue)

    def on_response(self, ch, method, properties, body):
        if self.correlation_id == properties.correlation_id:
            self.response = body

    def call(self, n):
        self.response = None
        self.correlation_id = str(uuid.uuid4())
        print("correlation_id: %s" % self.correlation_id)
        print("reply_to: %s" % self.callback_queue)
        self.channel.basic_publish(exchange='',
                                   routing_key=self.queue,
                                   properties=pika.BasicProperties(
                                         reply_to = self.callback_queue,
                                         correlation_id = self.correlation_id,
                                         ),
                                   body=str(n))
        while self.response is None:
            self.connection.process_data_events()
        return int(self.response)

@click.command()
@click.option('--host', default='localhost', help='host')
@click.option('--username', default='guest', help='loging')
@click.option('--password', default='guest', help='password')
@click.option('--queue', default='rpc_queue', help='queue')
@click.option('--n', default=10, help='n')
def main(host, username, password, queue, n):
    fibonacci_rpc = FibonacciRpcClient(host, username, password, queue)
    print " [x] Requesting fib(%d)" % n
    response = fibonacci_rpc.call(n)
    print " [.] Got %r" % (response,)

if __name__ == '__main__':
    main()