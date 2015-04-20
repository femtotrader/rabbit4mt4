#!/usr/bin/env python
# -*- coding: utf-8 -*-

about = """
Python script to copy files to an other one

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
import glob

def copy_from_dir(args):
    d_copy = OrderedDict()
    
    #current_dir = os.getcwd()
    current_dir = os.path.dirname(os.path.abspath(__file__))
    #current_dir = os.path.join(current_dir, "test")
    
    mt4_directories = ["C:\\Program Files (x86)\\MT4 Alpari NZ Demo"]
    for mt4_dir in mt4_directories:
        for mql4_dir in ['Experts', 'Include', 'Libraries', 'Scripts']:
            logging.info(mql4_dir)
            for filename in glob.glob(os.path.join(current_dir, "MQL4\\{mql4_dir}\\*".format(mql4_dir=mql4_dir))):
                logging.info(filename)
                d_copy[filename] = os.path.join(mt4_dir, "MQL4\\{mql4_dir}".format(mql4_dir=mql4_dir))
    
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
