//+------------------------------------------------------------------+
//|                                               string_toolbox.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Enclose string with simple quote (')                             |
//+------------------------------------------------------------------+
string quote(string s)
  {
   return("'" + s + "'");
  }
//+------------------------------------------------------------------+
//| Enclose string with doublequote (")                              |
//+------------------------------------------------------------------+
string doublequote(string s)
  {
   return("\"" + s + "\"");
  }
//+------------------------------------------------------------------+
//| Enclose string with backquote (`)                                |
//| "backquote" are also called "backtick"                           |
//+------------------------------------------------------------------+
string backquote(string s)
  {
   return("`" + s + "`");
  }
//+------------------------------------------------------------------+
//| Trim a string left and right                                     |
//+------------------------------------------------------------------+
string StringTrim(string str)
  {
   str = StringTrimLeft(str);
   str = StringTrimRight(str);

   return (str);
  }
//+------------------------------------------------------------------+
//| Unescape string                                                  |
//+------------------------------------------------------------------+
string string_unescape(string s)
  {
   StringReplace(s,"_ESC1_","'");
   StringReplace(s,"_ESC2_","\"");
   return(s);
  }
//+------------------------------------------------------------------+
//| Escape string                                                    |
//+------------------------------------------------------------------+
string string_escape(string s)
  {
   StringReplace(s,"'","_ESC1_");
   StringReplace(s,"\"","_ESC2_");
   return(s);
  }
//+------------------------------------------------------------------+
