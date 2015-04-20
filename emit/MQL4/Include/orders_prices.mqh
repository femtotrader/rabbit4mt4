//+------------------------------------------------------------------+
//|                                                orders_prices.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property strict

//#define CMD_OPEN 0
//#define CMD_CLOSE 1

const int CMD_OPEN=0;
const int CMD_CLOSE=1;
// ask>bid => spread=ask-bid
// open buy at ask
// open sell at bid
// close buy at bid
// close sell at ask
double getPrice(int cmdOpenClose,int cmd,string symbol)
  {
   double price = -1;
   int dir_sign = direction_sign(cmd);
   double bid,ask;

   RefreshRates();
   int price_digits=(int) MarketInfo(symbol,MODE_DIGITS);
   bid = NormalizeDouble(MarketInfo(symbol, MODE_BID), price_digits);
   ask = NormalizeDouble(MarketInfo(symbol, MODE_ASK), price_digits);

   if(cmdOpenClose==CMD_OPEN)
     {
      if(dir_sign>0) // cmd==OP_BUY || cmd==OP_BUYLIMIT || cmd==OP_BUYSTOP
        {
         price=ask;
        }
      else if(dir_sign<0) // cmd==OP_SELL || cmd==OP_SELLLIMIT || cmd==OP_SELLSTOP
        {
         price=bid;
        }
     }
   else if(cmdOpenClose==CMD_CLOSE)
     {
      if(dir_sign>0)
        {
         price=bid;
        }
      else if(dir_sign<0)
        {
         price=ask;
        }
     }
   return(price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_pending_order(int cmd)
  {
   return(cmd>=2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_market_order(int cmd)
  {
   return(cmd<2); // 0:OP_BUY 1:OP_SELL
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int direction_sign(int order_type)
  {
   if(order_type==OP_BUY || order_type==OP_BUYLIMIT || order_type==OP_BUYSTOP)
     {
      return(1);
     }
   else if(order_type==OP_SELL || order_type==OP_SELLLIMIT || order_type==OP_SELLSTOP)
     {
      return(-1);
     }
   else
     {
      return(0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderTypeToString(int order_type)
  {
   if(order_type==OP_BUY)
     {
      return("__BUY___");
     }
   else if(order_type==OP_SELL)
     {
      return("__SELL__");
     }
   else if(order_type==OP_BUYLIMIT)
     {
      return("BUYLIMIT");
     }
   else if(order_type==OP_SELLLIMIT)
     {
      return("SELLLIMIT");
     }
   else if(order_type==OP_BUYSTOP)
     {
      return("BUYSTOP");
     }
   else if(order_type==OP_SELLSTOP)
     {
      return("SELLSTOP");
     }
   else
     {
      return("??ORDER?");
     }
  }
//+------------------------------------------------------------------+
