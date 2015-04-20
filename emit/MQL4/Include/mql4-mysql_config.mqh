//+------------------------------------------------------------------+
//|                                            mql4-mysql_config.mq4 |
//|                                                                  |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"

extern string  g_db_host_setting     = "localhost"; //DB hostname ('localhost' or '127.0.0.1')
extern string  g_db_user_setting     = "root"; //DB user ('root')
extern string  g_db_pass_setting     = "123456"; //DB password ('123456')
extern string  g_db_name_setting   = "test"; //DB name

extern int     g_db_port_setting     = 3306; //DB port
extern int     g_db_socket_setting   = 0; //DB socket
extern int     g_db_client_setting   = 0; //DB client
