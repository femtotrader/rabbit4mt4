#!/usr/bin/python
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

import os
import string
import json
import datetime
import pytz
import random
import pyjsonrpc
import logging
import traceback
import logging.config
import pika
import pandas as pd
import decimal
from decimal import Decimal
from enum import Enum # enum34
from bunch import Bunch, bunchify
from mt4_constants import *

class MyException(Exception):
    pass

class TimeoutExpired(Exception):
    pass

class Config_DB_Default(object):
    tablesprefix=""
    table_name="json_rpc"
    dbengine="mysql"
    host="127.0.0.1"
    database="test"
    user="root"
    password="123456"

class Config_AMQP_Default(object):
    host="localhost"
    username="guest"
    password="guest"
    
    timeout=5

class MySQL_RabbitMQ_Bridge(object):
    """
    MySQL RabbitMQ bridge

    don't use it directly but use inherited class
    such as MT4_MySQL_RabbitMQ_Bridge
    """
    def __init__(self, terminal_id=None, config_db=None, config_amqp=None):
        """
        MySQL RabbitMQ bridge constructor

        Parameters
        ----------
            terminal_id : terminal_id string
            config_db : AMQP configuration
            config_amqp : AMQP configuration
        """
        if config_db is None:
            self._config_db = Config_DB_Default()
        else:
            self._config_db = config_db
                
        if config_amqp is None:
            self._config_amqp = Config_AMQP_Default()
        else:
            self._config_amqp = config_amqp
            
        # get connect to our database
        self._conn_db = self.get_db_conn(config_db)
        
        # get connect to AMQP server
        self._conn_amqp = self.get_amqp_conn(config_amqp)
              
        self._terminal_id = terminal_id #"mt4_demo01_123456"

    def get_amqp_conn(self, config):
        """
        Returns database connection

        Parameters
        ----------
            config : AMQP configuration

        Returns
        -------
            amqp_conn : AMQP connection
        """
        logging.info("Connecting to RabbitMQ")
        credentials = pika.PlainCredentials(config.username, config.password)
        parameters = pika.ConnectionParameters(host=config.host, credentials=credentials)
        conn = pika.BlockingConnection(parameters)
        if config.timeout is not None:
            if config.timeout>0:
                logging.info("add_timeout %s" % config.timeout)
                conn.add_timeout(config.timeout, self._timeout_expired) # ToDo: timeout
        return(conn)

    def tables_create(self):
        """
        Create `{prefix}json_rpc` table
        """
        logging.info("Create table")
    
        table_name_with_prefix = self._config_db.tablesprefix + self._config_db.table_name

        query = """CREATE TABLE IF NOT EXISTS `%s`.`%s` (
  `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `terminal_id` varchar(255) NOT NULL,
  `request_id` varchar(255) NOT NULL,
  `request` varchar(255) NOT NULL,
  `reply_to` varchar(255) NOT NULL,
  `was_received` tinyint(1) NOT NULL,
  `was_executed` tinyint(1) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT uc_terminal_id_request_id UNIQUE (`terminal_id`,`request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;""" % (self._config_db.database, table_name_with_prefix)

        cursor = self._conn_db.cursor()

        try:
            import mysql.connector
            logging.info(" "*2 + "Creating table '{}': ".format(table_name_with_prefix))
            cursor.execute(query)
        except mysql.connector.Error as err:
            logging.error(query)
            logging.error(err.msg)

    def tables_drop(self):
        """
        Drop `{prefix}json_rpc` table
        """
        self._tables_drop_or_truncate("DROP")

    def tables_truncate(self):
        """
        Truncate `{prefix}json_rpc` table
        """
        self._tables_drop_or_truncate("TRUNCATE")

    def _tables_drop_or_truncate(self, action):
        """
        Drop or truncate JSON_RPC table

        Parameters
        ----------
            action : action string ('drop' or 'truncate')
        """
        logging.info("{action} tables".format(action=action))
    
        table_name_with_prefix = self._config_db.tablesprefix + self._config_db.table_name

        query = """{action} TABLE `{database}`.`{table}`;""".format(
            action=action, database=self._config_db.database, table=table_name_with_prefix)
        
        cursor = self._conn_db.cursor()

        try:
            import mysql.connector
            logging.info("  {action} table '{table}': ".format(action=action, table=table_name_with_prefix))
            cursor.execute(query)
        except mysql.connector.Error as err:
            logging.error(query)
            logging.error(err.msg)
        
    def use_terminal(self, terminal_id):
        """
        Returns this (`self`) bridge using a given `terminal_id`

        Parameters
        ----------
            terminal_id : terminal_id string

        Returns
        -------
            self : this bridge with `terminal_id`set
        """
        self._terminal_id = terminal_id
        return(self)
    
    def _timeout_expired(self):
        """
        Callback function when timeout is expired
        """
        logging.error("timeout expired")
        raise(TimeoutExpired)
    
    def _call(self, method, *args, **kwargs):
        """
        Send a request but don't wait response
        This is only a shortcut to `_call_nowaitresponse` method
        """
        self._call_nowaitresponse(method, *args, **kwargs)
        #return(self.call_waitresponse(method, *args, **kwargs))

    def _call_waitresponse(self, method, *args, **kwargs):
        """
        Send a request and wait response (blocking API)
        """
        request_id = self._call_sendtodb(method, *args, **kwargs)
        queue = amqp_queue_from_request_id(request_id)
        logging.info("wait response on %r" % queue)

        self._channel = self._conn_amqp.channel()
        self._channel.queue_declare(queue=queue)

        #print(" [*] Waiting for messages on queue '%s'. To exit press CTRL+C" % queue)

        #def callback(ch, method, properties, body):
        #    print(" [x] Received %r" % (body,))
        #    response = pyjsonrpc.parse_response_json(body)
        #    logging.info(response["result"])
        #    self._channel.close()

        #self._channel.basic_consume(callback,
        #              queue=queue,
        #              no_ack=True)
        
        #self._channel.consume(queue, no_ack=True)

        #self._channel.start_consuming()
        
        for method, properties, body in self._channel.consume(queue):
            response = pyjsonrpc.parse_response_json(body)
            break

        #self._channel.queue_delete(queue=queue)
        #self._channel.close()
            
        if response.error:
            logging.error("Error:", response.error.code, response.error.message)
            raise(MyException(response.error.message, response.error.code))
        else:
            result = response.result
            return(result)
        
        
    def _call_nowaitresponse(self, method, *args, **kwargs):
        """
        Send a request but don't wait response
        This is only a shortcut to `_call_sendtodb` method
        """
        self._call_sendtodb(method, *args, **kwargs)
        
    def _call_sendtodb(self, method, *args, **kwargs):
        """
        Send a request with its arguments to database
        JSON RPC request is created using pyjsonrpc

        Parameters
        ----------
            method : method to call
            *args : list of arguments
            **kwargs : keyword arguments (dict)

        Returns
        -------
            conn : database connection
        """

        if self._terminal_id is None:
            raise(MyException("terminal_id wasn't set. Use use_terminal method)"))
    
        #logging.info("method: %s" % method)
        #logging.info("args: %s" % args)
        #logging.info("kwargs: %s" % kwargs)

        request = pyjsonrpc.create_request_dict(method, *args, **kwargs)
        
        request_id = request["id"]
        request = json.dumps(request)
        #reply_to = amqp_queue_random()
        reply_to = amqp_queue_from_request_id(request_id) #UglyFix (because of MySQL ArrayFetch issue)
    
        logging.debug(" [->] Sending request")
        logging.debug("request: %s" % request)
        logging.debug("request_id: %s" % request_id)
        logging.debug("reply_to: %s" % reply_to)
    
        self._insert_rpc(request_id, request, reply_to)
        
        return(request_id)

        
    def _insert_rpc(self, request_id, request, reply_to):
        """
        Inserts request to database

        Parameters
        ----------
            request_id : request_id (string) - unique id of a request
            request : request to (string) - JSON RPC request
            reply_to : reply_to (string) - response will be sent to queue named reply_id

        Returns
        -------
            conn : database connection
        """

        table_name_with_prefix = self._config_db.tablesprefix + self._config_db.table_name
    
        #IGNORE INTO 
        query = """INSERT INTO `%s`.`%s` VALUES 
(NULL, '%s', '%s', '%s', '%s', 0, 0, NULL, NULL);""" % (
            self._config_db.database, table_name_with_prefix, self._terminal_id, request_id, request, reply_to
        );
    
        cursor = self._conn_db.cursor()

        try:
            import mysql.connector
            logging.info("  INSERT into table '{table}': ".format(table=table_name_with_prefix))
            cursor.execute(query)
        except mysql.connector.Error as err:
            logging.error(query)
            logging.error(err.msg)
        
        self._conn_db.commit()
    
        logging.info(query)

    
    def get_db_conn(self, config_db):
        """
        Returns database connection

        Parameters
        ----------
            config_db : database configuration

        Returns
        -------
            db_conn : database connection
        """
        dbengine = config_db.dbengine.lower()
        if dbengine == 'pgsql':
            raise(NotImplementedError)
            #import psycopg2
            #logging.info("Connecting to PostgreSQL database")
            #conn = psycopg2.connect(host=config_db.host, database=config_db.database,
            #                        user=config_db.user, password=config_db.password)
        elif dbengine == 'mysql':
            logging.info("Connecting to MySQL database")
            import mysql.connector
            conn = mysql.connector.connect(host=config_db.host, database=config_db.database,
                                    user=config_db.user, password=config_db.password)
        elif dbengine == 'none':
            logging.info("no DB engine")
            conn = None
        else:
            raise(NotImplementedError)
        return(conn)
        
def string_escape(s):
    """Escape string
    replace ' by _ESC1_ and " by _ESC2_
    to avoid issue when issue when inserting JSON RPC to database
    and also to avoid issue with MQL JSON RPC parser

    Parameters
    ----------
        s : string to escape characters

    Returns
    -------
        s : escaped string
    """
    #s = s.encode('string_escape')
    #s = s.encode('unicode_escape')
    #s = json.dumps(s)[1:-1]
    s = s.replace("'", '_ESC1_')
    s = s.replace('"', '_ESC2_')
    return(s)
    
def amqp_queue_random():
    """
    Returns random AMQP queue name

    Returns
    -------
        name : AMQP queue name (string)
    """
    N = 20
    alphabet = string.ascii_lowercase + string.ascii_uppercase + string.digits
    #alphabet = string.hexdigits.lower()
    s = ''.join(random.choice(alphabet) for _ in range(N))
    #return("amq.gen-%s" % s)
    return("rpc_queue_resp-%s" % s)
    
def amqp_queue_from_request_id(request_id):
    """
    Returns AMQP queue name for response from a request_id

    Parameters
    ----------
        request_id : string request_id

    Returns
    -------
        name : AMQP queue name (string)
    """
    return("rpc_queue_resp-%s" % request_id[0:22].replace('-', '0'))

UNIX_EPOCH = datetime.datetime(1970, 1, 1, 0, 0, tzinfo = pytz.utc)
def EPOCH(utc_datetime):
    """Converts datetime to Unix EPOCH timestamp (s)

    Parameters
    ----------
        utc_datetime : Non naive datetime (with timezone UTC)

    Returns
    -------
        timestamp : Pandas Timestamp with UTC timezone

    """
    delta = utc_datetime - UNIX_EPOCH
    seconds = delta.total_seconds()
    #ms = seconds * 1000
    return(seconds)

def dt2epoch(dt):
    """
    Converts datetime or string to Unix EPOCH timestamp (s)

    Parameters
    ----------
        dt : datetime or string (that can be parsed as datetime)

    Returns
    -------
        timestamp : Pandas Timestamp with UTC timezone
    """

    if isinstance(dt, basestring):
        unix_timestamp = pd.to_datetime(dt)
        if unix_timestamp.tzinfo is None:
            unix_timestamp = unix_timestamp.replace(tzinfo=pytz.utc)
            unix_timestamp = int(EPOCH(unix_timestamp))
    elif isinstance(dt, datetime.datetime):
        unix_timestamp = int(EPOCH(dt))
    return(unix_timestamp)

def epoch2ts(unix_timestamp):
    """
    Converts Unix Epoch timestamp (us) to Pandas Timestamp with UTC timezone

    Parameters
    ----------
        unix_timestamp : Unix Epoch timestamp (us)

    Returns
    -------
        timestamp : Pandas Timestamp with UTC timezone
    """
    timestamp = pd.to_datetime(unix_timestamp*1E3).replace(tzinfo=pytz.utc) # timestamp is us -> ns
    return(timestamp)




def pendings(df):
    """
    Returns DataFrame with only pendings orders
    
            >>> b = MT4_MySQL_RabbitMQ_Bridge()
            >>> df = b.AccountTrades()
            >>> po = pendings(df)

    Parameters
    ----------
        df : account trades DataFrame

    Returns
    -------
        df : DataFrame containing pending orders in account trades
    """
    return(df[(df['type']!=OP.BUY) & (df['type']!=OP.SELL) & (df['type']!=OP.OTHER)])

def opened(df):
    """
    Returns DataFrame with only opened orders
    
            >>> b = MT4_MySQL_RabbitMQ_Bridge()
            >>> df = b.AccountTrades()
            >>> po = opened(df)

    Parameters
    ----------
        df : account trades DataFrame

    Returns
    -------
        df : DataFrame containing pending orders in account trades
    """
    return(df[(df['type']==OP.BUY) | (df['type']==OP.SELL)])

def tickets_gen(tickets, sep=","):
    """
    Returns ticket number (generator)

    Parameters
    ----------
        tickets : can be
            a list of tickets (list or Numpy array np.ndarray)
            or a Pandas DataFrame with a columns "ticket"
            or a string with tickets separated with sep

        sep : separator (default ",") if tickets is a string
    """
    if isinstance(tickets, pd.DataFrame):
        tickets = tickets["ticket"]
    elif isinstance(tickets, basestring):
        tickets = tickets.split(sep)
        tickets = map(lambda s: s.strip(), tickets)
    for ticket in tickets:
        yield(ticket)

class MT4_MySQL_RabbitMQ_Bridge(MySQL_RabbitMQ_Bridge):
    def Comment(self, message=""):
        """
        Display message to top left corner of the 
        chart on which bridge EA is attached to

        Parameters
        ----------
        message : message string to send to MT
        """
        self._call("Comment", string_escape(message))

    def Print(self, message=""):
        """
        Prints message in experts tab

        Parameters
        ----------
        message : message string to send to MT
        """
        self._call("Print", string_escape(message))
        
    def IDN(self):
        """
        Display terminal_id on terminal
        """
        #self._call("IDN") # params can't be an empty list in JSON RPC because of MQL JSON parser bug - see http://www.mql5.com/en/forum/28928
        self._call("IDN", None) # UglyFix

    def Echo(self, message=""):
        """
        Returns echoed of message

        Parameters
        ----------
        message : message string to send to MT

        Returns
        -------
        (timestamp, result) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            result : echoed string
        """
        result = self._call_waitresponse("Echo", string_escape(message))
        timestamp = None
        return(timestamp, result)
        #raise(NotImplementedError)

    def Add(self, a, b):
        """Returns a+b

        Parameters
        ----------
        a : a (int)
        b : b (int)

        Returns
        -------
        (timestamp, ticket) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            result : result=a+b (int)
        """
        result = self._call_waitresponse("Add", str(a), str(b)) # UglyFix: passing a and b as string (instead of int) because of MQL JSON parser bug - see http://www.mql5.com/en/forum/28928
        timestamp = None
        return(timestamp, int(result))
        
    def OrderSendMarket(self, symbol, cmd, volume, slippage, stoploss, takeprofit, comment="", magic=0):
        """Send market order (OP.BUY or OP.SELL)
        This is a shortcut for `OrderSend` method with price=-1

        Parameters
        ----------
        symbol : symbol string
        cmd : cmd (operation type OP) - can be OP.BUY OP.SELL
            (but it can't be OP.BUYLIMIT or any pending order)
        volume : volume of order
        slippage : slippage (point)
        stoploss : stoploss price
        takeprofit : take profit price
        comment : comment string
        magic : magic number (int) to identify a strategy

        Returns
        -------
        (timestamp, ticket) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            ticket : ticket number
        """

        ticket = self.OrderSend(symbol, cmd, volume, -1.0, slippage, stoploss, takeprofit, comment, magic, 0)
        timestamp = None # ToImplement
        return(timestamp, ticket)

    def OrderSend(self, symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment="", magic=0, expiration=0):
        """Send order (market order such as OP.BUY or OP.SELL
        but also pending order OP.BUYLIMIT, OP.SELLSTOP ...)
        This is a shortcut for `OrderSend` method with price=-1

        Parameters
        ----------
        symbol : symbol string
        cmd : cmd (operation type OP) - can be OP.BUY OP.SELL OP.BUYLIMIT ...
        volume : volume of order
        price : price of order
        slippage : slippage (point)
        stoploss : stoploss price
        takeprofit : take profit price
        comment : comment string
        magic : magic number (int) to identify a strategy

        Returns
        -------
        (timestamp, ticket) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            ticket : ticket number
        """
        assert(isinstance(symbol, basestring)) # basestring = str / unicode
        assert(isinstance(cmd, OP) or isinstance(cmd, int) or isinstance(cmd, basestring))
        if isinstance(cmd, OP):
            cmd = cmd.value
        if isinstance(cmd, basestring):
            cmd = OP._member_map_[cmd.upper()].value
            
        expiration = dt2epoch(expiration)

        ticket = self._call_waitresponse("OrderSend", symbol, str(cmd), str(volume), str(price), str(slippage), str(stoploss), str(takeprofit), str(comment), str(magic), str(expiration))
        timestamp = None # ToImplement

        return(timestamp, ticket) # int # ToDo: should also return timestamp

    def OrderClose(self, ticket, volume=-1.0, price=-1.0, slippage=-1):
        """
        Close an (opened) order

        Parameters
        ----------
        ticket : ticket number

        Returns
        -------
        (timestamp, b_result) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            b_result : boolean result
        """
        b_result = self._call_waitresponse("OrderClose", str(ticket), str(volume), str(price), str(slippage))
        timestamp = None # ToImplement
        return(timestamp, bool(b_result)) # ToDo: should also return timestamp

    def OrderDelete(self, ticket):
        """
        Delete a pending order

        Parameters
        ----------
        ticket : ticket number

        Returns
        -------
        (timestamp, b_result) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            b_result : boolean result
        """
        b_result = self._call_waitresponse("OrderDelete", str(ticket))
        timestamp = None # ToImplement
        return(timestamp, bool(b_result)) # ToDo: should also return timestamp
        
    def OrderModify(self, ticket, price, stoploss, takeprofit, expiration=0):
        """
        Modify order (price or expiration of a pending order), stoploss, takeprofit

        Parameters
        ----------
        ticket : ticket number
        price : new price of a pending order
        stoploss : new stop loss price
        takeprofit : new take profit price
        expiration : new expiration datetime (default is 0 - no expiration)

        Returns
        -------
        (timestamp, b_result) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            b_result : boolean result
        """
        expiration = dt2epoch(expiration)

        b_result = self._call_waitresponse("OrderModify", str(ticket), str(price), str(stoploss), str(takeprofit), str(expiration))
        timestamp = None # ToImplement
        return(timestamp, bool(b_result)) # ToDo: should also return timestamp
    
    def AccountInfo(self):
        """
        Returns account information
        This is a shortcut for `AccountInformation` method)
        """
        return(self.AccountInformation())

    def AccountInformation(self):
        """
        Returns account information

        Returns
        -------
        (timestamp, b) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            b : Bunch (dict with dot-style notation) of account information
        """
        result = self._call_waitresponse("AccountInformation", None)
        result = bunchify(result)
        timestamp = epoch2ts(result.timestamp)
        d = result.data
        return(timestamp, d)

    def SymbolInfo(self, symbol):
        """
        Returns market (symbol) information
        This is a just an other name of `MarketInfo` method)
        """
        return(self.SymbolInfo(symbol))

    def MarketInfo(self, symbol):
        """
        Returns account information

        Parameters
        ----------
        symbol : symbol string

        Returns
        -------
        (timestamp, b) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            b : Bunch (dict with dot-style notation) of market (symbol) information
        """
        result = self._call_waitresponse("MarketInfo", symbol)
        result = bunchify(result)
        timestamp = epoch2ts(result.timestamp)
        d = result.data
        return(timestamp, d)
        
    """
    def cast_df_history_trades(self, df):
        df = df[["ticket","opentime","type","volume","symbol","openprice","stoploss","takeprofit","closetime","closeprice","commission","swap","profit","comment","magicnumber"]]
        for col in ["opentime", "closetime"]:
            df[col].replace(0, pd.NaT, inplace=True) # NaT = Not a Time
            df[col] = pd.to_datetime(df[col]*1E9)
        df["type"] = df["type"].map(OP)
        for col in ["volume", "openprice", "stoploss", "takeprofit", "closeprice", "commission", "swap", "profit"]:
            df[col] = df[col].map(decimal.Decimal)
    #    #return(df)
    """
    
    def AccountHistory(self, sizeLimit=-1):
        """
        Returns account history

        Parameters
        ----------
        sizeLimit : maximum number of elements in account history

        Returns
        -------
        (timestamp, df) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            df : DataFrame containing account history
        """

        try:
            result = self._call_waitresponse("AccountHistory", str(sizeLimit))
            df = pd.DataFrame(result["data"])
            timestamp = epoch2ts(result["timestamp"])
            
            #df = self.cast_df_history_trades(df)
            #self.cast_df_history_trades(df)
            
            df = df[["ticket","opentime","type","volume","symbol","openprice","stoploss","takeprofit","closetime","closeprice","commission","swap","profit","comment","magicnumber"]]
            for col in ["opentime", "closetime"]:
                df[col] = df[col].replace(0, pd.NaT) # NaT = Not a Time
                df[col] = pd.to_datetime(df[col]*1E9)
            df["type"] = df["type"].map(OP)
            for col in ["volume", "openprice", "stoploss", "takeprofit", "closeprice", "commission", "swap", "profit"]:
                #df[col] = df[col].map(np.float64)
                df[col] = df[col].map(decimal.Decimal)
            df["tradeduration"] = df["closetime"] - df["opentime"]
            inf = decimal.Decimal("Infinity") # or np.inf if we are using floating instead of decimal
            s_direction_sign = df["type"].map(d_order_type_sign)
            s_pip_position = df["symbol"].map(pip_position)
            s_stoploss_dist = np.where(df["stoploss"]!=0.0, s_direction_sign*(df["openprice"]-df["stoploss"]), inf)
            s_takeprofit_dist = np.where(df["takeprofit"]!=0.0, s_direction_sign*(df["takeprofit"]-df["openprice"]), inf)
            s_pip_price = s_pip_position.map(lambda x: 1/Decimal("1E%s" % x))
            df["stoploss_pips"] = s_stoploss_dist / s_pip_price
            df["takeprofit_pips"] = s_takeprofit_dist / s_pip_price
            
            return(timestamp, df)
        except:
            logging.error(traceback.format_exc())
            raise(NotImplementedError)

    def AccountTrades(self, sizeLimit=-1):
        """
        Returns account trades (opened orders and pending orders)

        Parameters
        ----------
        sizeLimit : maximum number of elements in account trades

        Returns
        -------
        (timestamp, df) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            df : DataFrame containing account trades
        """
        try:
            result = self._call_waitresponse("AccountTrades", str(sizeLimit))
            df = pd.DataFrame(result["data"])
            timestamp = epoch2ts(result["timestamp"])
            
            #self.cast_df_history_trades(df)

            df = df[["ticket","opentime","type","volume","symbol","openprice","stoploss","takeprofit","closetime","closeprice","commission","swap","profit","comment","magicnumber"]]
            for col in ["opentime", "closetime"]:
                df[col] = df[col].replace(0, pd.NaT) # NaT = Not a Time
                df[col] = pd.to_datetime(df[col]*1E9)
            df["type"] = df["type"].map(OP)
            for col in ["volume", "openprice", "stoploss", "takeprofit", "closeprice", "commission", "swap", "profit"]:
                df[col] = df[col].map(decimal.Decimal)
            df["tradeduration"] = df["closetime"] - df["opentime"]
            inf = decimal.Decimal("Infinity") # or np.inf if we are using floating instead of decimal
            s_direction_sign = df["type"].map(d_order_type_sign)
            s_pip_position = df["symbol"].map(pip_position)
            s_stoploss_dist = np.where(df["stoploss"]!=0.0, s_direction_sign*(df["openprice"]-df["stoploss"]), inf)
            s_takeprofit_dist = np.where(df["takeprofit"]!=0.0, s_direction_sign*(df["takeprofit"]-df["openprice"]), inf)
            s_pip_price = s_pip_position.map(lambda x: 1/Decimal("1E%s" % x))
            df["stoploss_pips"] = s_stoploss_dist / s_pip_price
            df["takeprofit_pips"] = s_takeprofit_dist / s_pip_price
            return(timestamp, df)

        except:
            logging.error(traceback.format_exc())
            raise(NotImplementedError)

    def Quotes(self, symbol, timeframe, sizeLimit=-1):
        """
        Returns OHLCV quotes

        Parameters
        ----------
        symbol : symbol string
        timeframe : timeframe
        sizeLimit : maximum number of quotes

        Returns
        -------
        (timestamp, df) : tuple composed of
            timestamp : UTC timestamp generated on MQL side
            df : DataFrame containing account trades
        """
        try:
            if isinstance(timeframe, basestring):
                timeframe = timeframe.upper()
                if timeframe in PERIOD._member_map_:
                    timeframe = PERIOD._member_map_[timeframe].value
                elif timeframe.isdigit():
                    timeframe = int(timeframe)
                    if timeframe in PERIOD._value2member_map_:
                        timeframe = PERIOD._value2member_map_[timeframe].value
                else:
                    raise(MyException("timeframe '%s' not allowed" % timeframe))
            else:
                raise(NotImplementedError)
            result = self._call_waitresponse("Quotes", symbol, str(timeframe), str(sizeLimit))
            df = pd.DataFrame(result["data"])
            timestamp = epoch2ts(result["timestamp"])
            digits_price = result["digits"]["price"]
            digits_volume = result["digits"]["volume"]
            
            df = df[["time","open","high","low","close","volume"]]
            
            df["time"] = df["time"].map(lambda x: pd.to_datetime(60*x*1E9)) # time was divided by 60 to reduce response size (and because lowest timeframe was 1 minute = 60 seconds)
            df = df.set_index("time")
            for col in ["open", "high", "low", "close"]:
                df[col] = df[col].astype(Decimal)
                df[col] = df[col].map(lambda x: Decimal(x)/Decimal("1E%d" % digits_price))
            df["volume"] = df["volume"].astype(Decimal)
            df["volume"] = df["volume"].map(Decimal)

            return(timestamp, df)
        except:
            logging.error(traceback.format_exc())
            logging.error(result)
            raise(NotImplementedError)

    # ToTest
    def MOrderDelete(self, tickets):
        """Delete several orders (M = Multi)

        Parameters
        ----------
        tickets : tickets can be
            a basic iterable like list,
            or numpy.array with ticket number
            or a DataFrame with a columns named ticket

        Returns
        -------
        (timestamp, count) : tuple composed of
            timestamp : UTC timestamp generated on MQL side (last deleted)
            count : number of deleted pending orders
        """
        count = 0
        if isinstance(tickets, pd.DataFrame):
            pending_tickets = pendings(df)
        else:
            pending_tickets = tickets
        
        for ticket in ticksts_gen(tickets):
            try:
                b_result = self.OrderDelete()
                if b_result:
                    count += 1
            except:
                logging.warning(traceback.format_exc())
        return(count)

    # ToTest
    def MOrderClose(tickets, volume=-1.0, price=-1.0, slippage=-1):
        """
        Close several (opened) orders (M = Multi)

        Parameters
        ----------
        tickets : tickets can be
            a basic iterable like list,
            or numpy.array with ticket number
            or a DataFrame with a columns named ticket
        volume : volume to close (partial close) or -1 (default) full close
        price : price to close or -1 (default) for market price
        slippage : slippage to close (points) or -1 (default) for default slippage

        Returns
        -------
        (timestamp, count) : tuple composed of
            timestamp : UTC timestamp generated on MQL side (last deleted)
            count : number of closed orders
        """
        pass
            

    
"""
ToDo:

   TerminalInfo()
"""