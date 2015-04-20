//+------------------------------------------------------------------+
//|                                           rabbit4mt4_logging.mqh |
//|                                                                  |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property strict

#include <rabbit4mt4.mqh>
#include <json_toolbox.mqh>

#define CRITICAL_LEVEL 4
#define ERROR_LEVEL	3
#define WARNING_LEVEL 2
#define INFO_LEVEL 1
#define DEBUG_LEVEL 0
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init_rabbitmq_logging()
  {
//int InitializeMQConnection(string hostName, string exchange, string bindingkey_root);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging(int msg_level,string message)
  {
//JSON_Dict json_message;
//json_message.Append("message",message);

//string s_json_message=json_message.Str();

   switch(msg_level)
     {
      case DEBUG_LEVEL : logging_debug(message);     break;
      case INFO_LEVEL : logging_info(message);    break;
      case WARNING_LEVEL : logging_warning(message);  break;
      case ERROR_LEVEL : logging_error(message);   break;
      case CRITICAL_LEVEL : logging_critical(message);   break;
      default: logging_critical(message);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_debug(string message,string logger="main")
  {
   Print("0D:"+message);
   SendMessageToMQ(g_terminal_id_setting+".events.logs."+logger+".debug",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_info(string message,string logger="main")
  {
   Print("1I:"+message);
   SendMessageToMQ(g_terminal_id_setting+".events.logs."+logger+".info",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_warning(string message,string logger="main")
  {
   Print("2W:"+message);
   SendMessageToMQ(g_terminal_id_setting+".events.logs."+logger+".warning",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_error(string message,string logger="main")
  {
   Print("3E:"+message);
   SendMessageToMQ(g_terminal_id_setting+".events.logs."+logger+".error",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_critical(string message,string logger="main")
  {
   Print("4C:"+message);
   SendMessageToMQ(g_terminal_id_setting+".events.logs."+logger+".critical",message);
  }

//+------------------------------------------------------------------+
