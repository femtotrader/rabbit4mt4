//+------------------------------------------------------------------+
//|                                               string_toolbox.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string doublequote(string s)
  {
   return("\"" + s + "\"");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringTrim(string str)
  {
   str = (string) StringTrimLeft(str);
   str = (string) StringTrimRight(str);

   return (str);
  }
//+------------------------------------------------------------------+
