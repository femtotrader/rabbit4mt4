#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pika
import click
import logging

@click.command()
@click.option('--host', default='localhost', help='host')
@click.option('--username', default='guest', help='loging')
@click.option('--password', default='guest', help='password')
@click.option('--queue', default='hello', help='queue')
@click.option('--message', default='Hello World!', help='message')
def main(host, username, password, queue, message):
    credentials = pika.PlainCredentials(username, password)
    parameters = pika.ConnectionParameters(host=host, credentials=credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    result = channel.queue_declare(queue=queue)
    
    #print(result.method.queue)

    channel.basic_publish(exchange='',
                      routing_key=queue,
                      body=message)
    print(" [x] Sent 'Hello World!'")
    connection.close()

if __name__ == '__main__':
    main()