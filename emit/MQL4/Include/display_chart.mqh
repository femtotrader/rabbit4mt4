//+------------------------------------------------------------------+
//|                                                display_chart.mq4 |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

int      About_Corner=3;
int      About_X = 20;
int      About_Y = 15;
int      About_dY= 16;
string   About_FontName = "Verdana";
int      About_FontSize = 9;
color    About_FontColor= Silver;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectsDeletePrefixed(string sPrefix)
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),sPrefix)==0) ObjectDelete(ObjectName(i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void About_TextOut(string comment,int j)
  {
   string obj_name="about_"+IntegerToString(j);
   if(ObjectFind(obj_name)==-1)
     {
      ObjectCreate(obj_name,OBJ_LABEL,0,0,0);
     }

   ObjectSet(obj_name,OBJPROP_XDISTANCE,About_X);
   ObjectSet(obj_name,OBJPROP_YDISTANCE,About_Y+j*About_dY);
   ObjectSet(obj_name,OBJPROP_CORNER,About_Corner);

   ObjectSetText(obj_name,comment,About_FontSize,About_FontName,About_FontColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void About_Display_TerminalID(string terminal_id)
  {
   string msg;
   string spr="--------------------------------------";
   msg="https://sites.google.com/site/femtotrader/";
   About_TextOut(msg,0);
   msg="© 2014 FemtoTrader";
   About_TextOut(msg,1);
   About_TextOut(spr,2);
   msg=StringConcatenate("Terminal ID: ",terminal_id);
   About_TextOut(msg,3);
  }
//+------------------------------------------------------------------+
