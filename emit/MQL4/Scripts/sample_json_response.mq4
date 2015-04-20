//+------------------------------------------------------------------+
//|                                         sample_json_response.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict

#include <json_rpc.mqh>
#include <json_rpc_example.mqh>
#include <logging_basic.mqh>
extern int g_slippage_default=3; //default slippage
extern int g_logging_level_setting=0;
extern string g_terminal_id_setting="mt4_demo01_123456"; //terminal_id

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string s_json_response;
   string request_id = "123";
   //s_json_response = Get_JSON_RPC_2_0_Response_Integer_Result();
   //s_json_response = JSON_RPC_Response_MarketInfo("123", Symbol());
   //s_json_response = JSON_RPC_Response_AccountHistory(request_id,-1);
   //s_json_response = JSON_RPC_Response_AccountTrades(request_id,-1);
   string symbol= Symbol();
   int timeframe = PERIOD_H1;
   int sizeLimit = 10;
   s_json_response = JSON_RPC_Response_Quotes(request_id,symbol,timeframe,sizeLimit);
   
   Print(s_json_response);
   JSON_Response_To_File(g_terminal_id_setting, s_json_response);
   

  }
//+------------------------------------------------------------------+
