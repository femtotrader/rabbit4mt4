//+------------------------------------------------------------------+
//|                                       rabbit4mt4_execute_rpc.mq4 |
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

#include <rabbit4mt4.mqh>
#include <rabbit4mt4_config.mqh>
#include <rabbit4mt4_logging.mqh>

#include <mql4-mysql.mqh>
#include <mql4-mysql_config.mqh>
#include <mql4-mysql_toolbox.mqh>

#include <json_rpc_mysql.mqh> // retrieve JSON RPC from DB

#include <display_chart.mqh>

extern string  g_table_prefix_setting=""; //table prefix
extern int g_sleep_ms=1000; //sleep (ms)

extern int g_slippage_default=3; //default slippage

int     g_db_connect_id=0;

string g_table_name_rpc;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
// Don't put any logging functions before initializing RabbitMQ connection

   IDN();

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

   bool b_result;
   b_result=init_MySQL(g_db_connect_id,g_db_host_setting,g_db_user_setting,g_db_pass_setting,g_db_name_setting,g_db_port_setting,g_db_socket_setting,g_db_client_setting);
   if(!b_result)
     {
      logging_critical("Can't connect to MySQL database");
      return(INIT_FAILED); // bad connect
     }

   logging_debug("MySQL connection initialized");

   init_table_names(g_table_prefix_setting);

// remove JSON RPC from DB at startup
// to avoid to execute very old RPC
   logging_debug("remove JSON RPC from DB");
   remove_json_rpc_from_db(g_db_connect_id,g_terminal_id_setting);

   datetime prev_time=TimeLocal();

   while(true)
     {
      if((TimeLocal()-prev_time)>=1) //Do stuff once per second
        {
         prev_time=TimeLocal();

         get_json_rpc_from_db(g_db_connect_id,g_terminal_id_setting);

        }

      Sleep(g_sleep_ms);
     }
   disconnect_db(g_db_connect_id);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   disconnect_db(g_db_connect_id);

   int result;
   result=CloseMQConnection();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
