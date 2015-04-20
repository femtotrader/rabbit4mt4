//+------------------------------------------------------------------+
//|                                      rabbit4mt5_emit_example.mq4 |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

#include <rabbit4mt5.mqh>
#include <rabbit4mt5_config.mqh>

double PipPoint(string symbol) {
    int digits = (int) SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    double pippoint = 0.0;

    if (digits == 2 || digits == 3) {
        pippoint = 0.01;
    } else if (digits == 4 || digits == 5) {
        pippoint = 0.0001;
    } else if (digits == 0 || digits == 1) {
        pippoint = 1.0;
    } else {
        //Comment("Error PipPoint function");
        Print("Error PipPoint function");
    }
    return(pippoint);
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int result;
   result = InitializeMQConnection(g_rabbitmq_host_name_setting, g_rabbitmq_exchange_setting, g_rabbitmq_routingkey_root_setting);
   
   // Send ticks to mt4_demo01_123456.event.ticks.eurusd
   int digits = Digits();
   string symbol = Symbol();
   double pippoint = PipPoint(symbol);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   Print(StringFormat("Emit tick: '%s' bid/ask '%s'/'%s'", symbol, DoubleToString(bid, digits), DoubleToString(ask, digits)));
   result = SendTickToMQ(symbol, bid, ask);
   
   // Send a JSON text message to mt4_demo01_123456.event.message
   string message;
   string routingkey;
   message = "{\"message\": \"Hello RabbitMQ\"}"; // use JSON message
   routingkey = StringFormat("%s.%s.%s", g_rabbitmq_routingkey_root_setting, "events", "messages");
   Print(StringFormat("Emit message: '%s' to '%s'", message, routingkey));
   result = SendMessageToMQ(routingkey, message);
   
   // Send bid, ask, spread (pips)
   // ToDo: add value of a technical indicator
   message = StringFormat("{\"bid\": \"%s\", \"ask\": \"%s\", \"spread_pips\": \"%s\"}",
      DoubleToString(bid, digits),
      DoubleToString(ask, digits),
      DoubleToString((ask-bid)/pippoint, 1)
   );
   routingkey = StringFormat("%s.%s.%s", g_rabbitmq_routingkey_root_setting, "events", "messages");
   Print(StringFormat("Emit message: '%s' to '%s'", message, routingkey));
   result = SendMessageToMQ(routingkey, message);
   


    result = CloseMQConnection();

  }
//+------------------------------------------------------------------+
