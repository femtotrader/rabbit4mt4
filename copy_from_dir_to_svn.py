#!/usr/bin/env python
# -*- coding: utf-8 -*-

about = """
Python script to copy files form a given directory to an other one

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

import argparse
import logging
import traceback
from collections import OrderedDict
import os
import shutil

def copy_from_dir(args):
    d_copy = OrderedDict()
    
    #dir = os.getcwd()
    dir = os.path.dirname(os.path.abspath(__file__))
    #dir = os.path.join(dir, "test")
    
    mt4_dir = "C:\\Program Files (x86)\\MT4 Alpari NZ Demo"

    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\rabbit4mt4.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\rabbit4mt4_config.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\rabbit4mt4_logging.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")

    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\string_toolbox.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\logging_basic.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\UnitTest.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\UnitTest_config.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Experts\\test_unittest.mq4")] = os.path.join(dir, "emit\\MQL4\\Experts")

    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\display_chart.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")

    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\json_toolbox.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\json_rpc.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\json_rpc_example.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\json_rpc_mysql.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\uuid.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\datetime_toolbox.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")

    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\hash.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Experts\\test_hash.mq4")] = os.path.join(dir, "emit\\MQL4\\Experts")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\json.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Experts\\test_json.mq4")] = os.path.join(dir, "emit\\MQL4\\Experts")
    
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\display_price_volume.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\orders_prices.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")

    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\mql4-mysql.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\mql4-mysql_config.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")
    d_copy[os.path.join(mt4_dir, "MQL4\\Include\\mql4-mysql_toolbox.mqh")] = os.path.join(dir, "emit\\MQL4\\Include")

    d_copy[os.path.join(mt4_dir, "MQL4\\Scripts\\rabbit4mt4_emit_example.mq4")] = os.path.join(dir, "emit\\MQL4\\Scripts")

    d_copy[os.path.join(mt4_dir, "MQL4\\Scripts\\rabbit4mt4_execute_rpc_example.mq4")] = os.path.join(dir, "emit\\MQL4\\Scripts")

    d_copy[os.path.join(mt4_dir, "MQL4\\Scripts\\sample_uuid.mq4")] = os.path.join(dir, "emit\\MQL4\\Scripts")
    d_copy[os.path.join(mt4_dir, "MQL4\\Scripts\\sample_json_response.mq4")] = os.path.join(dir, "emit\\MQL4\\Scripts")
    
    d_copy[os.path.join(mt4_dir, "MQL4\\Experts\\rabbit4mt4_ticks_emit.mq4")] = os.path.join(dir, "emit\\MQL4\\Experts")
    d_copy[os.path.join(mt4_dir, "MQL4\\Experts\\rabbit4mt4_orders_events.mq4")] = os.path.join(dir, "emit\\MQL4\\Experts")
    d_copy[os.path.join(mt4_dir, "MQL4\\Experts\\rabbit4mt4_execute_rpc.mq4")] = os.path.join(dir, "emit\\MQL4\\Experts")

    mt5_dir = "C:\\Program Files\\MT5 - Alpari UK Demo 01"
    d_copy[os.path.join(mt5_dir, "MQL5\\Experts\\Advisors\\rabbit4mt5_ticks_emit.mq5")] = os.path.join(dir, "emit\\MQL5\\Experts\\Advisors")
    d_copy[os.path.join(mt5_dir, "MQL5\\Experts\\Advisors\\rabbit4mt5_dom_emit.mq5")] = os.path.join(dir, "emit\\MQL5\\Experts\\Advisors")
    d_copy[os.path.join(mt5_dir, "MQL5\\Include\\rabbit4mt5.mqh")] = os.path.join(dir, "emit\\MQL5\\Include")
    d_copy[os.path.join(mt5_dir, "MQL5\\Include\\rabbit4mt5_config.mqh")] = os.path.join(dir, "emit\\MQL5\\Include")
    d_copy[os.path.join(mt5_dir, "MQL5\\Include\\dom_toolbox.mqh")] = os.path.join(dir, "emit\\MQL5\\Include")
    d_copy[os.path.join(mt5_dir, "MQL5\\Include\\json_toolbox.mqh")] = os.path.join(dir, "emit\\MQL5\\Include")
    d_copy[os.path.join(mt5_dir, "MQL5\\Include\\string_toolbox.mqh")] = os.path.join(dir, "emit\\MQL5\\Include")
    d_copy[os.path.join(mt5_dir, "MQL5\\Include\\display_price_volume.mqh")] = os.path.join(dir, "emit\\MQL5\\Include")
    d_copy[os.path.join(mt5_dir, "MQL5\\Scripts\\rabbit4mt5_emit_example.mq5")] = os.path.join(dir, "emit\\MQL5\\Scripts")

    for src, dest in d_copy.items():
        try:
            logging.info("copy '{src}' to '{dest}'".format(src=src, dest=dest))
            if not args.simulate:
                shutil.copy2(src, dest)
        except:
            logging.error(traceback.format_exc())

if __name__ == '__main__':
    logger = logging.getLogger()
    logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
  
    parser = argparse.ArgumentParser()
    parser.add_argument("--about", help="about", action='store_true')
    parser.add_argument("--simulate", help="about", action='store_true')
    args = parser.parse_args()
   
    if args.about:
        print(about)
    else:
        copy_from_dir(args)
