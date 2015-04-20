//+------------------------------------------------------------------+
//|                                          rabbit4mt5_dom_emit.mq5 |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"

#include <rabbit4mt5.mqh>
#include <rabbit4mt5_config.mqh>
extern string g_terminal_id_setting="mt5_demo01_123456"; //terminal_id

#include <dom_toolbox.mqh>
#include <Strings\String.mqh>
#include <display_price_volume.mqh>

input float g_broker_gmt_offset=3; //GMT offset

string routingkey;
string message;

string g_symbol;
string g_symbol_lowered;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---    
   int result;

   result=InitializeMQConnection(g_rabbitmq_host_name_setting,g_rabbitmq_username,g_rabbitmq_password,g_rabbitmq_exchange_setting,g_terminal_id_setting);

   g_symbol=Symbol();
   g_symbol_lowered=g_symbol;
   if(!StringToLower(g_symbol_lowered)) 
     {
      return(INIT_FAILED);
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Close connection");
   int result;
   result=CloseMQConnection();
  }
  
  

  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   int result;
//---

   int digits_price=(int) SymbolInfoInteger(g_symbol, SYMBOL_DIGITS); // 5 for EURUSD
   double pippoint = PipPoint(g_symbol);
   int pipdigits = PipDigits(g_symbol);
   int digits_volume=0;

//   message=tick_json_dict_message_with_orderbook(g_symbol,g_broker_gmt_offset, digits_price, digits_volume, pippoint, pipdigits);
message=tick_json_list_message_with_orderbook(g_symbol,g_broker_gmt_offset, digits_price, digits_volume, pippoint, pipdigits);

   if(StringLen(message)>0)
     {
      routingkey=StringFormat("%s.%s.%s.%s",g_terminal_id_setting,"events","dom",g_symbol_lowered);
      Print(StringFormat("Emit message to '%s': '%s'",routingkey,message));
      result=SendMessageToMQ(routingkey,message);

     }

  }
//+------------------------------------------------------------------+
