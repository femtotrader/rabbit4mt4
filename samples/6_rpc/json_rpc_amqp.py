#!/usr/bin/env python

"""
Python JSON RPC library for AMQP (RabbitMQ - pika)

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

import pika
import uuid
import logging
import traceback

import pyjsonrpc
import pyjsonrpc.rpcerror as rpcerror
import pyjsonrpc.rpcresponse as rpcresponse

import datetime
import json
from bson import json_util
#import anyjson as json

from abc import ABCMeta, abstractmethod

class MyException(Exception):
    pass

class RPC_Encoder_Decoder(object):
    __metaclass__ = ABCMeta
    
    def __init__(self):
        self.d_funcs = None

    @abstractmethod
    def encode(self, data): pass
    
    @abstractmethod
    def _decode(self, data): pass
    
    @abstractmethod
    def decode(self, data): pass

    @abstractmethod
    def update_rpc(self): pass
    
    @abstractmethod
    def call(self, rpc_request): pass

class JSON_RPC_Encoder_Decoder(RPC_Encoder_Decoder):
    def encode(self, data):
        return(json.dumps(data, default=json_util.default))

    def _decode(self, data):
        #return(json.loads(data, default=json_default))
        return(json.loads(data, object_hook=json_util.object_hook))
    
    def decode(self, data):
        data = self._decode(data)
        if "result" in data:
            return(data["result"])
        else:
            #raise(MyException(rpcerror.jsonrpcerrors[data["error"]["code"]]))
            raise(rpcerror.jsonrpcerrors[data["error"]["code"]])
            
    def update_rpc(self):
        self.rpc = pyjsonrpc.JsonRpc(methods = self.d_funcs)
    
    def call(self, rpc_request):
        rpc_response = self.rpc.call(rpc_request)
        return(rpc_response)

#class JsonRpcAmqpClientFactory(object):           

class JsonRpcAmqpClient(object):
    def __init__(self, host, username, password, enc_decoder=None):
        self._host = host
        self._username = username
        self._password = password

        if enc_decoder is None:
            self.enc_decoder = JSON_RPC_Encoder_Decoder()
        else:
            self.enc_decoder = enc_decoder
        
        self._connection = None
        self._connect = self._connect_first_use

    def _connect_first_use(self):
        credentials = pika.PlainCredentials(self._username, self._password)
        parameters = pika.ConnectionParameters(host=self._host, credentials=credentials)
        self._connection = pika.BlockingConnection(parameters)
        self._connect = self._connect_other_use
        
    def _connect_other_use(self):
        pass
    
    def use_server(self, server_id=None, timeout=None):
        self._server_id = server_id
        self._queue = "rpc_queue_%s" % self._server_id
        self._timeout = timeout
        
        self._connect()
        
        if timeout is not None:
            if timeout>0:
                self._connection.add_timeout(self._timeout, self.on_response)

        self._channel = self._connection.channel()
        
        result = self._channel.queue_declare(exclusive=True)
        self._callback_queue = result.method.queue
        
        logging.debug("queue: %r" % self._queue)

        self._channel.basic_consume(self.on_response, no_ack=True,
                                   queue=self._callback_queue)

        return(self)

    def on_response(self, channel=None, method=None, properties=None, body=None):
        if channel is None or method is None or properties is None or body is None:
            logging.error("Deadline (timeout)")
            self.response = None
            self._connection.close()
            #raise(NotImplementedError)
        else:
            if self.correlation_id == properties.correlation_id:
                self.response = body
                self.dt_response = datetime.datetime.utcnow()
         
    def call(self, method, *args, **kwargs):
        if self._connection is not None:
            rpc_request = pyjsonrpc.create_request_dict(method, *args, **kwargs)
            self.dt_call = datetime.datetime.utcnow()
            self.response = None
            #self.correlation_id = str(uuid.uuid4()) # UUID4 (random)
            self.correlation_id = rpc_request["id"] # get request_id from dict
            rpc_request = self.enc_decoder.encode(rpc_request) # dict -> str
            #rpc_request = self.enc_decoder.encode(rpc_request) + "bad" # badly formated JSON (for test)
    
            logging.debug(" [->] Sending request to queue %r" % self._queue)
            logging.debug("request: %r" % rpc_request)
            logging.debug("correlation_id: %r" % self.correlation_id)
            logging.debug("reply_to: %r" % self._callback_queue)
            self._channel.basic_publish(exchange='',
                                       routing_key=self._queue,
                                       properties=pika.BasicProperties(
                                             reply_to = self._callback_queue,
                                             correlation_id = self.correlation_id,
                                             ),
                                       body=rpc_request)
            while self.response is None:
                self._connection.process_data_events()
            logging.debug(" [<-] Got response on queue %r" % self._callback_queue)
            logging.debug("response: %r" % (self.response))
            logging.debug("rpc execution delay: %s" % (self.dt_response-self.dt_call))
    
            return(self.enc_decoder.decode(self.response))
        else:
            raise(MyException("No connection"))

class JsonRpcAmqpServer(object):
    def __init__(self, host, username, password, server_id, purge_at_startup, enc_decoder=None):
        queue = "rpc_queue_%s" % server_id
        if enc_decoder is None:
            self.enc_decoder = JSON_RPC_Encoder_Decoder()
        else:
            self.enc_decoder = enc_decoder

        credentials = pika.PlainCredentials(username, password)
        parameters = pika.ConnectionParameters(host=host, credentials=credentials)
        self._connection = pika.BlockingConnection(parameters)

        self._channel = self._connection.channel()

        self._channel.queue_declare(queue=queue)
        
        if purge_at_startup:
            self._channel.queue_purge(queue) # purge queue before starting server

        self._channel.basic_qos(prefetch_count=1)

        logging.debug("Awaiting RPC requests on queue %r" % queue)

        self._channel.basic_consume(self.on_request, queue=queue)
        
        self.rpc = None
    
    def start(self):
        if self.functions_registered():
            self._channel.start_consuming()
        else:
            raise(MyException("no RPC function registered (use register_functions)"))

    def functions_registered(self):
        return(self.enc_decoder.d_funcs is not None)
        
    def register_functions(self, d_funcs):
        if self.functions_registered():
            logging.warning("some RPC functions were ever registed! it will unregistered them")
        self.enc_decoder.d_funcs = d_funcs
        self.enc_decoder.update_rpc()

    def on_request(self, channel, method, properties, rpc_request):
        logging.debug(" [->] Receiving request")
        logging.debug("request: %r" % (rpc_request,))
        
        try:
            #rpc_response = self.rpc.call(rpc_request)
            rpc_response = self.enc_decoder.call(rpc_request)
        except rpcerror.ParseError as e:
            logging.error("Can't call %r" % rpc_request)
            logging.error(traceback.format_exc())
            #logging.error(e)

            #rpc_response = rpcresponse.Response(
            #    jsonrpc = jsonrpc,
            #    id = None,
            #    error = rpcerror.ParseError()
            #)
            
            #print(rpc_response)

            #ToFix
            #rpc_response = rpcerror.ParseError().toJSON()
            #print(type(rpc_response))
            return()
        
        logging.debug(" [<-] Sending response")
        logging.debug("response: %r" % (rpc_response,))
        logging.debug("correlation_id: %r" % properties.correlation_id)
        logging.debug("reply_to: %r" % properties.reply_to)

        channel.basic_publish(exchange='',
                     routing_key=properties.reply_to,
                     properties=pika.BasicProperties(correlation_id = \
                                                     properties.correlation_id),
                     body=rpc_response)
        channel.basic_ack(delivery_tag = method.delivery_tag)
