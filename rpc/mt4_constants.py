#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Python MT4 constants

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
 - enum (Enum python 3.4 backport)
   $ pip install enum34
"""

from enum import Enum # enum34
import logging
import numpy as np

class OP(Enum):
    """
    Operation type for the OrderSend() function.

            >>> OP.BUY
            >>> OP.SELL
    """
    BUY = 0
    SELL = 1
    BUYLIMIT = 2
    SELLLIMIT = 3
    BUYSTOP = 4
    SELLSTOP = 5
    OTHER = 6

d_order_type_sign = {
	OP.BUY: 1, # BUY
	OP.SELL: -1, # SELL
    OP.BUYLIMIT: 1, # BUYLIMIT
    OP.BUYSTOP: 1, # BUYSTOP
    OP.SELLLIMIT: -1, # SELLLIMIT
    OP.SELLSTOP: -1, # SELLSTOP
    OP.OTHER: 0
}
    
class PERIOD(Enum):
    """All predefined timeframes of charts have unique identifiers.
    The PERIOD.CURRENT identifier means the current period of a chart,
    at which a MQL bridge is running.
    http://docs.mql4.com/constants/chartconstants/enum_timeframes

            >>> PERIOD.M1
            >>> PERIO.H4

    """   
    CURRENT = 0
    M1 = 1
    #M2 = 2
    #M3 = 3
    #M4 = 4
    M5 = 5
    #M6 = 6
    M10 = 10
    M12 = 12
    M15 = 15
    M20 = 20
    M30 = 30
    H1 = 60
    #H2 = 120
    #H3 = 180
    H4 = 240
    #H6 = 360
    #H8 = 480
    #H12 = 720
    D1 = 1440
    W1 = 10080
    MN1 = 43200

def pip_position(symbol):
    N = len(symbol)
    if N == 6:
        cur1 = symbol[0:3]
        cur2 = symbol[3:6]
        
        if cur2 == "JPY":
            return(2)
        else:
            return(4)
    elif N == 0:
        return(0)
    else:
        logging.error("Can't get pip position for %r" % symbol)
        return(0) #np.nan
        #raise(NotImplementedError)