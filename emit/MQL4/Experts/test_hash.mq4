//+------------------------------------------------------------------+
//|                                                    test_hash.mq4 |
//|             Licensed under GNU GENERAL PUBLIC LICENSE Version 3. |
//|                    See a LICENSE file for detail of the license. |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict


#include <UnitTest.mqh>
#include <UnitTest_config.mqh>
#include <hash.mqh>
#define HASH_TEST_SIZE 1000
//--- The derived class MyUnitTest
class MyUnitTest : public UnitTest        // After a colon we define the base class
  {                                       // from which inheritance is made
public:
   void runAllTests()
     {
      initUnitTest();

      initTestCase(); test_01_hash_int(); endTestCase();
      initTestCase(); test_02_hash_collisions(); endTestCase();

      endUnitTest();
     };

private:
   void initTestCase()
     {
      Print(StringConcatenate(UT_SPACE_TESTCASE,"initTestCase before every test"));
     }

   void test_01_hash_int()
     {
      unittest.addTest(__FUNCTION__);

      Hash *h=new Hash();

      // Store values
      h.hPutInt("low",0);
      h.hPutInt("high",1);

      // Get values
      int low,high;
      low=h.hGetInt("low");
      high=h.hGetInt("high");

      unittest.assertEquals(low, 0);
      unittest.assertEquals(high, 1);

      // Loop
      HashLoop *l;
      for(l=new HashLoop(h); l.hasNext(); l.next())
        {
         string key=l.key();
         int val=l.valInt();
         Print(key," = ",val);
         unittest.assertEquals(h.hGetInt(key), val);
        }
      delete h;
     }

   void test_02_hash_collisions() 
     {
      unittest.addTest(__FUNCTION__);

      // Force hash collisions using a small hash size.
      Hash *h=new Hash(5,true);

      int count=0;
      HashLoop *l;
      string key;

      for(int i=0; i<HASH_TEST_SIZE; i++) 
        {
         key = (string) i;
         h.hPutInt(key,i);
        }
      // Read and verify
      for(int i=0; i<HASH_TEST_SIZE; i++) 
        {
         key = (string) i;
         int j = h.hGetInt(key);
         unittest.assertEquals(i, j, "i should equal j");
        }
      count=0;

      int a[HASH_TEST_SIZE];

      ArrayInitialize(a,0);
      // Test the loop
      for(l=new HashLoop(h); l.hasNext(); l.next()) 
        {
         count++;

         //Check loop key values match
         int i = (int)StringToInteger(l.key());
         int j = l.valInt();
         unittest.assertEquals(i, j, "Hash fail2");

         // Check occurences
         a[i]++;
         unittest.assertEquals(a[i], 1, "Hash fail3");
        }
      delete l;

      // Check total
      unittest.assertEquals(count, HASH_TEST_SIZE, "Hash fail4");

      // Check distribution
      for(int i=0; i<HASH_TEST_SIZE; i++) 
        {
         h.hPutInt("XXXXXXXXXXX"+(string)i+"YYYYYYYYYYYY",i);
        }

      delete h;
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
