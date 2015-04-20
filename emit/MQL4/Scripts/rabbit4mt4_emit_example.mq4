//+------------------------------------------------------------------+
//|                                      rabbit4mt4_emit_example.mq4 |
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

#include <json_toolbox.mqh>
#include <display_price_volume.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
  {
//---
   int result;
   result=InitializeMQConnection(g_rabbitmq_host_name_setting,g_rabbitmq_username,g_rabbitmq_password,g_rabbitmq_virtualhost,g_rabbitmq_exchange_setting,g_terminal_id_setting);
   if(result!=0)
     {
      string msg;
      msg="Can't initialize RabbitMQ connection";
      Print(msg);
      return(INIT_FAILED); // bad connect
     }
     
   // Send "Hello world!" to queue nammed "queue"
   string msg;
   string queue;
   msg="Hello world!";
   queue="hello";
   Print(StringFormat("Send '%s' to queue '%s'",msg,queue));
   SendMessageToQueue("hello",msg);
      
   // Send ticks to mt4_demo01_123456.event.ticks.eurusd exchange
   int digits = Digits();
   string symbol = Symbol();
   double pippoint = PipPoint(symbol);
   double bid = Bid;
   double ask = Ask;
   Print(StringFormat("Emit tick: '%s' bid/ask '%s'/'%s'", symbol, DoubleToString(bid, digits), DoubleToString(ask, digits)));
   result = SendTickToMQ(symbol, bid, ask);
   
   // Send a JSON text message to mt4_demo01_123456.event.message
   string message;
   string routingkey;
   message = "{\"message\": \"Hello RabbitMQ\"}"; // use JSON message
   routingkey = StringFormat("%s.%s.%s", g_terminal_id_setting, "events", "messages");
   Print(StringFormat("Emit message: '%s' to '%s'", message, routingkey));
   result = SendMessageToMQ(routingkey, message);
   
   // Send bid, ask, spread (pips) and MA
   double ma = iMA(NULL,0,13,8,MODE_SMMA,PRICE_MEDIAN,0);
   /*
   // raw message generation
   message = StringFormat("{\"bid\": \"%s\", \"ask\": \"%s\", \"spread_pips\": \"%s\", \"ma_13_8\": \"%s\"}",
      DoubleToString(bid, digits),
      DoubleToString(ask, digits),
      DoubleToString((ask-bid)/pippoint, 1),
      DoubleToString(ma, digits)
   );
   */
   JSON_Dict json_message; // using json_toolbox.mqh
   json_message.Append("bid", bid, digits);
   json_message.Append("ask", ask, digits);
   json_message.Append("spread_pips", (ask-bid)/pippoint, 1);
   json_message.Append("ma", ma, digits);
   message = json_message.Str();
   routingkey = StringFormat("%s.%s.%s", g_terminal_id_setting, "events", "messages");
   Print(StringFormat("Emit message: '%s' to '%s'", message, routingkey));
   result = SendMessageToMQ(routingkey, message);
   


    result = CloseMQConnection();
    
    return(0);

  }
//+------------------------------------------------------------------+
