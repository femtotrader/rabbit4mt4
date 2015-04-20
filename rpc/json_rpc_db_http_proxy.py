#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, jsonify
from flask import request, abort

import click
import logging

class JsonRpcError(object):
    def __init__(self, message, code):
        self.message = message
        self.code = code
        
    def toDict(self, id):
        d = {}
        d["jsonrpc"] = "2.0"
        d_error = {}
        d_error["code"] = self.code
        d_error["message"] = self.message
        d["error"] = d_error
        d["id"] = id
        return(d)
    
    def toJSON(self, id):
        d = self.toDict(id)
        return(json.dumps(d))

class FlaskRPCProxy(Flask):
    def __init__(self, name, terminal_ids):
        super(FlaskRPCProxy, self).__init__(name)

        self.lst_terminal_ids = terminal_ids
        
        self.add_url_rule('/api/v1/rpc/<terminal_id>', 'index', self.index, methods = ['POST'])

    def index(self, terminal_id):
        id = None
        if not request.get_json(silent=True):
            msg = "Not a valid JSON RPC request"
            logging.error(msg)
            error = JsonRpcError(msg, -32000)
            return(jsonify(error.toDict(id)))

        try:
            id = request.json["id"]
        except:
            id = None
    
        if terminal_id not in self.lst_terminal_ids:
            if self.debug:
                msg = "Invalid Terminal ID %r (should be in %s)" % (terminal_id, self.lst_terminal_ids) # unsafe
            else:
                msg = "Invalid Terminal ID %r" % terminal_id # safe
            logging.error(msg)
            error = JsonRpcError(msg, -32001)
            return(jsonify(error.toDict(id)))
    
        for key in ["jsonrpc", "method", "params", "id"]:
            if not key in request.json:
                msg = "Request must contain '%s' key" % key
                logging.error(msg)
                error = JsonRpcError(msg, -32002)
                return(jsonify(error.toDict(id)))
    
        if request.json['jsonrpc']!="2.0":
            msg = 'Invalid JSON RPC Version'
            logging.error(msg)
            error = JsonRpcError(msg, -32002)
            return(jsonify(error.toDict(id)))
    
        result = self.transmit_rpc_request(terminal_id, id, request.json)

        return(jsonify(result) )

    def transmit_rpc_request(self, terminal_id, id, request):
        logging.info("send json_rpc_request: %r to %r" % (request, terminal_id))
        logging.info(type(request))
        # ToDo: send request to receiver and wait response
        result = {"jsonrpc": "2.0", "result": 42, "id": id}
        return(result)

@click.command()
@click.option('--terminal_ids', help="accepted terminal_id (use ',' if several)", default="tid01,tid02")
@click.option('--debug/--no-debug', default=False, help="Debug mode")
def main(terminal_ids, debug):
    terminal_ids = terminal_ids.split(",")
    app = FlaskRPCProxy(__name__, terminal_ids)
    app.run(debug = debug)

if __name__ == '__main__':
    main()