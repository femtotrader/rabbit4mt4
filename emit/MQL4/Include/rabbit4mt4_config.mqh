//+------------------------------------------------------------------+
//|                                            rabbit4mt4_config.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

extern string g_rabbitmq_host_name_setting = "localhost"; //RabbitMQ host name
extern string g_rabbitmq_exchange_setting = "topic_logs"; //RabbitMQ exchange name
extern string g_rabbitmq_username = "guest"; //RabbitMQ username
extern string g_rabbitmq_password = "guest"; //RabbitMQ password
extern string g_rabbitmq_virtualhost = "/"; //RabbitMQ virtualhost

//extern string g_rabbitmq_routingkey_root_setting = "mt4_demo01_123456"; //RabbitMQ bindingkey_root use password generator to give a unique name
// terminal_id_setting