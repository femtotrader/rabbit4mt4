//+------------------------------------------------------------------+
//|                                        rabbit4mt4_ticks_emit.mq4 |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

extern string g_terminal_id_setting="mt4_demo01_123456"; //terminal_id

#include <rabbit4mt4.mqh>
#include <rabbit4mt4_config.mqh>

#include <display_chart.mqh>

int result;
string symbol;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

void DispMQVersion() 
  {
   string mq_version;
   mq_version=GetMQVersion();
   Print(mq_version);
   Comment(mq_version);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("OnInit");
   symbol=Symbol();

   ObjectsDeletePrefixed("about_");
   About_Display_TerminalID(g_terminal_id_setting);

   result=InitializeMQConnection(g_rabbitmq_host_name_setting,g_rabbitmq_username,g_rabbitmq_password,g_rabbitmq_virtualhost,g_rabbitmq_exchange_setting,g_terminal_id_setting);
   if(result!=0)
     {
      string msg;
      msg="Can't initialize RabbitMQ connection";
      Print(msg);
      return(INIT_FAILED); // bad connect
     }

   DispMQVersion();

//---

//result = SendTick(symbol, Bid, Ask); // uncomment for test (when no incoming ticks)

//WaitMessage();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("OnDeinit");
   DisableWaitMessage();
   Print("Close connection");
   result=CloseMQConnection();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Print("OnTick");
   DispMQVersion();

   result=SendTickToMQ(symbol,Bid,Ask);

//WaitMessage();

//string msg;
//msg = GetMessage();
//Print(msg);

  }
//+------------------------------------------------------------------+
