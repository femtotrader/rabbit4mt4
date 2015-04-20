//+------------------------------------------------------------------+
//|                               rabbit4mt4_execute_rpc_example.mq4 |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

extern string g_terminal_id_setting="mt4_demo01_123456"; //terminal_id

#include <json_toolbox.mqh> // to create JSON documents
#include <json_rpc.mqh> // JSON remote procedure call
#include <json_rpc_example.mqh> // some JSON RPC samples
#include <rabbit4mt4_config.mqh>

int g_logging_level_setting=0;
#include <logging_basic.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

int g_assert_nb_total=0;
int g_assert_nb_failed=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void assert(bool cond,string message="") 
  {
   g_assert_nb_total+=1;

   if(cond) 
     {
      Print("ok... ",message);
        } else {
      g_assert_nb_failed+=1;
      Print("FAIL  ",message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void summuary() 
  {
   Print("assert_nb_total : ",g_assert_nb_total);
   Print("assert_nb_failed: ",g_assert_nb_failed);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_01() 
  {
   JSONParser *parser=new JSONParser();

   bool b_result;

   string s_json_rpc_request;
   s_json_rpc_request="{\"jsonrpc\" : \"2.0\",\"params\" : [\"10\",\"12\"],\"method\" : \"Add\",\"id\" : \"12342\"}";
//string s_json_rpc_request="{\"jsonrpc\" : \"2.0\",\"params\" : [10,12],\"method\" : \"Add\",\"id\" : \"12342\"}";
   Print(s_json_rpc_request);

   JSONValue *jv=parser.parse(s_json_rpc_request);
   logging_debug("PARSED:"+jv.toString());
   JSONObject *jo=jv;
   JSONArray*ja_params=jo.getArray("params");
   string s_a;
//int a;
   b_result=ja_params.getString(0,s_a);
   Print("s_a=",s_a);
   assert(s_a=="10","a must be equal to '10'");
   Print("type(a)=",ja_params.getType());
   assert(b_result,"getString must return true");
   
   delete parser;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---

   JSONParser *parser=new JSONParser();

   bool b_result;
   string s_json_rpc_request="{\"jsonrpc\" : \"2.0\",\"params\" : [10,12],\"method\" : \"Add\",\"id\" : \"12342\"}";
   Print(s_json_rpc_request);

   JSONValue *jv=parser.parse(s_json_rpc_request);
   logging_debug("PARSED:"+jv.toString());
   JSONObject *jo=jv;
   JSONArray*ja_params=jo.getArray("params");
   long a;
   b_result=ja_params.getLong(0,a);
   Print("a=",a);
   assert(a==10,"a must be equal to 10");
   Print("type(a)=",ja_params.getType());
   assert(b_result,"getString must return true");

   summuary();

   delete ja_params;

   delete jv;
   delete parser;


/*

// {"jsonrpc": "2.0", "method": "add", "params": [5, 3], "id": 1}
// {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}
// {"jsonrpc": "2.0", "method": "Comment", "params": ["Hello Eiffel Tower!"], "id": 1}
   JSON_Dict *json_rpc_request=new JSON_Dict();
   string s_json_rpc_request;
   //s_json_rpc_request=Get_JSON_RPC_2_0_Sample_Comment(json_rpc_request);
   s_json_rpc_request=Get_JSON_RPC_2_0_Sample_Add(json_rpc_request);
   delete json_rpc_request;

   Print(s_json_rpc_request);
   int error_code;
   string request_id;
   string s_json_rpc_response;
   error_code = Execute_JSON_RPC_Request(parser,s_json_rpc_request,request_id, s_json_rpc_response);
   Print("error_code=", error_code);
   Print("request_id=", request_id);
   Print("json_rpc_response=", s_json_rpc_response);
   
*/

//JSON_RPC_2_0_Request *req=new JSON_RPC_2_0_Request("Add","1234");

/*
   JSON_RPC_2_0_Response_Error *response=new JSON_RPC_2_0_Response_Error("1234", -32600, "Invalid Request");
   string s_json_rpc_response=response.Str();
   delete response;
   //return(s_json_rpc_response);
   Print(s_json_rpc_response);
   */

//string s_json_response=JSON_RPC_Response_AccountInformation("1234");
//string s_json_response=JSON_RPC_Response_AccountHistory("1234");
//string s_json_response=JSON_RPC_Response_AccountTrades("1234");
//Print(s_json_response);

//JSON_Response_To_File(g_terminal_id_setting,s_json_response);

//delete parser;

  }
//+------------------------------------------------------------------+
