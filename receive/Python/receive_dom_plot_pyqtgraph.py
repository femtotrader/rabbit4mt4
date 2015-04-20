#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Python script to Display realtime orderbook

JSON message like '[["1.38276", "3000000.0", 1], ... , ["1.38229", "500000.0", 2]]'
columns order ["price", "volume", "typ"] (typ=1 for asks typ=2 for bids)

Done:
Test with sample data
    use python receive_dom.py --enable_sample_mode

ToFix:
Realtime plot with RabbitMQ JSON

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

import logging
import logging.config
import traceback
import argparse
import time
import os
import sys

import pandas as pd
import pika
import datetime
import json

from pyqtgraph.Qt import QtGui, QtCore
import numpy as np
import pyqtgraph as pg

import threading
import time

from StringIO import StringIO

class OrderBookPlot:
    def __init__(self, args, win):
        self.args = args
        self.win = win
        
        #self.plot_ob_cum = pg.plot()
        self.plot_ob_cum = win.addPlot(title="orderbook (cumulated volume)")

        self.plot_ob = win.addPlot(title="orderbook")

        #self.ptr = 0
        
        self.curve = {}
		
        pen = pg.mkPen('b', style=QtCore.Qt.SolidLine)
        self.curve["bids_price_volume"] = self.plot_ob.plot(pen=pen)
        pen = pg.mkPen('r', style=QtCore.Qt.SolidLine)
        self.curve["asks_price_volume"] = self.plot_ob.plot(pen=pen)
		
        #pen = 'r'
        pen = pg.mkPen('b', style=QtCore.Qt.SolidLine)
        self.curve["bids_price_volumecum"] = self.plot_ob_cum.plot(pen=pen, symbol='+')
        pen = pg.mkPen('r', style=QtCore.Qt.SolidLine)
        self.curve["asks_price_volumecum"] = self.plot_ob_cum.plot(pen=pen, symbol='+')

        pen = pg.mkPen('b', style=QtCore.Qt.DotLine)
        self.curve["bids_pricemean_volumecum"] = self.plot_ob_cum.plot(pen=pen, symbol='o')
        pen = pg.mkPen('r', style=QtCore.Qt.DotLine)
        self.curve["asks_pricemean_volumecum"] = self.plot_ob_cum.plot(pen=pen, symbol='o')
        

    def update(self, data):
        self.update_orderbook(data)
        self.update_plot()

    def update_plot(self):        
        for typ in ["bids", "asks"]:
            self.curve[typ + "_" + "price_volumecum"].setData(x=self.ob[typ]["volume_cum"].values, y=self.ob[typ].index.values)
            self.curve[typ + "_" + "pricemean_volumecum"].setData(x=self.ob[typ]["volume_cum"].values, y=self.ob[typ]['price_mean'].values)

            self.curve[typ + "_" + "price_volume"].setData(x=self.ob[typ]["volume"].values, y=self.ob[typ].index.values)
        
        #if self.ptr == 0:
        #    self.plot_ob_cum.enableAutoRange('xy', False)  ## stop auto-scaling after the first data set is plotted
        #self.ptr += 1

    def clear_term(self):
        os.system('cls' if os.name == 'nt' else 'clear')

    def update_orderbook(self, data):
        self.clear_term()

        (routing_key, message_json) = data
                
        #logging.info("update_orderbook")
        #df_all = pd.read_json(message_json)
        
        message_json = json.loads(message_json)
        logging.debug(message_json["orderbook"])
        df_all = pd.DataFrame(message_json["orderbook"])        
        logging.debug(df_all)
        #df_all.columns = ["price", "volume", "type"]
        
        df_all["price"] = df_all["price"].astype(float)
        df_all["volume"] = df_all["volume"].astype(float)
        #df_all["type"] = df_all["type"].astype(int)

        self.ob = {}
        self.ob["asks"] = df_all[df_all["type"]==1][["price", "volume"]]
        self.ob["bids"] = df_all[df_all["type"]==2][["price", "volume"]]
    
        #for typ, df in ob.items():
        #    ob[typ]["price"] = ob[typ]["price"].astype(float)
        #    ob[typ]["volume"] = ob[typ]["volume"].astype(float)
    
        self.ob["asks"] = self.ob["asks"].sort(columns=["price"], ascending=[True])
        self.ob["bids"] = self.ob["bids"].sort(columns=["price"], ascending=[False])
    
        for typ, df in self.ob.items():
            self.ob[typ]["volume_cum"] = self.ob[typ]["volume"].cumsum()
            self.ob[typ]["price*volume"] = self.ob[typ]["price"]*self.ob[typ]["volume"]
            self.ob[typ]["(price*volume)_cum"] = self.ob[typ]["price*volume"].cumsum()
            self.ob[typ]["price_mean"] = self.ob[typ]["(price*volume)_cum"]/self.ob[typ]["volume_cum"]
    
        self.ob["asks"] = self.ob["asks"].sort(columns=["price"], ascending=[False])
        #self.ob["bids"] = self.ob["bids"].sort(columns=["price"], ascending=[False])

        for typ, df in self.ob.items():
            self.ob[typ] = self.ob[typ].set_index("price", drop=False)
            
        logging.info("routing_key" + ": " + routing_key)
        
        ts = datetime.datetime.utcfromtimestamp(message_json["unixtime_s"])
        logging.info("datetime: %s" % ts)
        for key in ["unixtime_s", "bid", "ask", "volume", "last", "spread_points"]: # "spread", "time"
            logging.info("%s: %s" % (key, message_json[key]))
        
        print("")
        
        #cols = ['volume', 'volume_cum', 'price_mean']
        cols = ['volume', 'volume_cum', 'price*volume', '(price*volume)_cum', 'price_mean']
        logging.info("asks" + "\n" + str(self.ob["asks"][cols]))    
        logging.info("bids" + "\n" + str(self.ob["bids"][cols]))
        #logging.info("="*10)
        

class RabbitMQThread(pg.QtCore.QThread):
    newData = pg.QtCore.Signal(object)
    def __init__(self, args):
        super(RabbitMQThread, self).__init__()
        self.args = args
        self.stopMutex = threading.Lock()
        self._stop = False

    def run(self):
        self.init_rabbitmq_connection()
    
    def init_rabbitmq_connection(self):
        connection = pika.BlockingConnection(pika.ConnectionParameters(
            host='localhost'))
        channel = connection.channel()

        exchange = 'topic_logs'

        channel.exchange_declare(exchange=exchange,
                         type='topic')

        result = channel.queue_declare(exclusive=True)
        queue_name = result.method.queue

        binding_keys = self.args.binding_keys.split(',')

        for binding_key in binding_keys:
            channel.queue_bind(exchange=exchange,
                       queue=queue_name,
                       routing_key=binding_key)

        logging.info(' [*] Waiting for DOM. To exit press CTRL+C')


        channel.basic_consume(self.rabbitmq_dom_callback,
                      queue=queue_name,
                      no_ack=True)

        channel.start_consuming()

    def rabbitmq_dom_callback(self, ch, method, properties, body):
        try:
            #logging.info("%s - %s" % (method.routing_key, body))
            
            self.newData.emit((method.routing_key, body))
            
            #message_json = json.loads(body)
            #logging.info(message_json) # display without pretty print
            #logging.info(json.dumps(message_json, sort_keys=True, indent=4, separators=(',', ': '))) # display with pretty print
            print("")
        except:
            logging.info(traceback.format_exc())

    def stop(self):
        # Must protect self._stop with a mutex because the secondary thread 
        # might try to access it at the same time.
        with self.stopMutex:
            self._stop = True

class OrderBookDisplay:
    def __init__(self, args):    
    	self.args = args

        #QtGui.QApplication.setGraphicsSystem('raster')
        app = QtGui.QApplication([])
        #mw = QtGui.QMainWindow()
        #mw.resize(800,800)

        pg.setConfigOption('background', 'w')
        pg.setConfigOption('foreground', 'k')

        win = pg.GraphicsWindow(title="Basic plotting examples")
        win.resize(1000,600)
        win.setWindowTitle('plot')

        # Enable antialiasing for prettier plots
        pg.setConfigOptions(antialias=True)
    
        self.order_book_plot = OrderBookPlot(self.args, win)

        if self.args.enable_sample_mode:
            timer = QtCore.QTimer()
            timer.timeout.connect(self.update_sample)
            timer.start(500)
        else:
            thread = RabbitMQThread(self.args)
            thread.newData.connect(self.order_book_plot.update)
            thread.start()
    
        import sys
        ## Start Qt event loop unless running in interactive mode or using pyside.
        if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
            QtGui.QApplication.instance().exec_()
            
    def update_sample(self):
    	(routing_key, json_message) = ("mt5_sample.events.dom.eurusd", self.args.sample)
        self.order_book_plot.update((routing_key, json_message))

def main(args):
	obd = OrderBookDisplay(args)

if __name__ == '__main__':
    logging.config.fileConfig("logging.conf")
    
    logger = logging.getLogger("simpleExample")
    
    logging.info("Running DOM Plot")
    
    message_json_default = '{"orderbook": [["1.38276", "3000000.0", 1], ["1.38271", "500000.0", 1], ["1.38269", "1500000.0", 1], ["1.38267", "3500000.0", 1], ["1.38266", "500000.0", 1], ["1.38265", "15000000.0", 1], ["1.38264", "500000.0", 1], ["1.38263", "10000000.0", 1], ["1.38262", "3600000.0", 1], ["1.38261", "24000000.0", 1], ["1.38260", "5100000.0", 1], ["1.38259", "4500000.0", 1], ["1.38258", "9550000.0", 1], ["1.38257", "6250000.0", 1], ["1.38255", "1000000.0", 1], ["1.38254", "100000.0", 1], ["1.38246", "2000000.0", 2], ["1.38245", "3000000.0", 2], ["1.38244", "2750000.0", 2], ["1.38243", "14550000.0", 2], ["1.38242", "5500000.0", 2], ["1.38241", "13000000.0", 2], ["1.38240", "4300000.0", 2], ["1.38239", "11000000.0", 2], ["1.38238", "500000.0", 2], ["1.38237", "23000000.0", 2], ["1.38236", "500000.0", 2], ["1.38235", "2000000.0", 2], ["1.38234", "500000.0", 2], ["1.38233", "500000.0", 2], ["1.38231", "500000.0", 2], ["1.38229", "500000.0", 2]]}'

    parser = argparse.ArgumentParser()
    parser.add_argument("--binding_keys", help="binding keys (use comma ',' to split several binding keys), default is '#' to receive any message, binding_key can be 'mt5_demo01_123456.events.dom.eurusd'", default="#")
    parser.add_argument("--enable_sample_mode", help="enable sample mode (use a sample JSON message)", action='store_true')
    parser.add_argument("--sample", help="JSON sample message", default=message_json_default)
    
    args = parser.parse_args()
    main(args)