#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Python bridge to store JSON RPC to a database and get result to a RabbitMQ queue

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
 
 - MySQL and MySQL driver for Python (mysql.connector)
   http://dev.mysql.com/downloads/connector/python/

- pyjsonrpc
    https://github.com/gerold-penz/python-jsonrpc
    $ pip install bunch
    $ pip install python-jsonrpc 
"""

import datetime
import pytz
import random
import click
import logging
import logging.config
import traceback
from json_rpc_db_amqp import MT4_MySQL_RabbitMQ_Bridge, Config_DB_Default, Config_AMQP_Default
import decimal
from decimal import Decimal
import pprint
from mt4_constants import *

@click.command()
@click.option('--dbengine', help="DB engine.", default="mysql")
@click.option('--dbhost', help="DB host.", default="127.0.0.1")
@click.option('--db', help="DB name.", default="test")
@click.option('--dbuser', help="DB user.", default="root")
@click.option('--dbpassword', help="DB password.", default="123456")
@click.option('--dbtablesprefix', help="Tables prefix. ('prefix_')", default="")

@click.option('--terminal_id', help="Terminal ID.", default="mt4_demo01_123456")

@click.option('--create/--no-create', default=False, help="Create table.")
@click.option('--truncate/--no-truncate', default=False, help="Truncate table.")
@click.option('--drop/--no-drop', default=False, help="Drop table.")
@click.option('--insert/--no-insert', default=True, help='Insert data.')

@click.option('--method', help="message.", default="Echo")
@click.option('--message', help="message.", default="Hello Eiffel")
@click.option('--n', help="N", default=10)
@click.option('--n1', help="N1", default=6)
@click.option('--n2', help="N2", default=3)
@click.option('--ticket', help="ticket", default=-1) # ticket = 237696636 > 0 (SELECT_BY_TICKET) ; -2 (SELECT_BY_POS)
#@click.option('--pos', help="ticket", default=None) # index+1 SELECT_BY_POS
@click.option('--price', help="price", default=-1.0)
@click.option('--stoploss', help="stoploss", default=-1.0)
@click.option('--takeprofit', help="takeprofit", default=-1.0)
@click.option('--slippage', help="slippage", default=-1)
@click.option('--volume', help="volume", default=-1.0)
@click.option('--symbol', help="symbol", default="EURUSD")
@click.option('--timeframe', help="symbol", default="H1")
@click.option('--cmd', help="cmd", default="BUY")
@click.option('--comment', help="comment", default="sent from script")
@click.option('--magic', help="magic", default=123)
@click.option('--expiration', help="magic", default="1970-01-01T00:00:00+00:00")

@click.option('--mqhost', help="MQ host", default="localhost")
@click.option('--mquser', help="MQ user", default="guest")
@click.option('--mqpassword', help="MQ password", default="guest")

@click.option('--timeout', help="timeout.", default=5)

def main(dbengine, dbhost, db, dbuser, dbpassword, dbtablesprefix,
            mqhost, mquser, mqpassword, timeout,
            terminal_id, method, message, n, n1, n2, ticket, price, stoploss, takeprofit, slippage, volume, symbol, timeframe, cmd, comment, magic, expiration, 
            create, truncate, drop, insert):
    table_name = "json_rpc"
    
    config_db = Config_DB_Default()
    config_db.tablesprefix =  dbtablesprefix
    config_db.table_name = table_name
    config_db.dbengine = dbengine
    config_db.host = dbhost
    config_db.database = db
    config_db.user = dbuser
    config_db.password = dbpassword

    config_amqp = Config_AMQP_Default()
    config_amqp.host = mqhost
    config_amqp.username = mquser
    config_amqp.password = mqpassword
    config_amqp.timeout = timeout
    
    b = MT4_MySQL_RabbitMQ_Bridge(terminal_id, config_db, config_amqp).use_terminal(terminal_id)
    
    if stoploss<0:
        stoploss = 0
    
    if takeprofit<0:
        takeprofit = 0

    if volume<0:
        volume=Decimal("0.01")            

    #expiration = datetime.datetime.utcnow().replace(tzinfo=pytz.utc) + datetime.timedelta(hours=8)
        
    pp = pprint.PrettyPrinter(indent=4)
    
    if drop:
        b.tables_drop()
        return
    
    if truncate:
        b.tables_truncate()
        return
    
    if create:
        b.tables_create()
    
    if insert:
        #b._call("comment", "%s @ %s" % (message, datetime.datetime.utcnow()))
        #b._call("add", "2", "3")
        #b._call("xx", "%s @ %s" % (message, datetime.datetime.utcnow()))
        #b.Comment("Hello world!")
        #b.IDN()
        #result = b.Echo(message)
        method = method.lower()
        if method=='idn':
            result = b.IDN()
            logging.info("result: %s" % result)
            logging.info("type(result): %s" % type(result))
        elif method=='print':
            result = b.Print(message)
            logging.info("result: %s" % result)
            logging.info("type(result): %s" % type(result))
        elif method=='comment':
            result = b.Comment(message)
            logging.info("result: %s" % result)
            logging.info("type(result): %s" % type(result))
        elif method=='echo':
            result = b.Echo(message)
            logging.info("result: %s" % result)
            logging.info("type(result): %s" % type(result))
        elif method=='add':
            result = b.Add(n1,n2)
            logging.info("result: %s" % result)
            logging.info("type(result): %s" % type(result))
        elif method in ['accountinformation', 'accountinfo']:
            result = b.AccountInformation()
            logging.info("timestamp: %r" % result[0])
            logging.info("result: %s" % result[1])
            #logging.info("result: %s" % pp.pformat(result[1]))
            logging.info("type(result): %s" % type(result[1]))
        elif method in ['marketinfo', 'symbolinfo']:
            result = b.MarketInfo(symbol)
            logging.info("timestamp: %r" % result[0])
            logging.info("result: %s" % result[1])
            #logging.info("result: %s" % pp.pformat(result[1]))
            logging.info("type(result): %s" % type(result[1]))
        elif method in ['accounthistory', 'history']:
            result = b.AccountHistory(n)
            logging.info("timestamp: %r" % result[0])
            logging.info("result: \n%s" % result[1])
            logging.info("type(result): %s" % type(result[1]))
            logging.info("result.dtypes: %r" % result[1].dtypes)
            logging.info("profit: %r" % result[1]["profit"].sum())
        elif method in ['accounttrades', 'trades']:
            result = b.AccountTrades(n)
            logging.info("timestamp: %r" % result[0])
            logging.info("result: \n%s" % result[1])
            logging.info("type(result): %s" % type(result[1]))
            logging.info("result.dtypes: %r" % result[1].dtypes)
            logging.info("profit: %r" % result[1]["profit"].sum())
        elif method=='quotes':
            result = b.Quotes(symbol,timeframe,n)
            logging.info("timestamp: %r" % result[0])
            logging.info("result: %s" % result[1])
            logging.info("type(result): %s" % type(result[1]))
            logging.info("result.dtypes: %r" % result[1].dtypes)
        elif method=='ordersend':
            (timestamp, data) = b.OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration)
            logging.info("result: %s" % data)
            logging.info("type(result): %s" % type(data))
        elif method=='orderclose':
            (ticket, volume, price, slippage) = (ticket, volume, price, slippage)
            (timestamp, data) = b.OrderClose(ticket, volume, price, slippage)
            logging.info("result: %s" % data)
            logging.info("type(result): %s" % type(data))
        elif method=='orderdelete':
            (timestamp, data) = b.OrderDelete(ticket)
            logging.info("result: %s" % data)
            logging.info("type(result): %s" % type(data))
        elif method=='ordermodify':
            (timestamp, data) = b.OrderModify(ticket, price, stoploss, takeprofit, expiration)
            logging.info("result: %s" % data)
            logging.info("type(result): %s" % type(data))
        
# ToDo: MarketInfo http://docs.mql4.com/constants/environment_state/marketinfoconstants#enum_symbol_info_string        
        
        else:
            logging.warning("Undef method %r" % method)
            raise(NotImplementedError)
            #logging.warning("Undef method %r, trying to call anyway" % method)
            #result = b.Comment("undef method '%s'" % method) # ToFix: escape '
            #result = b.Comment("undef method \"%s\"" % method) # ToFix: escape '
            #result = b.Comment("undef method %s" % method)
            #b._call(method)
            #b._call(method, "") # UglyFix because of bug is JSON Parser see http://www.mql5.com/en/forum/28928

        #b.use_terminal(terminal_id).Comment("Hello")
    
if __name__ == '__main__':
    logging.config.fileConfig("logging.conf")
    logger = logging.getLogger("simpleExample")
    main()