//+------------------------------------------------------------------+
//|                                             json_rpc_example.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

#include <json_rpc.mqh>
//+------------------------------------------------------------------+
//| Sample JSON RPC 2.0 to display Comment                           |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_Request_Sample_Comment()
  {
   JSON_Dict *json_rpc_request=new JSON_Dict();

   json_rpc_request.Append("jsonrpc",JSON_RPC_VERSION);

   json_rpc_request.Append("method","Comment");
//json_rpc.Append("method","Print");

   JSON_List json_list_params;
   datetime dt=TimeLocal(); //TimeCurrent();
   json_list_params.Append("Hello Eiffel Tower!"+" - "+TimeToStr(dt,TIME_SECONDS));
   json_rpc_request.Append("params",json_list_params);

   json_rpc_request.Append("id","12340"); // I'm using id as string - specification allow integer

   string s_json_rpc_request=json_rpc_request.Str();
   delete json_rpc_request;
   return(s_json_rpc_request);
  }
//+------------------------------------------------------------------+
//| Sample JSON RPC 2.0 to display Comment                           |
//| Caution! Named parameters are currently not supported            |
//| in this bridge                                                   |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_with_named_parameters_Request_Sample_Comment()
  {
   JSON_Dict *json_rpc_request=new JSON_Dict();

   json_rpc_request.Append("jsonrpc",JSON_RPC_VERSION);

   json_rpc_request.Append("method","Comment");
//json_rpc.Append("method","Print");

// 
   JSON_Dict json_dict_params;
   datetime dt=TimeCurrent();
   json_dict_params.Append("msg","Hello Eiffel Tower!"+" - "+TimeToStr(dt,TIME_SECONDS));
   json_rpc_request.Append("params",json_dict_params);

   json_rpc_request.Append("id","12341"); // I'm using id as string - specification allow integer

   string s_json_rpc_request=json_rpc_request.Str();
   delete json_rpc_request;
   return(s_json_rpc_request);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_Request_Sample_Add_Raw()
  {
   JSON_Dict *json_rpc_request=new JSON_Dict();

   json_rpc_request.Append("jsonrpc",JSON_RPC_VERSION);

   json_rpc_request.Append("method","Add");

   JSON_List json_list_params;
   json_list_params.Append(10);
   json_list_params.Append(12);
   json_rpc_request.Append("params",json_list_params);

   json_rpc_request.Append("id","12342"); // I'm using id as string - specification allow integer

   string s_json_rpc_request=json_rpc_request.Str();
   delete json_rpc_request;
   return(s_json_rpc_request);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_Request_Sample_Add()
  {
   JSON_RPC_2_0_Request *req=new JSON_RPC_2_0_Request("Add");
   req.params.Append(10);
   req.params.Append(12);
   req.Append("params", req.params);
   string s_json_rpc_request=req.Str();
   delete req;
   return(s_json_rpc_request);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_Response_Integer_Result()
  {
   JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response("1234");
   response.Append("result",10);
   string s_json_rpc_response=response.Str();
   delete response;
   return(s_json_rpc_response);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_Response_Array_Integers_Result()
  {
   JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response("1234");
   JSON_List results;
   results.Append(10);
   results.Append(11);
   response.Append("result",results);
   string s_json_rpc_response=response.Str();
   delete response;
   return(s_json_rpc_response);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_Response_Dict_Integers_Result()
  {
   JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response("1234");
   JSON_Dict results;
   results.Append("a", 10);
   results.Append("b", 11);
   response.Append("result",results);
   string s_json_rpc_response=response.Str();
   delete response;
   return(s_json_rpc_response);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_JSON_RPC_2_0_Response_Error()
  {
   JSON_RPC_2_0_Response_Error *response=new JSON_RPC_2_0_Response_Error("1234",-32600,"Invalid Request");
   string s_json_rpc_response=response.Str();
   delete response;
   return(s_json_rpc_response);
  }
//+------------------------------------------------------------------+
