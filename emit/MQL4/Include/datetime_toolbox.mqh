//+------------------------------------------------------------------+
//|                                             datetime_toolbox.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"

long getCurrentUnixTimestampGMT_us() {
   //return((int) TimeGMT()); // s
   return((long) (TimeGMT()*1E6)); // us
}

int getUnixTimestamp(datetime dt) {
   return((int) dt); // s
}

long getUnixTimestamp_us(datetime dt) {
   return((long) (dt*1E6)); // us
}

datetime unixtimestamp_us_to_datetime(long unixtimestamp)
{
   return((datetime) (unixtimestamp/1E6)); // us
}