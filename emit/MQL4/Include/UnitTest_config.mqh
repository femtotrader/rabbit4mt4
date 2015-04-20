//+------------------------------------------------------------------+
//|                                              UnitTest_config.mqh |
//|             Licensed under GNU GENERAL PUBLIC LICENSE Version 3. |
//|                    See a LICENSE file for detail of the license. |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

input bool g_unit_testing=true; //Enable unit testing (This is must be false if release version)
input bool g_unit_testing_OnInit=true; //Run unit testing when OnInit events occurs
input bool g_unit_testing_OnLoop=false; //Run unit testing when loop occurs
input bool g_unit_testing_OnTick=false; //Run unit testing when OnTick events occurs
input bool g_alert_when_failed=true; //Alert message when assert failed
input int g_loop_ms=500; //Loop delay (ms)
