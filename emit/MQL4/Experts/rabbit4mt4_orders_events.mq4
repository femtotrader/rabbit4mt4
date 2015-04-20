//+------------------------------------------------------------------+
//|                                     rabbit4mt4_orders_events.mq4 |
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
#include <rabbit4mt4_logging.mqh>

#include <display_price_volume.mqh>
#include <display_chart.mqh>

#include <json_toolbox.mqh>

#include <hash.mqh>

Hash *h_Type;
Hash *h_Volume;
Hash *h_Symbol;
Hash *h_SL;
Hash *h_TP;
Hash *h_price_open;
Hash *h_expiration;

//Hash *h_ticket_from;
//Hash *h_ticket_from_origin;

Hash *h_Volume_Still_Opened;

input int g_loop_delay_ms=2000; //loop delay (ms)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string datetime2string(datetime dt) // no timezone
  {
   string s_timestamp;
   if(dt!=0)
     {
      s_timestamp = TimeToStr(dt, TIME_DATE | TIME_SECONDS);
      s_timestamp = StringSetChar(s_timestamp, 4, '-');
      s_timestamp = StringSetChar(s_timestamp, 7, '-');
      //time = time + " " + g_timezone_setting;
        } else {
      s_timestamp="0000-00-00 00:00:00";
     }
   return (s_timestamp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void send_current_order_to_mq(string routingkey_tail)
  {
   string symbol=OrderSymbol();
   string message;
   int result;
   string routingkey;

   int digits_price=(int) MarketInfo(symbol,MODE_DIGITS);
   int digits_volume=VolumeDigits(symbol);
   int digits_default=8;

   JSON_Dict json_message;
   json_message.Append("ticket", IntegerToString(OrderTicket()));
   json_message.Append("order_type", OrderType());
   json_message.Append("volume", OrderLots(), digits_volume);
   json_message.Append("symbol", OrderSymbol());
   json_message.Append("open_time", datetime2string(OrderOpenTime()));
   json_message.Append("open_price", OrderOpenPrice(), digits_price);
   json_message.Append("stop_loss", OrderStopLoss(), digits_price);
   json_message.Append("take_profit", OrderTakeProfit(), digits_price);
   json_message.Append("magic_number", IntegerToString(OrderTicket()));
   json_message.Append("comment", OrderComment());
   json_message.Append("expiration", OrderExpiration());
   json_message.Append("commission", OrderCommission(), digits_default);
   json_message.Append("swap", OrderSwap(), digits_default);
   json_message.Append("profit", OrderProfit(), digits_default);
   message=json_message.Str();

   routingkey=StringFormat("%s.%s.%s.%s",g_terminal_id_setting,"events","orders",routingkey_tail);
   Print(StringFormat("Emit to '%s': '%s'",routingkey,message));
   result=SendMessageToMQ(routingkey,message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void store_current_order_to_memory(int ticket)
  {
   string s_ticket=IntegerToString(ticket);

   string symbol=OrderSymbol();
   int digits_price=(int) MarketInfo(symbol,MODE_DIGITS);
   int digits_volume=VolumeDigits(symbol);

   Print(StringFormat("SetOrderToMemory: ticket='%s' type='%s' symbol='%s' SL='%s' TP='%s' vol='%s' expiration='%s' openprice='%s'",
         s_ticket,IntegerToString(OrderType()),OrderSymbol(),DoubleToString(OrderStopLoss(),digits_price),
         DoubleToString(OrderTakeProfit(),digits_price),DoubleToString(OrderLots(),digits_volume),
         IntegerToString(OrderExpiration()),DoubleToString(OrderOpenPrice(),digits_price)));

   h_Type.hPutInt(s_ticket,OrderType());
   h_Volume.hPutDouble(s_ticket, OrderLots());
   h_Symbol.hPutString(s_ticket, OrderSymbol());
   h_SL.hPutDouble(s_ticket, OrderStopLoss());
   h_TP.hPutDouble(s_ticket, OrderTakeProfit());
   h_price_open.hPutDouble(s_ticket, OrderOpenPrice());
   h_expiration.hPutDatetime(s_ticket, OrderExpiration());

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void send_memory_order_to_mq(string s_ticket,string routingkey_tail)
  {
   string symbol=h_Symbol.hGetString(s_ticket);
   string message;
   int result;
   string routingkey;

   int digits_price=(int) MarketInfo(symbol,MODE_DIGITS);
   int digits_volume=VolumeDigits(symbol);
   int digits_default=8;

   JSON_Dict json_message;
   json_message.Append("ticket", s_ticket);
   json_message.Append("order_type", h_Type.hGetInt(s_ticket));
   json_message.Append("volume", h_Volume.hGetDouble(s_ticket), digits_volume);
   json_message.Append("symbol", symbol);
   message=json_message.Str();

   routingkey=StringFormat("%s.%s.%s.%s",g_terminal_id_setting,"events","orders",routingkey_tail);
   Print(StringFormat("Emit to '%s': '%s'",routingkey,message));
   result=SendMessageToMQ(routingkey,message);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void current_order_received()
  {
   send_current_order_to_mq("received");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void current_order_modified()
  {
   send_current_order_to_mq("modified");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void memory_order_deleted(string s_ticket)
  {
   send_memory_order_to_mq(s_ticket,"deleted");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void memory_order_closed(string s_ticket)
  {
   send_memory_order_to_mq(s_ticket,"closed");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void memory_order_partially_closed(string s_ticket)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitializeStillOpenedOrders()
  {
   h_Volume_Still_Opened=new Hash();

   int ticket;
   string s_ticket;
   double volume;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         ticket=OrderTicket();
         s_ticket=IntegerToString(ticket);
         volume=OrderLots();

         h_Volume_Still_Opened.hPutDouble(s_ticket,volume);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
// ToFix: partial close not supported
void current_order_partially_closed() {
    store_current_order_to_dict();
    send_current_order_to_mq("partially_closed");
}
*/

void current_order_closed()
  {
   send_current_order_to_mq("closed");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderExistsInMemory(string s_ticket)
  {
   return(h_Volume.hContainsKey(s_ticket));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetOrderStopLossFromMemory(string s_ticket)
  {
   return(h_SL.hGetDouble(s_ticket));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetOrderTakeProfitFromMemory(string s_ticket)
  {
   return(h_TP.hGetDouble(s_ticket));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetOrderVolumeFromMemory(string s_ticket)
  {
   return(h_Volume.hGetDouble(s_ticket));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetOrderExpirationFromMemory(string s_ticket)
  {
   return(h_expiration.hGetDatetime(s_ticket));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetOrderOpenPriceFromMemory(string s_ticket)
  {
   return(h_price_open.hGetDouble(s_ticket));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetOrderTypeFromMemory(string s_ticket)
  {
   return(h_Type.hGetInt(s_ticket));
  }
//+------------------------------------------------------------------+
//| Find closed trades                                               |
//+------------------------------------------------------------------+
void FindClosedTrades()
  {
   InitializeStillOpenedOrders();

   HashLoop *l;
   string s_ticket;
   double vol;

   int nb_orders_to_close_or_delete=0;
   string a_orders_to_close_or_delete[];

// Every orders (including orders that have been closed
// just a few seconds before)
   for(l=new HashLoop(h_Volume); l.hasNext(); l.next())
     {
      s_ticket=l.key();
      vol=l.valDouble();
      if(!h_Volume_Still_Opened.hContainsKey(s_ticket))
        {
         Print(StringFormat("Order '%s' should be closed (or deleted)",s_ticket));
         nb_orders_to_close_or_delete++;
         ArrayResize(a_orders_to_close_or_delete,nb_orders_to_close_or_delete);
         a_orders_to_close_or_delete[nb_orders_to_close_or_delete-1]=s_ticket;
        }
     }

   for(int i=0; i<nb_orders_to_close_or_delete; i++)
     {
      s_ticket=a_orders_to_close_or_delete[i];

      if(h_Type.hGetInt(s_ticket)<2)
        { // market order
         Print(StringFormat("Order '%s' will be closed",s_ticket));
         memory_order_closed(s_ticket);
           } else { // pending order
         Print(StringFormat("Pending order '%s' will be deleted",s_ticket));
         memory_order_deleted(s_ticket);
        }

      h_Volume.hDel(s_ticket);
      h_Type.hDel(s_ticket);
      h_Symbol.hDel(s_ticket);
      h_SL.hDel(s_ticket);
      h_TP.hDel(s_ticket);
      h_price_open.hDel(s_ticket);
      h_expiration.hDel(s_ticket);

     }

//

   delete l;
   delete h_Volume_Still_Opened;
  }
//+------------------------------------------------------------------+
//| Find new trades and modified orders                              |
//+------------------------------------------------------------------+
void FindNewTrades()
  {
   int ticket;
   string s_ticket;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         string symbol=OrderSymbol();
         int digits_price=(int) MarketInfo(symbol,MODE_DIGITS);
         int digits_volume=VolumeDigits(symbol);

         ticket=OrderTicket();
         s_ticket=IntegerToString(ticket);

         if(!OrderExistsInMemory(s_ticket))
           { // test if this order was ever sent to RabbitMQ queue, if not
            string comment=OrderComment();
            string comment_from_pattern="from #";
            int comment_char_id= StringFind(comment,comment_from_pattern);
            if(comment_char_id>=0)
              {
               string s_ticket_from=StringSubstr(comment,comment_char_id+StringLen(comment_from_pattern),0);
               Print(StringFormat("Partial close - ToFix - '%s' from '%s'",s_ticket,s_ticket_from));
               store_current_order_to_memory(ticket);
               memory_order_closed(s_ticket_from); // ToFix : when a partial closed occurs the ticket_from is fully closed
                 } else {
               Print(StringFormat("Order '%s' doesn't exists in memory - storing and sending to MQ",s_ticket));
               store_current_order_to_memory(ticket); // we store in a dictionnary (with ticket number as key)
               current_order_received(); // and we send this order to Rabbit
              }
              } else {
            bool b_order_modified=false;
            bool b_order_partially_closed=false;
            bool b_order_closed=false;

            double SL_old,SL_new;

            SL_old = GetOrderStopLossFromMemory(s_ticket);
            SL_new = OrderStopLoss();
            if(SL_new!=SL_old)
              {
               Print(StringFormat("Order '%s' modified - SL changed from '%s' to '%s'",IntegerToString(ticket),DoubleToString(SL_old,digits_price),DoubleToString(SL_new,digits_price)));
               b_order_modified=true;
              }

            double TP_old,TP_new;

            TP_old = GetOrderTakeProfitFromMemory(s_ticket);
            TP_new = OrderTakeProfit();
            if(TP_new!=TP_old)
              {
               Print(StringFormat("Order '%s' modified - TP changed from '%s' to '%s'",IntegerToString(ticket),DoubleToString(TP_old,digits_price),DoubleToString(TP_new,digits_price)));
               b_order_modified=true;
              }

/*
                     double vol_old, vol_new;
                     vol_old = GetOrderVolumeFromMemory(s_ticket);
                     vol_new = DoubleToString(OrderLots(), digits_volume);
                     if ( vol_new != vol_old ) {
                        Print(StringFormat("Order '%s' modified - volume changed from '%s' to '%s'", IntegerToString(ticket), DoubleToString(vol_old, digits_volume), DoubleToString(vol_new, digits_volume)));
                        //b_order_modified = true;
                        b_order_partially_closed = true;
                     }
                     */

            int typ_old,typ_new;
            typ_old = GetOrderTypeFromMemory(s_ticket);
            typ_new = OrderType();
            if(TP_new!=TP_old)
              {
               Print(StringFormat("Pending order '%s' is now executed (changing OrderType in memory)",s_ticket));
               h_Type.hPutInt(s_ticket,typ_new);
               //b_order_modified=true;
              }

            if(OrderType()>1)
              { // pending orders
               datetime expiration_old,expiration_new;
               expiration_old = GetOrderExpirationFromMemory(s_ticket);
               expiration_new = OrderExpiration();
               if(expiration_new!=expiration_old)
                 {
                  Print(StringFormat("Pending order '%s' modified - Expiration changed from '%s' to '%s'",IntegerToString(ticket),expiration_old,expiration_new));
                  b_order_modified=true;
                 }

               double price_open_new,price_open_old;
               price_open_old = GetOrderOpenPriceFromMemory(s_ticket);
               price_open_new = OrderOpenPrice();
               if(price_open_new!=price_open_old)
                 {
                  Print(StringFormat("Pending order '%s' modified - price open changed from '%s' to '%s'",IntegerToString(ticket),price_open_old,price_open_new));
                  b_order_modified=true;
                 }

              }

/*
                     if (b_order_partially_closed) {
                        Print("order partially closed");
                        current_order_partially_closed();
                     }
                     */

            if(b_order_modified)
              {
               //Print(StringFormat("Order '%s' modified", IntegerToString(ticket)));
               current_order_modified();
               store_current_order_to_memory(ticket);
              }

            if(b_order_closed)
              {
               //Print(StringFormat("Order '%s' closed", IntegerToString(ticket)));
               current_order_closed();
              }

            //Print(StringFormat("Pending order '%s' deleted", IntegerToString(ticket)));

           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Store orders to memory (HashMap) that are even opened            |
//| (to avoid to send them again to RabbitMQ at EA startup)          |
//+------------------------------------------------------------------+
void StoreOrdersToMemory()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         store_current_order_to_memory(OrderTicket());
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   h_Type=new Hash();
   h_Symbol= new Hash();
   h_Volume=new Hash();
   h_SL = new Hash();
   h_TP = new Hash();
   h_price_open = new Hash();
   h_expiration = new Hash();

   ObjectsDeletePrefixed("about_");
   About_Display_TerminalID(g_terminal_id_setting);

   int result;
   result=InitializeMQConnection(g_rabbitmq_host_name_setting,g_rabbitmq_username,g_rabbitmq_password,g_rabbitmq_virtualhost,g_rabbitmq_exchange_setting,g_terminal_id_setting);
   if(result!=0)
     {
      string msg;
      msg="Can't initialize RabbitMQ connection";
      Print(msg); // we must keep this Print (because if we don't have RabbitMQ we need to Print error somewhere)
      logging_critical(msg);
      return(INIT_FAILED); // bad connect
     }

   logging_info(StringFormat("Running '%s'",__FUNCTION__));

   logging_debug("RabbitMQ connection initialized");

   datetime prev_time=TimeLocal();

   StoreOrdersToMemory();

   while(true)
     {
      if((TimeLocal()-prev_time)>=1) //Do stuff once per second
        {
         prev_time=TimeLocal();

         FindClosedTrades();
         FindNewTrades();

         //Print("in the loop");
        }

      Sleep(g_loop_delay_ms); // 500
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
   int result;
   result=CloseMQConnection();

   delete h_Volume;
   delete h_SL;
   delete h_TP;
   delete h_price_open;
   delete h_expiration;

   delete h_Volume_Still_Opened;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
