//+------------------------------------------------------------------+
//|                                                   rabbit4mt4.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

#import "Rabbit4mt4.dll"
int InitializeMQConnection(string hostName,string username,string password,string virtualhost,string exchange,string terminal_id);
int SendTickToMQ(string symbol,double bid,double ask);
int SendMessageToMQ(string bindingkey,string message);
int CloseMQConnection();
string GetMQVersion(void);
int WaitMessage();
int DisableWaitMessage();
int EnableWaitMessage();
string GetMessage();
int SendMessageToQueue(string queue,string message);
#import
//+------------------------------------------------------------------+
