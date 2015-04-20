#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Python script to store JSON RPC to database

Dependencies:
 - click (Command Line Interface Creation Kit)
   $ pip install click
 - Peewee
     a small, expressive orm (Object-relational mapping)
     $ pip install peewee
 - PyMySQL
     MySQL Python connector
     https://github.com/PyMySQL/PyMySQL
     $ pip install PyMySQL
"""

"""
ToDo
use pyjsonrpc
https://github.com/gerold-penz/python-jsonrpc
$ pip install bunch
$ pip install python-jsonrpc
"""

import os
import string
import json
import datetime
import random
import click
from peewee import *
from config import db_config
import pyjsonrpc

#DB = SqliteDatabase('json_rpc.sqlite')
DB = MySQLDatabase(host=db_config["host"], database=db_config["database"],
    user=db_config["user"], passwd=db_config["password"], port=db_config["port"]) # MySQLdb (pip install PyMySQL)

    
#CREATE TABLE `json_rpc` (
#  `terminal_id` varchar(255) NOT NULL,
#  `request_id` varchar(255) NOT NULL,
#  `request` varchar(255) NOT NULL,
#  `response` varchar(255) NOT NULL,
#  `was_received` tinyint(1) NOT NULL,
#  `was_executed` tinyint(1) NOT NULL,
#  PRIMARY KEY (`terminal_id`,`request_id`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8;
#
# "  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP," +
# "  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +


class JSON_RPC(Model):
    terminal_id = CharField()
    request_id = CharField()
    request = CharField()
    response = CharField()
    was_received = BooleanField()
    was_executed = BooleanField()
    # error_code = IntegerField() # ?
    #created = ()
    #updated = ()

    class Meta:
        database = DB # this model uses the people database
        primary_key = CompositeKey('terminal_id', 'request_id')

#def random_alphanumeric_id(length):
#    chars = string.ascii_letters + string.digits # + '!@#$%^&*()'
#    random.seed = (os.urandom(1024))
#    return(''.join(random.choice(chars) for i in range(length)))

#def random_numeric_id(length):
#    return(random.randint(10**8, 10**9))


@click.command()
@click.option('--terminal_id', help="Terminal ID.", default="mt4_demo01_123456")
@click.option('--drop_table', is_flag=True, help="Drop table.")
@click.option('--create_table', is_flag=True, help="Create table.")
@click.option('--no_insert', is_flag=True, help='Insert data.')
@click.option('--message', help="message.", default="Hello Eiffel")
def main(terminal_id, message, drop_table, create_table, no_insert):
    # connect to our database
    DB.connect()
    
    if drop_table:
        JSON_RPC.drop_table(fail_silently=True)
        return

    if create_table:
        JSON_RPC.create_table(fail_silently=True)
    
    #JSON_RPC.select().where(True).delete_instance()

    terminal_id = terminal_id

    #request = {}
    #request_id = random_alphanumeric_id(10)
    #request["jsonrpc"] = "2.0"
    #request["method"] = "Comment"
    #request["params"] = ["Hello Eiffel with request_id='%s' @ %s" % (request_id, datetime.datetime.utcnow())]
    #request["id"] = request_id
    #request = json.dumps(request)
    #request = '{"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": '+ str(request_id) + '}'
    
    request = pyjsonrpc.create_request_dict("Comment", "%s@ %s" % (message, datetime.datetime.utcnow()))
    request_id = request["id"]
    request = json.dumps(request)

    response = ""
    
    json_rpc = JSON_RPC(
        terminal_id=terminal_id,
        request_id = request_id,
        request=request,
        response=response,
        was_received=False,
        was_executed=False
    )
    
    if not no_insert:
        #json_rpc.save()
        json_rpc.save(force_insert=True)

if __name__ == '__main__':
    main()