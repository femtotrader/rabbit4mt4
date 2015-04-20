#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pika
import logging
import click

@click.command()
@click.option('--host', default='localhost', help='host')
@click.option('--username', default='guest', help='loging')
@click.option('--password', default='guest', help='password')
@click.option('--queue', default='rpc_queue', help='queue')
def main(host, username, password, queue):
    credentials = pika.PlainCredentials(username, password)
    parameters = pika.ConnectionParameters(host=host, credentials=credentials)
    connection = pika.BlockingConnection(parameters)

    channel = connection.channel()

    channel.queue_declare(queue=queue)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(on_request, queue=queue)

    print " [x] Awaiting RPC requests"
    channel.start_consuming()

def fib(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fib(n-1) + fib(n-2)

def on_request(ch, method, properties, body):
    n = int(body)

    print " [.] fib(%s)"  % (n,)
    response = fib(n)
    
    print("correlation_id: %s" % properties.correlation_id)
    print("reply_to: %s" % properties.reply_to)

    ch.basic_publish(exchange='',
                     routing_key=properties.reply_to,
                     properties=pika.BasicProperties(correlation_id = \
                                                     properties.correlation_id),
                     body=str(response))
    ch.basic_ack(delivery_tag = method.delivery_tag)

if __name__ == '__main__':
    main()