//+------------------------------------------------------------------+
//|                                                 json_toolbox.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"

#include <string_toolbox.mqh>

class JSON_List;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JSON_Dict
  {
private:
   int               m_size;          // size
   string            m_data;          // data
   string            m_sep_data;      // data separator (,)
   string            m_sep_kv;        // key/value separator (:)
public:
   //--- Default constructor
                     JSON_Dict(void);
   void              Append(string key,string value);
   void              Append(string key,int value);
   void              Append(string key,double value);
   void              Append(string key,double value,int digits);
   void              AppendNoDoubleQuotes(string key,string value);
   void              Append(string key,JSON_List  &value);
   void              Append(string key,JSON_Dict  &value);
   string            Str(void);
   int               Size(void);
   string            Empty(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
JSON_Dict::JSON_Dict(void)
  {
   m_size = 0;
   m_data = "";
   m_sep_data=",";
   m_sep_kv=":";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void JSON_Dict::Append(string key,string value)
  {
   AppendNoDoubleQuotes(key,doublequote(value));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_Dict::Append(string key,int value)
  {
   AppendNoDoubleQuotes(key,(string) value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_Dict::Append(string key,double value)
  {
   AppendNoDoubleQuotes(key,(string) value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_Dict::Append(string key,double value,int digits)
  {
   if(digits>0)
     {
      AppendNoDoubleQuotes(key, doublequote(DoubleToString(value,digits))); // decimal
     }
   else if(digits==0)
     {
      AppendNoDoubleQuotes(key, DoubleToString(value,0)); // integer
     }
   else if (digits<0)
     {
      AppendNoDoubleQuotes(key, DoubleToString(value/(MathPow(10, -digits)),0)); // integer
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_Dict::AppendNoDoubleQuotes(string key,string value)
  {
   string new_data_string=doublequote(key)+m_sep_kv+value;
   if(m_size==0)
     {
      m_data=new_data_string;
        } else {
      m_data=m_data+m_sep_data+new_data_string;
     }
   m_size++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_Dict::Append(string key,JSON_Dict &value)
  {
   AppendNoDoubleQuotes(key,value.Str());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_Dict::Append(string key,JSON_List &value)
  {
   AppendNoDoubleQuotes(key,value.Str());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_Dict::Str(void)
  {
   return("{" + m_data + "}");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int JSON_Dict::Size(void)
  {
   return(m_size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_Dict::Empty(void)
  {
   return("{}");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JSON_List
  {
private:
   int               m_size;          // size
   string            m_data;          // data
   string            m_sep_data;      // data separator (,)
public:
   //--- Default constructor
                     JSON_List(void);
   void              Append(string value);
   void              Append(int value);
   void              Append(double value);
   void              Append(double value,int digits);
   void              AppendNoDoubleQuotes(string value);
   void              Append(JSON_List  &value);
   void              Append(JSON_Dict  &value);
   string            Str(void);
   int               Size(void);
   string            Empty(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
JSON_List::JSON_List(void)
  {
   m_size = 0;
   m_data = "";
   m_sep_data=",";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_List::Append(string value)
  {
   AppendNoDoubleQuotes(doublequote(value));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_List::Append(int value)
  {
   AppendNoDoubleQuotes((string) value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_List::Append(double value)
  {
   AppendNoDoubleQuotes(doublequote((string) value));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_List::Append(double value,int digits)
  {
   if(digits>0)
     {
      AppendNoDoubleQuotes(doublequote(DoubleToString(value,digits))); // decimal
     }
   else if(digits==0)
     {
      AppendNoDoubleQuotes(DoubleToString(value,0)); // integer
     }
   else if (digits<0)
     {
      AppendNoDoubleQuotes(DoubleToString(value/(MathPow(10, -digits)),0)); // integer
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_List::AppendNoDoubleQuotes(string value)
  {
   if(m_size==0)
     {
      m_data=value;
        } else {
      m_data=m_data+m_sep_data+value;
     }
   m_size++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_List::Append(JSON_List &value)
  {
   AppendNoDoubleQuotes(value.Str());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JSON_List::Append(JSON_Dict &value)
  {
   AppendNoDoubleQuotes(value.Str());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_List::Str(void)
  {
   return("[" + m_data + "]");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int JSON_List::Size(void)
  {
   return(m_size);
  }
//+------------------------------------------------------------------+

string JSON_List::Empty(void)
  {
   return("[]");
  }
//+------------------------------------------------------------------+
