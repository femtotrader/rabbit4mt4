#!/usr/bin/env python
import pika
import click
import logging

@click.command()
@click.option('--host', default='localhost', help='host')
@click.option('--username', default='guest', help='loging')
@click.option('--password', default='guest', help='password')
@click.option('--queue', default='hello', help='queue')
def main(host, username, password, queue):
    credentials = pika.PlainCredentials(username, password)
    parameters = pika.ConnectionParameters(host=host, credentials=credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    channel.queue_declare(queue=queue)

    print(" [*] Waiting for messages on queue '%s'. To exit press CTRL+C" % queue)

    def callback(ch, method, properties, body):
        print(" [x] Received %r" % (body,))

    channel.basic_consume(callback,
                      queue=queue,
                      no_ack=True)

    channel.start_consuming()

if __name__ == '__main__':
    main()