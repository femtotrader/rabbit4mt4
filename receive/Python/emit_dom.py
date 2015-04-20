#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Python script to emit DOM (for testing purpose)
It can be useful for Sunday developers (closed markets)

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

I'm developer and I provide under free software license some softwares that can be useful
for currencies users/traders.
If you consider that what I'm doing is valuable
you can send me some crypto-coins.
https://sites.google.com/site/femtotrader/donate
"""

import json
import pika
import sys
import argparse
import logging
import logging.config
import traceback
import time

def main(args):
    connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
    channel = connection.channel()

    channel.exchange_declare(exchange='topic_logs',
                         type='topic')

    routing_key = args.routing_key
    
    message = args.sample
    try:
        logging.info("%s - %s" % (routing_key, message))
        message_json = json.loads(message)
        #logging.info(message_json) # display without pretty print
        logging.info(json.dumps(message_json, sort_keys=True, indent=4, separators=(',', ': '))) # display with pretty print
        #self.update_orderbook(method.routing_key, message_json)
        print("")
    except:
        logging.error("Can't parse JSON - will not send data")
        logging.error(traceback.format_exc())
        return()

    channel.basic_publish(exchange='topic_logs',
                      routing_key=routing_key,
                      body=message)
    logging.info(" [x] Sent %r:%r" % (routing_key, message))
    connection.close()


if __name__ == '__main__':
    logging.config.fileConfig("logging.conf")
    
    logger = logging.getLogger("simpleExample")
    
    message_json_default = '[["1.38276", "3000000.0", 1], ["1.38271", "500000.0", 1], ["1.38269", "1500000.0", 1], ["1.38267", "3500000.0", 1], ["1.38266", "500000.0", 1], ["1.38265", "15000000.0", 1], ["1.38264", "500000.0", 1], ["1.38263", "10000000.0", 1], ["1.38262", "3600000.0", 1], ["1.38261", "24000000.0", 1], ["1.38260", "5100000.0", 1], ["1.38259", "4500000.0", 1], ["1.38258", "9550000.0", 1], ["1.38257", "6250000.0", 1], ["1.38255", "1000000.0", 1], ["1.38254", "100000.0", 1], ["1.38246", "2000000.0", 2], ["1.38245", "3000000.0", 2], ["1.38244", "2750000.0", 2], ["1.38243", "14550000.0", 2], ["1.38242", "5500000.0", 2], ["1.38241", "13000000.0", 2], ["1.38240", "4300000.0", 2], ["1.38239", "11000000.0", 2], ["1.38238", "500000.0", 2], ["1.38237", "23000000.0", 2], ["1.38236", "500000.0", 2], ["1.38235", "2000000.0", 2], ["1.38234", "500000.0", 2], ["1.38233", "500000.0", 2], ["1.38231", "500000.0", 2], ["1.38229", "500000.0", 2]]'

    parser = argparse.ArgumentParser()
    parser.add_argument("--routing_key", help="routing key 'mt5_demo01_123456.events.dom.eurusd'", default="mt5_demo01_123456.events.dom.eurusd")
    parser.add_argument("--sample", help="JSON sample message", default=message_json_default)
    parser.add_argument("--loop", help="loop", action='store_true')
    parser.add_argument("--delay", help="delay (s)", default='2')
    
    args = parser.parse_args()
    
    delay = float(args.delay)
    
    if args.loop:
    	while(True):
            main(args)
            time.sleep(delay)
    else:
        main(args)