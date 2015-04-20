//+------------------------------------------------------------------+
//|                                                     json_rpc.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

//http://en.wikipedia.org/wiki/JSON-RPC
//http://www.jsonrpc.org/specification

#include <json.mqh> // to parse JSON documents
#include <json_toolbox.mqh> // to create JSON documents
#include <uuid.mqh> // Universally Unique IDentifier (UUID)
#include <orders_prices.mqh>
#include <datetime_toolbox.mqh>

//#include <rabbit4mt4_logging.mqh>

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define JSON_RPC_VERSION   "2.0"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int JSON_RPC_Parse_Error(int error_code,string error_message,string json_rpc_request)
  {
   logging_error(StringFormat("JSON RPC parse error - %02d - %s",error_code,error_message));
   logging_error(json_rpc_request);
   return(error_code);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//| RPC error code
//|  1 : Can't find 'jsonrpc' (JSON-RPC version)
//|  2 : Unsupported JSON-RPC version
//|  3 : Can't find 'id' (request_id)
//|  4 : Unsupported 'id' type
//|  5 : Can't find 'method'
//|  6 : Method name can't lowered
//|  7 : Undefined method
//|  8 : Can't find 'params'
//|  9 : Bad parameters count
//| 10 : Can't find element '%d' in params
//+------------------------------------------------------------------+
int Execute_JSON_RPC_Request(JSONParser *parser,string json_rpc_request,string  &s_request_id,string &s_json_rpc_response)
  {

   logging_info("Execute RPC: "+json_rpc_request);

// s_request_id and s_json_rpc_response are passed as reference
// in order to output request_id and s_json_rpc_response
   s_request_id="";
   s_json_rpc_response="";

   JSONValue *jv=parser.parse(json_rpc_request);

   string method;
   string jsonrpc_version;

   if(jv==NULL)
     {
      logging_error(StringFormat("JSONParser error: %s %s",parser.getErrorCode(),parser.getErrorMessage()));
     }
   else
     {
      logging_debug("PARSED:"+jv.toString());
      if(jv.isObject())
        {
         JSONObject *jo=jv;

         if(jo.getString("jsonrpc",jsonrpc_version))
           {
            if(jsonrpc_version!=JSON_RPC_VERSION)
              {
               delete jo;
               delete jv;
               return(JSON_RPC_Parse_Error(2,StringFormat("Unsupported JSON-RPC version '%s'", jsonrpc_version),json_rpc_request));
              }
           }
         else
           {
            delete jo;
            return(JSON_RPC_Parse_Error(1,"Can't find 'jsonrpc' (JSON-RPC version)",json_rpc_request));
           }

         if(!jo.getHash().hContainsKey("id"))
           {
            delete jo;
            return(JSON_RPC_Parse_Error(3,"Can't find 'id'",json_rpc_request));
           }

         JSONValue*jsv=jo.getValue("id");
         if(jsv.isString())
           {
            logging_debug("'id' is string");
            s_request_id=jsv.getString();
           }
         else if(jsv.isNumber())
           { // ToFix : bug in json.mqh
            logging_debug("'id' is number");
            s_request_id=IntegerToString(jsv.getLong());
            delete jo;
            return(JSON_RPC_Parse_Error(4,"Unsupported 'id' type",json_rpc_request));
           }
         else
           {
            logging_debug("'id' is undef type");
            //Print(jsv.isString());
            //Print(jsv.isNull()); // ? ToFix: 
            //Print(jsv.isObject());
            //Print(jsv.isArray());
            //Print(jsv.isNumber());
            //Print(jsv.isBool());


            delete jo;

            return(JSON_RPC_Parse_Error(4,"Unsupported 'id' type ('id' is neither string or number)",json_rpc_request));
           }

         delete jsv;

         string s_param;

         // Safe access in case JSON data is missing or different.
         if(jo.getString("method",method))
           {
            logging_debug("method = "+method);
            if(!StringToLower(method))
              {
               delete jo;
               return(JSON_RPC_Parse_Error(6,"Method name can't lowered",json_rpc_request));
              }

            JSONArray*ja_params=jo.getArray("params");
            if(ja_params==NULL)
              {
               delete ja_params;
               delete jo;
               return(JSON_RPC_Parse_Error(7,"Can't find 'params' array",json_rpc_request));
              }

            //logging_debug("params=",ja_params.toString());

            // only JSON-RPC 2.0 with positionnal parameters

            if(method=="idn") // display terminal_id as Comment
              {
               IDN();
               return(0);
              }

            else if(method=="comment") // ToDo - ToFix - what happened in case of malformed RPC (no params...)
              {
               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               string msg;
               int index=0;
               if(!ja_params.getString(index,msg))
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(10,StringFormat("Can't find element '%d' in params", index),json_rpc_request));

                 }
               Comment(string_unescape(msg)); // Run the 'Comment' command as expected by RPC
               delete ja_params;
              }

            else if(method=="print")
              {
               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               string msg;
               int index=0;
               if(!ja_params.getString(index,msg))
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(10,StringFormat("Can't find element '%d' in params", index),json_rpc_request));

                 }
               Print(string_unescape(msg)); // Run the 'Print' command as expected by RPC
               delete ja_params;
              }

            else if(method=="echo") // receive a string return this echoed string
              {
               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               string msg;
               int index=0;
               if(!ja_params.getString(index,msg))
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(10,StringFormat("Can't find element '%d' in params", index),json_rpc_request));

                 }

               JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(s_request_id);
               response.Append("result",StringFormat("[ECHO] %s",msg));
               s_json_rpc_response=response.Str();
               delete ja_params;
              }
            else if(method=="add")
              {
               if(ja_params.size()!=2)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               int a;
               int b;
               int result;

               jsv=jo.getValue("params");
               JSONValue*jsv_param;

               jsv_param=jo.getArray("params").getValue(0);
               s_param=jsv_param.getString();
               a=(int) StringToInteger(s_param);

               jsv_param=jo.getArray("params").getValue(1);
               s_param=jsv_param.getString();
               b=(int) StringToInteger(s_param);

               delete jsv_param;

               result=a+b;
               string msg=StringConcatenate("a+b=",result);
               Comment(msg);
               Print(msg);

               JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(s_request_id);
               response.Append("result",IntegerToString(result));
               s_json_rpc_response=response.Str();
               delete response;
               delete ja_params;
              }
            else if(method=="marketinfo")
              {
               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               jsv=jo.getValue("params");
               JSONValue*jsv_param;
               jsv_param=jo.getArray("params").getValue(0);
               string symbol=jsv_param.getString();
               if(symbol=="")
                 {
                  symbol=Symbol();
                 }

               s_json_rpc_response=JSON_RPC_Response_MarketInfo(s_request_id,symbol);
               delete ja_params;
              }
            else if(method=="accountinformation")
              {
               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }
               s_json_rpc_response=JSON_RPC_Response_AccountInformation(s_request_id);
               delete ja_params;
              }
            else if(method=="accounthistory")
              {
               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }
               jsv=jo.getValue("params");
               JSONValue*jsv_param;
               jsv_param=jo.getArray("params").getValue(0);
               s_param=jsv_param.getString();
               int sizeLimit=(int) StringToInteger(s_param);

               s_json_rpc_response=JSON_RPC_Response_AccountHistory(s_request_id,sizeLimit);
               delete ja_params;
              }
            else if(method=="accounttrades")
              {
               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }
               jsv=jo.getValue("params");
               JSONValue*jsv_param;
               jsv_param=jo.getArray("params").getValue(0);
               s_param=jsv_param.getString();
               int sizeLimit=(int) StringToInteger(s_param);
               s_json_rpc_response=JSON_RPC_Response_AccountTrades(s_request_id,sizeLimit);
               delete ja_params;
              }
            else if(method=="quotes")
              {
               if(ja_params.size()!=3)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }
               jsv=jo.getValue("params");
               JSONValue*jsv_param;
               
               jsv_param=jo.getArray("params").getValue(0);
               string symbol=jsv_param.getString();

               jsv_param=jo.getArray("params").getValue(1);
               s_param=jsv_param.getString();
               int timeframe=(int) StringToInteger(s_param);

               jsv_param=jo.getArray("params").getValue(2);
               s_param=jsv_param.getString();
               int sizeLimit=(int) StringToInteger(s_param);
               
               s_json_rpc_response=JSON_RPC_Response_Quotes(s_request_id,symbol,timeframe,sizeLimit);
               delete ja_params;
              }


            else if(method=="ordersend")
              {
               if(ja_params.size()!=10)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               string symbol,comment;
               int ticket=-1;
               int cmd,magic,slippage;
               double volume,price,stoploss,takeprofit;

               jsv=jo.getValue("params");
               JSONValue*jsv_param;

               jsv_param=jo.getArray("params").getValue(0);
               symbol=jsv_param.getString();

               jsv_param=jo.getArray("params").getValue(1);
               s_param=jsv_param.getString();
               cmd=(int) StringToInteger(s_param);

               jsv_param=jo.getArray("params").getValue(2);
               s_param= jsv_param.getString();
               volume =(double) StringToDouble(s_param);

               jsv_param=jo.getArray("params").getValue(3);
               s_param=jsv_param.getString();
               price=(double) StringToDouble(s_param);
               if(price<0)
                 {
                  price=getPrice(CMD_OPEN,cmd,symbol);
                 }

               jsv_param=jo.getArray("params").getValue(4);
               s_param=jsv_param.getString();
               slippage=(int) StringToInteger(s_param);
               if(slippage<0)
                 {
                  slippage=g_slippage_default;
                 }

               jsv_param=jo.getArray("params").getValue(5);
               s_param=jsv_param.getString();
               stoploss=(double) StringToDouble(s_param);
               //if (stoploss<0) {
               //   stoploss = 0;
               //}

               jsv_param=jo.getArray("params").getValue(6);
               s_param=jsv_param.getString();
               takeprofit=(double) StringToDouble(s_param);
               //if (takeprofit<0) {
               //   takeprofit = 0;
               //}

               jsv_param=jo.getArray("params").getValue(7);
               comment=jsv_param.getString();

               jsv_param=jo.getArray("params").getValue(8);
               s_param=jsv_param.getString();
               magic=(int) StringToInteger(s_param);

               jsv_param=jo.getArray("params").getValue(9);
               s_param=jsv_param.getString();
               datetime expiration=(int) StringToInteger(s_param);

               delete jsv_param;

               logging_info(StringFormat("OrderSend symbol=%s vol=%f price=%f slippage=%d stoploss=%f takeprofit=%f expiration=%s",symbol,volume,price,slippage,stoploss,takeprofit,TimeToString(expiration,TIME_DATE|TIME_SECONDS)));
               ticket=OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,expiration);

               if(ticket>0)
                 {
                  JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(s_request_id);
                  response.Append("result",ticket);
                  s_json_rpc_response=response.Str();
                  delete response;
                 }
               else
                 {
                  JSON_RPC_2_0_Response_Error *response=new JSON_RPC_2_0_Response_Error(s_request_id,JsonRpcError_InvalidRequest);
                  s_json_rpc_response=response.Str();
                  delete response;
                 }

               delete ja_params;
              }

            else if(method=="orderclose")
              {
               if(ja_params.size()!=4)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               int ticket=-1;
               int cmd,slippage;
               double volume,price;
               string symbol;

               bool b_result=false;

               jsv=jo.getValue("params");
               JSONValue*jsv_param;

               jsv_param=jo.getArray("params").getValue(0);
               s_param=jsv_param.getString();
               ticket=(int) StringToInteger(s_param);

               JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(s_request_id);

               int b_order_selected=false;
               if(ticket>0)
                 {
                  b_order_selected=OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
                 }
               else
                 {
                  b_order_selected=OrderSelect(-ticket-1,SELECT_BY_POS,MODE_TRADES);
                 }

               if(b_order_selected)
                 {
                  ticket=OrderTicket();
                  cmd=OrderType();
                  symbol=OrderSymbol();

                  price=getPrice(CMD_CLOSE,cmd,symbol);

                  jsv_param=jo.getArray("params").getValue(1);
                  s_param=jsv_param.getString();
                  volume=(double) StringToDouble(s_param);
                  if(volume<0)
                    {
                     volume=OrderLots();
                    }

                  jsv_param=jo.getArray("params").getValue(3);
                  s_param = jsv_param.getString();
                  slippage=(int) StringToInteger(s_param);
                  if(slippage<0)
                    {
                     slippage=g_slippage_default;
                    }

                  logging_info(StringFormat("OrderClose ticket='%d' vol=%f price=%f slippage=%d",ticket,volume,price,slippage));
                  b_result=OrderClose(ticket,volume,price,slippage);

                  response.Append("result",b_result);
                  s_json_rpc_response=response.Str();
                 }
               else
                 {
                  logging_warning(StringFormat("ticket %s wasn't closed because it can be selected",IntegerToString(ticket)));

                  response.Append("result",false);
                  s_json_rpc_response=response.Str();
                 }

               delete response;
               delete ja_params;

              }

            else if(method=="orderdelete")
              {

               if(ja_params.size()!=1)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               jsv=jo.getValue("params");
               JSONValue*jsv_param;

               int ticket=-1;
               bool b_result=false;

               jsv_param=jo.getArray("params").getValue(0);
               s_param=jsv_param.getString();
               ticket=(int) StringToInteger(s_param);

               if(ticket<0)
                 {
                  if(OrderSelect(-ticket-1,SELECT_BY_POS,MODE_TRADES))
                    {
                     ticket=OrderTicket();
                    }
                 }

               logging_info(StringFormat("OrderDelete ticket='%d",ticket));
               b_result=OrderDelete(ticket);

               JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(s_request_id);
               response.Append("result",b_result);
               s_json_rpc_response=response.Str();

               delete response;
               delete ja_params;
              }

            else if(method=="ordermodify")
              {

               if(ja_params.size()!=5)
                 {
                  delete ja_params;
                  delete jo;
                  return(JSON_RPC_Parse_Error(9,"Bad parameters count",json_rpc_request));
                 }

               jsv=jo.getValue("params");
               JSONValue*jsv_param;

               int ticket=-1;
               bool b_result=false;

               jsv_param=jo.getArray("params").getValue(0);
               s_param=jsv_param.getString();
               ticket=(int) StringToInteger(s_param);

               jsv_param=jo.getArray("params").getValue(1);
               s_param=jsv_param.getString();
               double price=(double) StringToDouble(s_param);

               jsv_param=jo.getArray("params").getValue(2);
               s_param=jsv_param.getString();
               double stoploss=(double) StringToDouble(s_param);

               jsv_param=jo.getArray("params").getValue(3);
               s_param=jsv_param.getString();
               double takeprofit=(double) StringToDouble(s_param);

               jsv_param=jo.getArray("params").getValue(4);
               s_param=jsv_param.getString();
               datetime expiration=(int) StringToInteger(s_param);

               if(ticket<0)
                 {
                  if(OrderSelect(-ticket-1,SELECT_BY_POS,MODE_TRADES))
                    {
                     ticket=OrderTicket();
                    }
                 }

               if(price<0)
                 {
                  price=OrderOpenPrice();
                 }

               logging_info(StringFormat("OrderModify ticket=%d price=%f stoploss=%f takeprofit=%f expiration=%s",ticket,price,stoploss,takeprofit,TimeToString(expiration,TIME_DATE|TIME_SECONDS)));
               b_result=OrderModify(ticket,price,stoploss,takeprofit,expiration);

               JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(s_request_id);
               response.Append("result",b_result);
               s_json_rpc_response=response.Str();

               delete response;
               delete ja_params;
              }
            else
              {
               delete jo;
               return(JSON_RPC_Parse_Error(7,"Undefined method '"+method+"'",json_rpc_request));
              }

           }
         else
           {
            delete jo;
            return(JSON_RPC_Parse_Error(5,"Can't find 'method'",json_rpc_request));
           }

        }
      delete jv;
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IDN()
  {
   string msg="terminal_id: "+g_terminal_id_setting;
   msg = msg + "\n" + "TimeGMT: " + TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS);
   msg = msg + "\n" + "TimeCurrent: " + TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS);
   msg = msg + "\n" + "TimeLocal: " + TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS);
   msg = msg + "\n" + "TimeGMTOffset_h: " + DoubleToString(TimeGMTOffset() / 3600.0);
   msg = msg + "\n" + "TimeDaylightSavings_h: " + DoubleToString(TimeDaylightSavings() / 3600.0);
   msg = msg + "\n" + "getTimestamp: " + IntegerToString(getCurrentUnixTimestampGMT_us());
   Comment(msg);
   Print(msg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_RPC_Response_AccountInformation(string request_id)
  {
   JSON_Dict json_result_data;
   json_result_data.Append("balance", AccountBalance(), 2);
   json_result_data.Append("credit", AccountCredit());
   json_result_data.Append("company", AccountCompany());
   json_result_data.Append("currency", AccountCurrency());
   json_result_data.Append("equity", AccountEquity(),2);
   json_result_data.Append("free_margin", AccountFreeMargin(),2);
   json_result_data.Append("free_margin_mode", AccountFreeMarginMode());
   json_result_data.Append("leverage", AccountLeverage());
   json_result_data.Append("margin", AccountMargin());
   json_result_data.Append("name", AccountName());
   json_result_data.Append("number", AccountNumber());
   json_result_data.Append("profit", AccountProfit());
   json_result_data.Append("server", AccountServer());
   json_result_data.Append("stopout_level", AccountStopoutLevel());
   json_result_data.Append("stopout_mode", AccountStopoutMode());

   JSON_Dict json_result;
   json_result.Append("timestamp", getCurrentUnixTimestampGMT_us());
   json_result.Append("data",json_result_data);

   JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(request_id);
   response.Append("result",json_result);
   string s_json_rpc_response=response.Str();
   delete response;

   return(s_json_rpc_response);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_RPC_Response_MarketInfo(string request_id,string symbol)
  {
   JSON_Dict json_result_data;

   //json_result_data.Append("symbol", symbol);
   json_result_data.Append("low", (string) MarketInfo(symbol,MODE_LOW));
   json_result_data.Append("high", (string) MarketInfo(symbol,MODE_HIGH));
   json_result_data.Append("time", getUnixTimestamp_us((datetime) MarketInfo(symbol,MODE_TIME))); // last tick time <> timestamp
   json_result_data.Append("bid", (string) MarketInfo(symbol,MODE_BID));
   json_result_data.Append("ask", (string) MarketInfo(symbol,MODE_ASK));
   json_result_data.Append("point", (string) MarketInfo(symbol,MODE_POINT));
   json_result_data.Append("digits", (string) MarketInfo(symbol,MODE_DIGITS));
   json_result_data.Append("spread", (string) MarketInfo(symbol,MODE_SPREAD));
   json_result_data.Append("stoplevel", (string) MarketInfo(symbol,MODE_STOPLEVEL));
   json_result_data.Append("lotsize", (string) MarketInfo(symbol,MODE_LOTSIZE));
   json_result_data.Append("tickvalue", (string) MarketInfo(symbol,MODE_TICKVALUE));
   json_result_data.Append("ticksize", (string) MarketInfo(symbol,MODE_TICKSIZE));
   json_result_data.Append("swaplong", (string) MarketInfo(symbol,MODE_SWAPLONG));
   json_result_data.Append("swapshort", (string) MarketInfo(symbol,MODE_SWAPSHORT));
   json_result_data.Append("starting", (string) MarketInfo(symbol,MODE_STARTING));
   json_result_data.Append("expiration", (string) MarketInfo(symbol,MODE_EXPIRATION));
   json_result_data.Append("tradeallowed", (string) MarketInfo(symbol,MODE_TRADEALLOWED));
   json_result_data.Append("minlot", (string) MarketInfo(symbol,MODE_MINLOT));
   json_result_data.Append("lotstep", (string) MarketInfo(symbol,MODE_LOTSTEP));
   json_result_data.Append("maxlot", (string) MarketInfo(symbol,MODE_MAXLOT));
   json_result_data.Append("swaptype", (string) MarketInfo(symbol,MODE_SWAPTYPE));
   json_result_data.Append("profitcalcmode", (string) MarketInfo(symbol,MODE_PROFITCALCMODE));
   json_result_data.Append("margincalcmode", (string) MarketInfo(symbol,MODE_MARGINCALCMODE));
   json_result_data.Append("margininit", (string) MarketInfo(symbol,MODE_MARGININIT));
   json_result_data.Append("marginmaintenance", (string) MarketInfo(symbol,MODE_MARGINMAINTENANCE));
   json_result_data.Append("marginhedged", (string) MarketInfo(symbol,MODE_MARGINHEDGED));
   json_result_data.Append("marginrequired", (string) MarketInfo(symbol,MODE_MARGINREQUIRED));
   json_result_data.Append("freezelevel", (string) MarketInfo(symbol,MODE_FREEZELEVEL));

   JSON_Dict json_result;
   json_result.Append("timestamp", getCurrentUnixTimestampGMT_us());
   json_result.Append("data",json_result_data);

   JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(request_id);
   response.Append("result",json_result);
   string s_json_rpc_response=response.Str();
   delete response;

   return(s_json_rpc_response);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_RPC_Response_AccountHistory(string request_id,int sizeLimit=-1)
  {
   int sizeTotal=OrdersHistoryTotal();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(sizeLimit<0)
     {
      sizeLimit=sizeTotal;
     }
   return( JSON_RPC_Response_AccountHistoryTrades(request_id, MODE_HISTORY, sizeTotal, sizeLimit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_RPC_Response_AccountTrades(string request_id,int sizeLimit=-1)
  {
   int sizeTotal=OrdersTotal();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(sizeLimit<0)
     {
      sizeLimit=sizeTotal;
     }
   return( JSON_RPC_Response_AccountHistoryTrades(request_id, MODE_TRADES, sizeTotal, sizeLimit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_RPC_Response_AccountHistoryTrades(string request_id,int pool,int sizeTotal,int sizeLimit)
  {
   JSON_Dict json_result_data;

   JSON_List json_list_ticket;
   JSON_List json_list_opentime;
   JSON_List json_list_type;
   JSON_List json_list_volume;
   JSON_List json_list_symbol;
   JSON_List json_list_openprice;
   JSON_List json_list_stoploss;
   JSON_List json_list_takeprofit;
   JSON_List json_list_closetime;
   JSON_List json_list_closeprice;
   JSON_List json_list_commission;
   JSON_List json_list_swap;
   JSON_List json_list_profit;
   JSON_List json_list_comment;
   JSON_List json_list_magicnumber;

//for(int i=0; i<sizeTotal; i++)
   for(int i=sizeTotal-1; i>=sizeTotal-sizeLimit; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(i,SELECT_BY_POS,pool))
        {

         json_list_ticket.Append(OrderTicket());
         json_list_opentime.Append(OrderOpenTime());
         json_list_type.Append(OrderType());
         json_list_volume.Append(OrderLots());
         json_list_symbol.Append(OrderSymbol());
         json_list_openprice.Append(OrderOpenPrice());
         json_list_stoploss.Append(OrderStopLoss());
         json_list_takeprofit.Append(OrderTakeProfit());
         json_list_closetime.Append(OrderCloseTime());
         json_list_closeprice.Append(OrderClosePrice());
         json_list_commission.Append(OrderCommission());
         json_list_swap.Append(OrderSwap());
         json_list_profit.Append(OrderProfit());
         json_list_comment.Append(OrderComment());
         json_list_magicnumber.Append(OrderMagicNumber());

        }
     }

   json_result_data.Append("ticket", json_list_ticket);
   json_result_data.Append("opentime", json_list_opentime);
   json_result_data.Append("type", json_list_type);
   json_result_data.Append("volume", json_list_volume);
   json_result_data.Append("symbol", json_list_symbol);
   json_result_data.Append("openprice", json_list_openprice);
   json_result_data.Append("stoploss", json_list_stoploss);
   json_result_data.Append("takeprofit", json_list_takeprofit);
   json_result_data.Append("closetime", json_list_closetime);
   json_result_data.Append("closeprice", json_list_closeprice);
   json_result_data.Append("commission", json_list_commission);
   json_result_data.Append("swap", json_list_swap);
   json_result_data.Append("profit", json_list_profit);
   json_result_data.Append("comment", json_list_comment);
   json_result_data.Append("magicnumber", json_list_magicnumber);

   JSON_Dict json_result;
   json_result.Append("timestamp", getCurrentUnixTimestampGMT_us());
   json_result.Append("data",json_result_data);

   JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(request_id);
   response.Append("result",json_result);
   string s_json_rpc_response=response.Str();
   delete response;

   return(s_json_rpc_response);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_RPC_Response_Quotes(string request_id,string symbol,int timeframe,int sizeLimit)
  {

   int N;
   if(sizeLimit<0)
     {
      N=iBars(symbol, timeframe);
     }
   else
     {
      N=sizeLimit;
     }

   PrintFormat("Count = %d",N);

   int digits_price=(int) MarketInfo(symbol,MODE_DIGITS);
   int digits_volume=0;

   JSON_Dict json_result_data;

   JSON_List json_list_time;
   JSON_List json_list_open;
   JSON_List json_list_high;
   JSON_List json_list_low;
   JSON_List json_list_close;
   JSON_List json_list_volume;

   for(int i=N-1; i>=0; i--)
     {
      //json_list_time.Append(TimeToStr(iTime(symbol,timeframe,i)));
      json_list_time.Append(getUnixTimestamp(iTime(symbol,timeframe,i))/60);
      json_list_open.Append((int) (iOpen(symbol,timeframe,i)*MathPow(10, digits_price)));
      json_list_high.Append((int) (iHigh(symbol,timeframe,i)*MathPow(10, digits_price)));
      json_list_low.Append((int) (iLow(symbol,timeframe,i)*MathPow(10, digits_price)));
      json_list_close.Append((int) (iClose(symbol,timeframe,i)*MathPow(10, digits_price)));
      json_list_volume.Append(iVolume(symbol,timeframe,i));
     }

   json_result_data.Append("time", json_list_time);
   json_result_data.Append("open", json_list_open);
   json_result_data.Append("high", json_list_high);
   json_result_data.Append("low", json_list_low);
   json_result_data.Append("close", json_list_close);
   json_result_data.Append("volume", json_list_volume);

   JSON_Dict json_result;
   json_result.Append("timestamp", getCurrentUnixTimestampGMT_us());
   
   JSON_Dict json_result_digits;
   json_result_digits.Append("price", digits_price);
   json_result_digits.Append("volume", digits_volume);
   json_result.Append("digits", json_result_digits);
   
   //json_result.Append("digits_price", digits_price);
   //json_result.Append("digits_volume", digits_volume);
   json_result.Append("data",json_result_data);

   JSON_RPC_2_0_Response *response=new JSON_RPC_2_0_Response(request_id);
   response.Append("result",json_result);
   string s_json_rpc_response=response.Str();
   delete response;

   return(s_json_rpc_response);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int JSON_Response_To_File(string file_suffix,string s_json_response)
  {
   string FileName=StringFormat("response_%s.json",file_suffix );
   FileDelete(FileName);
   int file_handle=FileOpen(FileName ,FILE_READ|FILE_WRITE|FILE_CSV);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(file_handle!=INVALID_HANDLE)
     {
      logging_info(StringFormat("Output to: \"%s\\Files\\%s\"",TerminalInfoString(TERMINAL_DATA_PATH),FileName));
      FileWrite(file_handle,s_json_response);
      FileClose(file_handle);
      return(0);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      return(1);
     }
  }
//+------------------------------------------------------------------+

string json_rpc_response_void(string request_id)
  {

//delete req;

   return("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JSON_RPC_2_0_Request : public JSON_Dict
  {

public:
                     JSON_RPC_2_0_Request(string method,string request_id);
                    ~JSON_RPC_2_0_Request() {delete params;};

   JSON_List        *params;
   //string            Str();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
JSON_RPC_2_0_Request::JSON_RPC_2_0_Request(string method,string request_id=NULL)
  {
   Append("jsonrpc",JSON_RPC_VERSION);

   Append("method",method);

   params=new JSON_List();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(request_id==NULL)
     {
      //AppendNoDoubleQuotes("id","null");
      Append("id",uuid4());
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Append("id",request_id);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JSON_RPC_2_0_Response : public JSON_Dict
  {

public:
                     JSON_RPC_2_0_Response(string request_id);
                    ~JSON_RPC_2_0_Response() {};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
JSON_RPC_2_0_Response::JSON_RPC_2_0_Response(string request_id)
  {
   Append("jsonrpc",JSON_RPC_VERSION);

   Append("id",request_id);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum JsonRpcError  // enumeration of named JsonRpcError
  {
   JsonRpcError_ParseError,
   JsonRpcError_InvalidRequest,
   JsonRpcError_MethodNotFound,
   JsonRpcError_InvalidParams,
   JsonRpcError_InternalError
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JSON_RPC_2_0_Response_Error : public JSON_Dict
  {

public:
                     JSON_RPC_2_0_Response_Error(string request_id,int code,string message);
                     JSON_RPC_2_0_Response_Error(string request_id,JsonRpcError json_rpc_error_enum);

                    ~JSON_RPC_2_0_Response_Error() {};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
JSON_RPC_2_0_Response_Error::JSON_RPC_2_0_Response_Error(string request_id,int code,string message)
  {
   Append("jsonrpc",JSON_RPC_VERSION);

   JSON_Dict error;
   error.Append("code", code);
   error.Append("message", message);
   Append("error",error);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(request_id==NULL)
     {
      AppendNoDoubleQuotes("id","null");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Append("id",request_id);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
JSON_RPC_2_0_Response_Error::JSON_RPC_2_0_Response_Error(string request_id,JsonRpcError json_rpc_error_enum)
  {
   Append("jsonrpc",JSON_RPC_VERSION);

   JSON_Dict error;
   int code;
   string message;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(json_rpc_error_enum==JsonRpcError_ParseError)
     {
      code=-32700;
      message="Invalid JSON was received by the server.";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(json_rpc_error_enum==JsonRpcError_InvalidRequest)
     {
      code=-32600;
      message="The JSON sent is not a valid Request object.";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(json_rpc_error_enum==JsonRpcError_MethodNotFound)
     {
      code=-32601;
      message="The method does not exist / is not available.";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(json_rpc_error_enum==JsonRpcError_InvalidParams)
     {
      code=-32602;
      message="Invalid method parameter(s).";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(json_rpc_error_enum==JsonRpcError_InternalError)
     {
      code=-32603;
      message="Internal JSON-RPC error.";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      code=-1;
      message="undefined error code";
     }

   error.Append("code", code);
   error.Append("message", message);
   Append("error",error);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(request_id==NULL)
     {
      AppendNoDoubleQuotes("id","null");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Append("id",request_id);
     }
  }

//+------------------------------------------------------------------+
