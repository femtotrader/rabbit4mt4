#!/usr/bin/env python
import pika
import sys
import logging
import click

@click.command()
@click.option('--host', default='localhost', help='host')
@click.option('--username', default='guest', help='loging')
@click.option('--password', default='guest', help='password')
@click.option('--exchange', default='topic_logs', help='exchange')
@click.option('--binding_keys', default='#', help='routing_key')
def main(host, username, password, exchange, binding_keys):
    credentials = pika.PlainCredentials(username, password)
    parameters = pika.ConnectionParameters(host=host, credentials=credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    channel.exchange_declare(exchange=exchange, type='topic')

    result = channel.queue_declare(exclusive=True)
    queue_name = result.method.queue

    for binding_key in binding_keys.split(','):
        channel.queue_bind(exchange=exchange,
                       queue=queue_name,
                       routing_key=binding_key)

    print(" [*] Waiting for message on exchange '%s'. To exit press CTRL+C" % exchange)

    def callback(ch, method, properties, body):
        print " [x] %r:%r" % (method.routing_key, body,)

    channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)

    channel.start_consuming()

if __name__ == '__main__':
    main()