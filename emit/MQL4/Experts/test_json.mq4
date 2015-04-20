//+------------------------------------------------------------------+
//|                                                    test_json.mq4 |
//|             Licensed under GNU GENERAL PUBLIC LICENSE Version 3. |
//|                    See a LICENSE file for detail of the license. |
//|                                    Copyright © 2014, FemtoTrader |
//|                        Using mt4-unittest framework available at |
//|                     https://github.com/femtotrader/mt4-unittest/ |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict


#include <UnitTest.mqh>
#include <UnitTest_config.mqh>
#include <json.mqh>
//--- The derived class MyUnitTest
class MyUnitTest : public UnitTest        // After a colon we define the base class
  {                                       // from which inheritance is made
public:
   void runAllTests()
     {
      initUnitTest();

      initTestCase(); test_01_json(); endTestCase();
      initTestCase(); test_02_json_rpc(); endTestCase();

      endUnitTest();
     };

private:
   void initTestCase()
     {
      Print(StringConcatenate(UT_SPACE_TESTCASE,"initTestCase before every test"));
     }

   void test_01_json()
     {
      unittest.addTest(__FUNCTION__);

      string s="{ \"firstName\": \"John\", \"lastName\": \"Smith\", \"age\": 25, \"size\": 1.78, \"address\": { \"streetAddress\": \"21 2nd Street\", \"city\": \"New York\", \"state\": \"NY\", \"postalCode\": \"10021\" }, \"phoneNumber\": [ { \"type\": \"home\", \"number\": \"212 555-1234\" }, { \"type\": \"fax\", \"number\": \"646 555-4567\" } ], \"gender\":{ \"type\":\"male\" }  }";
      JSONParser *parser=new JSONParser();
      JSONValue *jv=parser.parse(s);
      Print("json:");
      if(jv==NULL)
        {
         Print("error:"+(string)parser.getErrorCode()+parser.getErrorMessage());
           } else {
         Print("PARSED:"+jv.toString());
         if(jv.isObject())
           {
            JSONObject *jo=jv;

            // Direct access - will throw null pointer if wrong getter used.
            unittest.assertEquals(jo.getString("firstName"), "John");
            unittest.assertEquals(jo.getObject("address").getString("city"), "New York");
            unittest.assertEquals(jo.getArray("phoneNumber").getObject(0).getString("number"), "212 555-1234");
            unittest.assertEquals(jo.getInt("age"), 25);

            JSONValue*jsv;
            jsv=jo.getValue("age");
            //unittest.assertFalse(jsv.isNull()); // there is a bug here
            //unittest.assertTrue(jsv.isNumber()); // there is a bug here
            int age=0;
/*
            if (jo.getInt("age",age) ) { // there is a bug here
               unittest.assertEquals(age, 25);
            } else {
               unittest.assertTrue(false, "Can't access age as int"); // there is a bug here       
            }
            */

            unittest.assertEquals(jo.getDouble("size"),1.78);

            // Safe access in case JSON data is missing or different.
            if(jo.getString("firstName",s))
              {
               unittest.assertEquals(s,"John");
              }

            // Loop over object returning JSONValue
            JSONIterator *it=new JSONIterator(jo);
            for(; it.hasNext(); it.next())
              {
               Print("loop:"+it.key()+" = "+it.val().toString());
              }
            delete it;
           }
         delete jv;
        }
      delete parser;
     }

   void test_02_json_rpc()
     {
      unittest.addTest(__FUNCTION__);

      string s;
      double x=0.0;
      int i=0;

      //s="{\"jsonrpc\" : \"2.0\",\"params\" : [\"Hello World!\"],\"method\" : \"Comment\",\"id\" : 12340}";
      s="{\"jsonrpc\" : \"2.0\",\"params\" : [\"3\", 4, 5.1],\"method\" : \"add\",\"id\" : 12340}";
      //s="{\"jsonrpc\" : \"2.0\",\"params\" : [\"3\", \"4\", 5.1],\"method\" : \"add\",\"id\" : 12340}";
      JSONParser *parser=new JSONParser();
      JSONValue *jv=parser.parse(s);

      JSONObject *jo=jv;

      JSONValue*jsv;
      jsv=jo.getValue("jsonrpc");
      unittest.assertTrue(jsv.isString());
      unittest.assertEquals(jo.getString("jsonrpc"), "2.0");

      jsv=jo.getValue("params");
      unittest.assertTrue(jsv.isArray());

      JSONValue*jsv_param;
      jsv_param=jo.getArray("params").getValue(0);
      unittest.assertTrue(jsv_param.isString());
      unittest.assertFalse(jsv_param.isNull());
      unittest.assertFalse(jsv_param.isNumber());


      jsv_param=jo.getArray("params").getValue(1);
      unittest.assertEquals(jsv_param.getInt(),4);
      unittest.assertEquals(jsv_param.getDouble(),4.0);
      unittest.assertFalse(jsv_param.isString());
      //unittest.assertTrue(jsv_param.isNumber()); // there is a bug here
      //unittest.assertFalse(jsv_param.isNull()); // there is a bug here

      jsv_param=jo.getArray("params").getValue(2);
      //unittest.assertTrue(jsv_param.isNumber()); // there is a bug here
      unittest.assertEquals(jsv_param.getDouble(),5.1);

      //unittest.assertEquals(jo.getArray("params").getDouble(2), 5.1);
      //unittest.assertFalse(jsv_param.isNull()); // there is a bug here

      //s="{\"jsonrpc\" : \"2.0\",\"params\" : [1],\"method\" : \"method\",\"id\" : 12340}"; // ok
      s="{\"jsonrpc\" : \"2.0\",\"params\" : [],\"method\" : \"method\",\"id\" : 12340}"; // valid JSON but MQL JSON parser fails
      jv=parser.parse(s);
      Print("parser.getErrorCode()= ",parser.getErrorCode());
      Print("parser.getErrorMessage()= ",parser.getErrorMessage());
      unittest.assertFalse(jv==NULL,parser.getErrorMessage());

      delete jv;
      delete jo;
      delete parser;
     }

  };

MyUnitTest *unittest;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   UT_OnInit();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   UT_OnDeinit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   UT_OnTick();
  }
//+------------------------------------------------------------------+
