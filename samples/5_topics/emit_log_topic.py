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
@click.option('--routing_key', default='anonymous.info', help='routing_key')
@click.option('--message', default='Hello World!', help='message')
def main(host, username, password, exchange, routing_key, message):
    credentials = pika.PlainCredentials(username, password)
    parameters = pika.ConnectionParameters(host=host, credentials=credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    channel.exchange_declare(exchange=exchange, type='topic')

    channel.basic_publish(exchange=exchange,
                      routing_key=routing_key,
                      body=message)
    print " [x] Sent %r:%r to exchange %r" % (routing_key, message, exchange)
    connection.close()

if __name__ == '__main__':
    main()