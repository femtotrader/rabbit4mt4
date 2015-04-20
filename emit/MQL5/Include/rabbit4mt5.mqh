//+------------------------------------------------------------------+
//|                                                   rabbit4mt5.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

#import "Rabbit4mt4.dll"
   int InitializeMQConnection(string hostName, string username, string password, string exchange, string terminal_id);
   int SendTickToMQ(string symbol, double bid, double ask);
   int SendMessageToMQ(string bindingkey, string message);
   int CloseMQConnection();
#import
