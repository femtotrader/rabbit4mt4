#!/usr/bin/env python

"""
Python JSON RPC server for AMQP (RabbitMQ - pika)

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
import pyjsonrpc
import decimal
from json_rpc_amqp import JsonRpcAmqpServer, JSON_RPC_Encoder_Decoder

def add(a, b):
    """Test function"""
    #a = decimal.Decimal(a)
    #b = decimal.Decimal(b)
    return a + b

def fib(n):
    """Fibonacci function"""
    #n = int(n)
    #n = decimal.Decimal(n)
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fib(n-1) + fib(n-2)

@click.command()
@click.option('--host', default='localhost', help='host')
@click.option('--username', default='guest', help='loging')
@click.option('--password', default='guest', help='password')
@click.option('--server_id', default='fooserver', help='server_id')
@click.option('--purge/--no-purge', default=True)
def main(host, username, password, server_id, purge):
    enc = JSON_RPC_Encoder_Decoder()
    json_rpc_server = JsonRpcAmqpServer(host, username, password, server_id, purge, enc)
    json_rpc_server.register_functions(
        {
            "add": add,
            "fib": fib
        })
    json_rpc_server.start()

if __name__ == '__main__':
    logging.config.fileConfig("logging.conf")    
    logger = logging.getLogger("simpleExample")
    main()