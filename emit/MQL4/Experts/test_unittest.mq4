//+------------------------------------------------------------------+
//|                                    test_unittest_femto_class.mq4 |
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

//--- The derived class MyUnitTest
class MyUnitTest : public UnitTest        // After a colon we define the base class
  {                                       // from which inheritance is made
public:
   void runAllTests()
     {
      initUnitTest();

      initTestCase(); test_01_bool_assertTrue_succeed(); endTestCase();
      initTestCase(); test_02_bool_assertFalse_succeed(); endTestCase();
      initTestCase(); test_03_integers_int_assertEquals_succeed();  endTestCase();
      initTestCase(); test_04_integers_long_assertEquals_succeed();  endTestCase();
      initTestCase(); test_05_float_assertEquals_succeed();  endTestCase();
      initTestCase(); testGetMA_shoudReturnSMA(); endTestCase();
      initTestCase(); testGetMAArray_shoudReturnCoupleOfSMA(); endTestCase();

      endUnitTest();
     };

private:
   void initTestCase()
     {
      Print(StringConcatenate(UT_SPACE_TESTCASE,"initTestCase before every test"));
     }

   void test_01_bool_assertTrue_succeed()
     {
      unittest.addTest(__FUNCTION__);
      unittest.assertTrue(true,"assertTrue should succeed");
      //unittest.assertTrue(false,"assertTrue should fail"); // comment this line to pass unit test
      unittest.assertTrue(true,"assertTrue should succeed");
     }

   void test_02_bool_assertFalse_succeed()
     {
      unittest.addTest(__FUNCTION__);
      unittest.assertFalse(false,"assertFalse should succeed");
      //unittest.assertFalse(true,"assertFalse should fail"); // comment this line to pass unit test
     }

   void test_03_integers_int_assertEquals_succeed()
     {
      unittest.addTest(__FUNCTION__);
      int actual,expected;
      expected=42;
      actual=42;
      unittest.assertEquals(actual,expected,"assertEquals with 2 integers should succeed");
      actual=43;
      //unittest.assertEquals(actual,expected,"assertEquals with 2 integers should fail"); // comment this line to pass unit test
     }

   void test_04_integers_long_assertEquals_succeed()
     {
      unittest.addTest(__FUNCTION__);
      long actual,expected;
      expected=42;
      actual=42;
      unittest.assertEquals(expected,actual,"assertEquals with 2 integers should succeed");
      //unittest.assertEquals(actual,expected,"assertEquals with 2 integers should succeed");
      actual=43;
      //unittest.assertEquals(actual,expected,"assertEquals with 2 integers should fail"); // comment this line to pass unit test
     }

   void test_05_float_assertEquals_succeed()
     {
      unittest.addTest(__FUNCTION__);
      float actual,expected;
      expected=42.0;
      actual=42.0;
      unittest.assertEquals(actual,expected,"assertEquals with 2 floats should succeed");
      actual=43.0;
      //unittest.assertEquals(actual,expected,"assertEquals with 2 floats should fail"); // comment this line to pass unit test
     }

   void test_06_string_assertEquals_succeed()
     {
      unittest.addTest(__FUNCTION__);
      string actual,expected;
      expected="abc";
      actual="abc";
      unittest.assertEquals(actual,expected,"assertEquals with 2 integers should succeed");
      actual="abA";
      //unittest.assertEquals(actual,expected,"assertEquals with 2 integers should fail"); // comment this line to pass unit test
     }

   void testGetMA_shoudReturnSMA()
     {
      unittest.addTest(__FUNCTION__);

      const double actual=getMA(3);
      const double expected=iMA(NULL,0,paramMAPeriod,0,MODE_SMA,PRICE_CLOSE,3);

      unittest.assertEquals(actual,expected,"MA must be SMA and 3 bars shifted");
      //unittest.assertTrue(false,"assertTrue should fail"); // comment this line to pass unit test
     }

   void testGetMAArray_shoudReturnCoupleOfSMA()
     {
      unittest.addTest(__FUNCTION__);

      const int shifts[]={4,5};
      double actual[2];
      getMAArray(shifts,actual);

      double expected[2];
      expected[0] = iMA(NULL, 0, paramMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 4);
      expected[1] = iMA(NULL, 0, paramMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 5);

      unittest.assertEquals(actual,expected,"MA array must contains a couple of SMA");
      //unittest.assertTrue(false,"assertTrue should fail"); // comment this line to pass unit test
     }
  };

MyUnitTest *unittest;

input int paramMAPeriod=13;


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
//|                                                                  |
//+------------------------------------------------------------------+
double getMA(int shift)
  {
   return (iMA(NULL, 0, paramMAPeriod, 0, MODE_SMA, PRICE_CLOSE, shift));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getMAArray(const int &shifts[],double &mas[])
  {
   for(int i=0; i<ArraySize(shifts); i++)
     {
      mas[i]=getMA(shifts[i]);
     }
  }

//+------------------------------------------------------------------+
