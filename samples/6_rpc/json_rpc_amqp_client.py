#!/usr/bin/env python

"""
Python JSON RPC client for AMQP (RabbitMQ - pika)

    Copyright (C) 2014 "FemtoTrader" <femto.trader@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>

Dependencies:
 - click (Command Line Interface Creation Kit)
   $ pip install click
 
 - pika
   https://pypi.python.org/pypi/pika
    $ pip install pika

- pyjsonrpc
    https://github.com/gerold-penz/python-jsonrpc
    $ pip install bunch
    $ pip install python-jsonrpc 
"""

import logging
import logging.config
import traceback
import click
import json
import datetime
from json_rpc_amqp import JsonRpcAmqpClient, JSON_RPC_Encoder_Decoder

@click.command()
@click.option('--host', default='localhost', help='host')
@click.option('--username', default='guest', help='loging')
@click.option('--password', default='guest', help='password')
@click.option('--server_id', default='fooserver', help='server_id')
@click.option('--a', default=10, help='a')
@click.option('--b', default=15, help='b')
@click.option('--method', default='fib', help='method')
@click.option('--timeout', default=2, help='timeout')
def main(host, username, password, server_id, timeout, method, a, b):
    enc = JSON_RPC_Encoder_Decoder()
    client = JsonRpcAmqpClient(host, username, password, enc)
    client = client.use_server(server_id, timeout)
        
    if method=='fib':
        response = client.call("fib", a)
        #response = client.call("fib", a)
        #response = client.fib(a)
        logging.info("fib(%d)=%d" % (a, response))
        logging.info(response)
        logging.info(type(response))
        response = client.call("fib", b)

    elif method=='fiberrarg':
        response = client.call("fib", a, 10)

    elif method=='fiberrmeth':
        response = client.call("fibx", a, 10)
        
    elif method=='add':
        response = client.call("add", a, b)
        logging.info("a+b=%d+%d=%d" % (a, b, response))
        logging.info(response)
        logging.info(type(response))
    
    elif method=='adddt':
        response = client.call("add", datetime.datetime.utcnow(), datetime.timedelta(days=1))
        
    elif method=='notjson':
        import pika
        credentials = pika.PlainCredentials(username, password)
        parameters = pika.ConnectionParameters(host=host, credentials=credentials)
        connection = pika.BlockingConnection(parameters)
        channel = connection.channel()
        channel.basic_publish(exchange='', routing_key=queue, body="bad_request")
    
    else:
        response = client.call("fibx", a)

if __name__ == '__main__':
    logging.config.fileConfig("logging.conf")    
    logger = logging.getLogger("simpleExample")
    main()