//+------------------------------------------------------------------+
//|                                        rabbit4mt4_ticks_emit.mq4 |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

#include <rabbit4mt5.mqh>
#include <rabbit4mt5_config.mqh>
extern string g_terminal_id_setting="mt5_demo01_123456"; //terminal_id

int result;
string symbol;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   symbol=Symbol();

   result=InitializeMQConnection(g_rabbitmq_host_name_setting,g_rabbitmq_username,g_rabbitmq_password,g_rabbitmq_exchange_setting,g_terminal_id_setting);

//---

//result = SendTick(symbol, Bid, Ask); // uncomment for test (when no incoming ticks)

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Close connection");
   result=CloseMQConnection();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   result=SendTickToMQ(symbol,Bid,Ask);
  }
//+------------------------------------------------------------------+
