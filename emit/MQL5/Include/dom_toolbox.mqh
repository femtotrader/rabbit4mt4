//+------------------------------------------------------------------+
//|                                                  dom_toolbox.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"

#include <json_toolbox.mqh>
#include <string_toolbox.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void orderbookrow2jsonlist(JSON_List*json_list,MqlBookInfo  &priceArray[],int i,int digits_price,int digits_volume)
  {
   json_list.Append(priceArray[i].price, digits_price);
   json_list.Append(priceArray[i].volume,digits_volume);
   json_list.Append(priceArray[i].type);
   //return(json_list);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string tick_json_list_message_with_orderbook(string symbol,float broker_gmt_offset,int digits_price,int digits_volume,double pippoint,int pipdigits)
  {
   JSON_List json_list;

   MqlTick last_tick;

   if(SymbolInfoTick(symbol,last_tick))
     {
      //     Print(last_tick.time,": Bid = ",last_tick.bid," Ask = ",last_tick.ask,"  Volume = ",last_tick.volume,
      //           " LastDeal = ",last_tick.last);
     }
   else
     {
      string error_message="SymbolInfoTick() failed, error = "+(string) GetLastError();
      Print(error_message);
      json_list.Append("1"); // error
      json_list.Append(doublequote(error_message)); // error_message
      return(json_list.Str());
     }

   double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double spread=ask-bid;
   int spread_points=(int)MathRound(spread/SymbolInfoDouble(Symbol(),SYMBOL_POINT));

   json_list.Append(0); // error
   json_list.Append(""); // error_message
   json_list.Append(((int) SymbolInfoInteger(symbol,SYMBOL_TIME))-((int)(broker_gmt_offset*3600.0))); // unixtime_s
   json_list.Append(AccountInfoString(ACCOUNT_COMPANY)); // company
   json_list.Append((string) AccountInfoInteger(ACCOUNT_LOGIN)); // login
   json_list.Append(symbol); // symbol
   JSON_List *json_list_ob = new JSON_List();
   int size =orderbook2jsonlist(json_list_ob, symbol,digits_price,digits_volume); // ToFix
   json_list.Append(size); // orderbook_size
   json_list.Append(json_list_ob); // orderbook
   delete json_list_ob;
   json_list.Append(last_tick.ask, digits_price); // ask
   json_list.Append(last_tick.bid, digits_price); // bid
   json_list.Append(last_tick.volume,digits_volume); //"volume
   json_list.Append(last_tick.last,digits_price); // last
                                                  //json_list.Append(spread); // spread
   json_list.Append(spread_points); // spread_points

   return(json_list.Str());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string tick_json_dict_message_with_orderbook(string symbol,float broker_gmt_offset,int digits_price,int digits_volume,double pippoint,int pipdigits)
  {
   JSON_Dict json_dict;

   MqlTick last_tick;

   if(SymbolInfoTick(symbol,last_tick))
     {
      //     Print(last_tick.time,": Bid = ",last_tick.bid," Ask = ",last_tick.ask,"  Volume = ",last_tick.volume,
      //           " LastDeal = ",last_tick.last);
     }
   else
     {
      string error_message="SymbolInfoTick() failed, error = "+(string) GetLastError();
      Print(error_message);
      json_dict.Append("error", 1);
      json_dict.Append("error_message", error_message);
      return(json_dict.Str());
     }

   double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double spread=ask-bid;
   int spread_points=(int)MathRound(spread/SymbolInfoDouble(Symbol(),SYMBOL_POINT));
   double spread_pips=spread/pippoint;

   json_dict.Append("error", 0);
   json_dict.Append("error_message", "");
//json_dict.Append("time", doublequote((string)last_tick.time));
   json_dict.Append("unixtime_s",((int) SymbolInfoInteger(symbol,SYMBOL_TIME))-((int)(broker_gmt_offset*3600.0)));
//json_dict.Append("unixtime_ms", "0");
//json_dict.Append("unixtime_us", "0");
   json_dict.Append("company", AccountInfoString(ACCOUNT_COMPANY));
   json_dict.Append("login", (string) AccountInfoInteger(ACCOUNT_LOGIN));
   json_dict.Append("symbol", symbol);
//json_dict.Append("orderbook", orderbook2jsonlist(symbol, digits_price, digits_volume));
   JSON_Dict *json_ob=new JSON_Dict();
   json_dict.Append("orderbook",orderbook2jsondict(json_ob,symbol,digits_price,digits_volume));
   delete json_ob;
   json_dict.Append("ask", last_tick.ask, digits_price);
   json_dict.Append("bid", last_tick.bid, digits_price);
   json_dict.Append("volume", last_tick.volume, digits_volume);
   json_dict.Append("last", last_tick.last, digits_price);
   json_dict.Append("spread", spread, digits_price);
   json_dict.Append("spread_pips", spread_pips, pipdigits);
   json_dict.Append("spread_points", spread_points);

   return(json_dict.Str());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


int orderbook2jsonlist(JSON_List*json_ob, string symbol,int digits_price,int digits_volume)
  {
   int size=0;

   MqlBookInfo priceArray[];
   bool getBook=MarketBookGet(symbol,priceArray);


   if(getBook)
     {

      size=ArraySize(priceArray);
      //Print("MarketBookInfo for ",Symbol());

      for(int i=0;i<size;i++)
        {
         JSON_List *json_list=new JSON_List();
         orderbookrow2jsonlist(json_list, priceArray,i,digits_price,digits_volume);
         json_ob.Append(json_list);
         delete json_list;
        }
      return(json_ob.Size());
     }
   else
     {
      Print("Could not get contents of the symbol DOM '"+symbol+"'");
      return(0);
      //return(json_ob);
     }
  }
//+------------------------------------------------------------------+

int orderbook2jsondict(JSON_Dict *json_ob,string symbol,int digits_price,int digits_volume)
  {
   int size=0;

   MqlBookInfo priceArray[];
   bool getBook=MarketBookGet(symbol,priceArray);

//JSON_Dict * json_ob = new JSON_Dict();

   JSON_List*json_ob_price=new JSON_List();
   JSON_List*json_ob_volume=new JSON_List();
   JSON_List*json_ob_type=new JSON_List();

   if(getBook)
     {

      size=ArraySize(priceArray);
      //Print("MarketBookInfo for ",Symbol());

      for(int i=0;i<size;i++)
        {
         json_ob_price.Append(priceArray[i].price,digits_price);
         json_ob_volume.Append(priceArray[i].volume,digits_volume);
         json_ob_type.Append(priceArray[i].type);
        }
      json_ob.Append("price", json_ob_price);
      json_ob.Append("volume", json_ob_volume);
      json_ob.Append("type", json_ob_type);

      delete json_ob_price;
      delete json_ob_volume;
      delete json_ob_type;

      return(json_ob.Size());
     }
   else
     {
      Print("Could not get contents of the symbol DOM '"+symbol+"'");
      return(0);
      //return(json_ob.Size());
     }
  }
//+------------------------------------------------------------------+
