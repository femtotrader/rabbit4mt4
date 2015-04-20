//+------------------------------------------------------------------+
//|                                           mql4-mysql_toolbox.mq4 |
//|                                                                  |
//|                                                     Sergey Lukin |
//|                                          contact@sergeylukin.com |
//|                                                                  |
//|                                           Toolbox by FemtoTrader |
//|                                           femto.trader@gmail.com |
//+------------------------------------------------------------------+
#property copyright "FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"

#include <mql4-mysql.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_db_timestamp(datetime dt) // no timezone
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
string timezone_to_string(int timezone)
  {
   string sTimezone;

   sTimezone=IntegerToString(MathAbs(timezone));

   while(StringLen(sTimezone)<2)
      sTimezone=("0"+sTimezone);

   if(timezone>=0)
     {
      sTimezone="+"+sTimezone;
        } else {
      sTimezone="-"+sTimezone;
     }
   return(sTimezone);
  }
//+------------------------------------------------------------------+

void disconnect_db(int db_connect_id) {
   deinit_MySQL(db_connect_id);
}

/*
bool reconnect(int db_connect_id)
{
    disconnect_db(db_connect_id);
    return (connect_db(db_connect_id));
}
*/