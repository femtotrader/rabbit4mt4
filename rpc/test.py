#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np
from enum import Enum

class OP(Enum):
    BUY = 0
    SELL = 1
    BUYLIMIT = 2
    SELLLIMIT = 3
    BUYSTOP = 4
    SELLSTOP = 5
    OTHER = 6

d = {"ticket": [100,101,102], "openprice": [1.05, 1.1, 1.11], "type": [OP.BUY, OP.SELL, OP.BUYLIMIT]}

df = pd.DataFrame(d)

print(df)

def pendings(df):
    return(df[(df['type']!=OP.BUY) & (df['type']!=OP.SELL) & (df['type']!=OP.OTHER)])

def opened(df):
    return(df[(df['type']==OP.BUY) | (df['type']==OP.SELL)])

oo = opened(df)

print(oo)

po = pendings(df)

print(po)

def tickets_gen(tickets, sep=","):
    """Returns ticket number (generator)"""
    if isinstance(tickets, pd.DataFrame):
        tickets = tickets["ticket"]
    elif isinstance(tickets, basestring):
        tickets = tickets.split(sep)
        tickets = map(lambda s: s.strip(), tickets)
    for ticket in tickets:
        yield(ticket)

print("pendings")
for ticket in tickets_gen(po):
    print(ticket)

print("opened")
for ticket in tickets_gen(oo):
    print(ticket)

print("opened (list)")
for ticket in tickets_gen([200, 201, 202]):
    print(ticket)

print("opened (string)")
for ticket in tickets_gen("200, 201, 202"):
    print("%r" % ticket)