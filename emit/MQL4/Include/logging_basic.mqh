//+------------------------------------------------------------------+
//|                                                logging_basic.mqh |
//|                                                                  |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property strict

const int CRITICAL_LEVEL = 4;
const int ERROR_LEVEL	= 3;
const int WARNING_LEVEL = 2;
const int INFO_LEVEL = 1;
const int DEBUG_LEVEL	= 0;

void logging(int msg_level, string message) {
    if (msg_level >= g_logging_level_setting) {
        Print(message);
    }
}

void logging_debug(string message)
  {
   Print("  "+message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_info(string message)
  {
   Print("i "+message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_warning(string message)
  {
   Print("w "+message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_error(string message)
  {
   Print("E "+message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void logging_critical(string message)
  {
   Print("CR"+message);
  }