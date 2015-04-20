#!/usr/bin/env python

import pandas as pd
import traceback
import logging.config
import argparse
import matplotlib.pyplot as plt
import time
import os

def clear_term():
    os.system('cls' if os.name == 'nt' else 'clear')

def display_orderbook(routing_key, message_json):
    df_all = pd.read_json(message_json)
    df_all.columns = ["price", "volume", "type"]

    ob = {}
    ob["asks"] = df_all[df_all["type"]==1][["price", "volume"]]
    ob["bids"] = df_all[df_all["type"]==2][["price", "volume"]]
    
    #for typ, df in ob.items():
    #    ob[typ]["price"] = ob[typ]["price"].astype(float)
    #    ob[typ]["volume"] = ob[typ]["volume"].astype(float)
    
    ob["asks"] = ob["asks"].sort(columns=["price"], ascending=[True])
    ob["bids"] = ob["bids"].sort(columns=["price"], ascending=[False])
    
    for typ, df in ob.items():
        ob[typ]["volume_cum"] = ob[typ]["volume"].cumsum()
        ob[typ]["price*volume"] = ob[typ]["price"]*ob[typ]["volume"]
        ob[typ]["(price*volume)_cum"] = ob[typ]["price*volume"].cumsum()
        ob[typ]["price_mean"] = ob[typ]["(price*volume)_cum"]/ob[typ]["volume_cum"]
    
    ob["asks"] = ob["asks"].sort(columns=["price"], ascending=[False])
    #ob["bids"] = ob["bids"].sort(columns=["price"], ascending=[False])

    for typ, df in ob.items():
        ob[typ] = ob[typ].set_index("price", drop=False)
    
    clear_term()
    cols = ['volume', 'volume_cum', 'price_mean']
    logging.info("asks" + "\n" + str(ob["asks"][cols]))    
    logging.info("bids" + "\n" + str(ob["bids"][cols]))
    logging.info("="*10)
    
    ob["asks"].plot(x="volume_cum", y="price", color='r', style='+', linestyle='-')
    ob["bids"].plot(x="volume_cum", y="price", color='b', style='+', linestyle='-')
    ob["asks"].plot(x="volume_cum", y="price_mean", color='r', style='.', linestyle='--')
    ob["bids"].plot(x="volume_cum", y="price_mean", color='b', style='.', linestyle='--')
    
    #plt.ion()
    #plt.draw()

    plt.show()

def display_sample_orderbook(args):
    message_json = args.sample
    routing_key = "mt5_sample.events.dom.eurusd"
    display_orderbook(routing_key, message_json)

#def display_realtime_orderbook(args):


def main(args):
    while(True):
        display_sample_orderbook(args)
        time.sleep(3) # seconds
    #if args.enable_sample_mode:
    #    display_sample_orderbook()
    #else:
    #    display_realtime_orderbook(args)

if __name__ == '__main__':
    logging.config.fileConfig("logging.conf")
    
    logger = logging.getLogger("simpleExample")
    
    message_json_default = '[["1.38276", "3000000.0", 1], ["1.38271", "500000.0", 1], ["1.38269", "1500000.0", 1], ["1.38267", "3500000.0", 1], ["1.38266", "500000.0", 1], ["1.38265", "15000000.0", 1], ["1.38264", "500000.0", 1], ["1.38263", "10000000.0", 1], ["1.38262", "3600000.0", 1], ["1.38261", "24000000.0", 1], ["1.38260", "5100000.0", 1], ["1.38259", "4500000.0", 1], ["1.38258", "9550000.0", 1], ["1.38257", "6250000.0", 1], ["1.38255", "1000000.0", 1], ["1.38254", "100000.0", 1], ["1.38246", "2000000.0", 2], ["1.38245", "3000000.0", 2], ["1.38244", "2750000.0", 2], ["1.38243", "14550000.0", 2], ["1.38242", "5500000.0", 2], ["1.38241", "13000000.0", 2], ["1.38240", "4300000.0", 2], ["1.38239", "11000000.0", 2], ["1.38238", "500000.0", 2], ["1.38237", "23000000.0", 2], ["1.38236", "500000.0", 2], ["1.38235", "2000000.0", 2], ["1.38234", "500000.0", 2], ["1.38233", "500000.0", 2], ["1.38231", "500000.0", 2], ["1.38229", "500000.0", 2]]'

    parser = argparse.ArgumentParser()
    parser.add_argument("--binding_keys", help="binding keys (use comma ',' to split several binding keys), default is '#' to receive any message, binding_key can be 'mt5_demo01_123456.events.dom.eurusd'", default="#")
    parser.add_argument("--enable_sample_mode", help="enable sample mode (use a sample JSON message)", action='store_true')
    parser.add_argument("--sample", help="JSON sample message", default=message_json_default)
    
    args = parser.parse_args()
    main(args)