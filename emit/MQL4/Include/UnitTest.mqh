//+------------------------------------------------------------------+
//|                                                     UnitTest.mqh |
//|             Licensed under GNU GENERAL PUBLIC LICENSE Version 3. |
//|                    See a LICENSE file for detail of the license. |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict

#define UT_SPACE_TESTCASE "  "
#define UT_SPACE_ASSERT "    "
#define UT_SEP " - "
#define UT_COMP_EXP_ACT "%s: expected is <%s> but <%s>"
#define UT_COMP_ARR_EXP_ACT "%s: expected array[%d] is <%s> but <%s>"
#define UT_DEFAULT_ASSERT_MESSAGE "assert should succeed"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
Inspired from https://github.com/micclly/mt4-unittest
*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class UnitTest
  {
public:
                     UnitTest();
                    ~UnitTest();

   void              addTest(string test_name);
   void              printSummary();

   void              initUnitTest(void);
   void              endUnitTest(void);

   void              initTestCase(void);
   void              endTestCase(void);

   void              assertTrue(bool actual,string message);
   void              assertFalse(bool actual,string message);

   void              assertEquals(bool actual,bool expected,string message);
   void              assertEquals(char actual,char expected,string message);
   void              assertEquals(uchar actual,uchar expected,string message);
   void              assertEquals(short actual,short expected,string message);
   void              assertEquals(ushort actual,ushort expected,string message);
   void              assertEquals(int actual,int expected,string message);
   void              assertEquals(uint actual,uint expected,string message);
   void              assertEquals(long actual,long expected,string message);
   void              assertEquals(ulong actual,ulong expected,string message);
   void              assertEquals(datetime actual,datetime expected,string message);
   void              assertEquals(color actual,color expected,string message);
   void              assertEquals(float actual,float expected,string message);
   void              assertEquals(double actual,double expected,string message);
   void              assertEquals(string actual,string expected,string message);

   void              assertEquals(const bool &expected[],const bool &actual[],string message);
   void              assertEquals(const char &expected[],const char &actual[],string message);
   void              assertEquals(const uchar &expected[],const uchar &actual[],string message);
   void              assertEquals(const short &expected[],const short &actual[],string message);
   void              assertEquals(const ushort &expected[],const ushort &actual[],string message);
   void              assertEquals(const int &expected[],const int &actual[],string message);
   void              assertEquals(const uint &expected[],const uint &actual[],string message);
   void              assertEquals(const long &expected[],const long &actual[],string message);
   void              assertEquals(const ulong &expected[],const ulong &actual[],string message);
   void              assertEquals(const datetime &expected[],const datetime &actual[],string message);
   void              assertEquals(const color &expected[],const color &actual[],string message);
   void              assertEquals(const float &expected[],const float &actual[],string message);
   void              assertEquals(const double &expected[],const double &actual[],string message);
   void              assertEquals(const string &expected[],const string &actual[],string message);

protected:
   string            m_current_test_name;

private:
   void              __assertTrue(bool actual,bool expected,string message);

   int               m_test_count;
   int               m_test_count_fail;

   int               m_current_assert_count;
   int               m_current_assert_count_fail;

   int               m_total_assert_count;
   int               m_total_assert_count_fail;

   void              setAssertSuccess(string message);
   void              setAssertFailure(string message);

   void              addAssert();

   string            summary(int count,int count_fail);
   void              printUnitTestSummary();
   void              printTestCaseSummary(void);

   bool              assertArraySize(const int actualSize,const int expectedSize,string message);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UnitTest::UnitTest()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UnitTest::~UnitTest(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::initUnitTest(void)
  {
   Comment("");
   Print("UnitTest - start");
   Print("================");

   m_test_count=0;
   m_test_count_fail=0;

   m_current_assert_count=0;
   m_current_assert_count_fail=0;

   m_total_assert_count=0;
   m_total_assert_count_fail=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::addTest(string test_name)
  {
   Print(StringConcatenate(UT_SPACE_TESTCASE,m_current_test_name,UT_SEP,"Running new unit test"));

   m_current_test_name=test_name;

   m_current_assert_count=0;
   m_current_assert_count_fail=0;

   m_test_count+=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::initTestCase(void)
  {
//Print(StringConcatenate(UT_SPACE_TESTCASE,"initTestCase"));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::endTestCase(void)
  {
   printTestCaseSummary();

   if(m_current_assert_count_fail!=0 || m_current_assert_count==0)
     {
      m_test_count_fail+=1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::printTestCaseSummary(void)
  {
   Print(StringConcatenate(UT_SPACE_TESTCASE,m_current_test_name,UT_SEP,"endTestCase"));

   string s=StringConcatenate(
                              UT_SPACE_TESTCASE,m_current_test_name,UT_SEP,
                              get_OK_Fail(m_current_assert_count_fail==0),UT_SEP,
                              summary(m_current_assert_count,m_current_assert_count_fail));

   Print(s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string UnitTest::summary(int count,int count_fail)
  {
   int count_success=count-count_fail;
   double count_success_percent;
   double count_failure_percent;
   if(count!=0)
     {
      count_success_percent= 100.0 * count_success/count;
      count_failure_percent= 100.0 * count_fail/count;
        } else {
      count_success_percent= 100.0;
      count_failure_percent= 0.0;
     }

   string s=StringFormat("Total: %d, Success: %d (%.2f%%), Failure: %d (%.2f%%)",
                         count,count_success,count_success_percent,
                         count_fail,count_failure_percent);
   return(s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::printUnitTestSummary(void)
  {
   Print("UnitTest summary");
   Print("================");

   string s_tests,s_asserts;

   s_asserts=StringConcatenate("asserts: ",summary(m_total_assert_count,m_total_assert_count_fail));

   Print(s_asserts);

   s_tests=StringConcatenate(get_OK_Fail(m_test_count_fail==0),
                             UT_SEP,summary(m_test_count,m_test_count_fail));
   Print(s_tests);

   Comment(s_tests+"\n"+s_asserts);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::printSummary(void)
  {
   printUnitTestSummary();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_OK_Fail(bool ok)
  {
   if(ok)
     {
      return("    OK    ");
        } else {
      return("***FAIL***");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::addAssert()
  {
   m_current_assert_count+=1;
   m_total_assert_count+=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::endUnitTest(void)
  {
   printUnitTestSummary();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::setAssertFailure(string message)
  {
   m_current_assert_count_fail+=1;
   m_total_assert_count_fail+=1;
   Print(StringConcatenate(UT_SPACE_ASSERT,m_current_test_name,UT_SEP,get_OK_Fail(false),UT_SEP,message));
   if(g_alert_when_failed)
     {
      Alert(StringConcatenate(get_OK_Fail(false),UT_SEP,m_current_test_name,UT_SEP,message));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::setAssertSuccess(string message)
  {
   Print(StringConcatenate(UT_SPACE_ASSERT,m_current_test_name,UT_SEP,get_OK_Fail(true),UT_SEP,message));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::__assertTrue(bool actual,bool expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,BooleanToString(expected),BooleanToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertTrue(bool actual,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   __assertTrue(true,actual,message); // caution true and True
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertFalse(bool actual,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   __assertTrue(false,actual,message); // caution false and False
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(char actual,char expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,CharToString(expected),CharToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(uchar actual,uchar expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,CharToString(expected),CharToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(short actual,short expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,IntegerToString(expected),IntegerToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(ushort actual,ushort expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,IntegerToString(expected),IntegerToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(int actual,int expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,IntegerToString(expected),IntegerToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(uint actual,uint expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,IntegerToString(expected),IntegerToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(long actual,long expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,IntegerToString(expected),IntegerToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(ulong actual,ulong expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,IntegerToString(expected),IntegerToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(datetime actual,datetime expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,TimeToString(expected),TimeToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(color actual,color expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,ColorToString(expected),ColorToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(float actual,float expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,DoubleToString(expected),DoubleToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(double actual,double expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,DoubleToString(expected),DoubleToString(actual));
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(string actual,string expected,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();

   if(actual==expected)
     {
      setAssertSuccess(message);
     }
   else
     {
      message=StringFormat(UT_COMP_EXP_ACT,message,expected,actual);
      setAssertFailure(message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool UnitTest::assertArraySize(const int expectedSize,const int actualSize,string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   if(actualSize==expectedSize)
     {
      return true;
     }
   else
     {
      //const string m = message + ": expected array size is <" + IntegerToString(expectedSize) +
      //    "> but <" + IntegerToString(actualSize) + ">";
      message=StringFormat("%s: expected array size is <%s> but <%s>",message,
                           IntegerToString(expectedSize),IntegerToString(actualSize));
      setAssertFailure(message);
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const bool &actual[],const bool &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,BooleanToString(expected[i]),BooleanToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const char &actual[],const char &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,CharToString(expected[i]),CharToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const uchar &actual[],const uchar &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,CharToString(expected[i]),CharToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const short &actual[],const short &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,IntegerToString(expected[i]),IntegerToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const ushort &actual[],const ushort &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,IntegerToString(expected[i]),IntegerToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const int &actual[],const int &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,IntegerToString(expected[i]),IntegerToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const uint &actual[],const uint &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,IntegerToString(expected[i]),IntegerToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const long &actual[],const long &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,IntegerToString(expected[i]),IntegerToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const ulong &actual[],const ulong &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,IntegerToString(expected[i]),IntegerToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const datetime &actual[],const datetime &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,TimeToString(expected[i]),TimeToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const color &actual[],const color &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,ColorToString(expected[i]),ColorToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const float &actual[],const float &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,DoubleToString(expected[i]),DoubleToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::assertEquals(const double &actual[],const double &expected[],string message=UT_DEFAULT_ASSERT_MESSAGE)
  {
   addAssert();
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(expectedSize,actualSize,message))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(expected[i]!=actual[i])
        {
         message=StringFormat(UT_COMP_ARR_EXP_ACT,message,
                              i,DoubleToString(expected[i]),DoubleToString(actual[i]));
         setAssertFailure(message);
         return;
        }
     }

   setAssertSuccess(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BooleanToString(bool b)
  {
   if(b)
     {
      return("true");
        }else {
      return("false");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UT_OnInit()
  {
   if(g_unit_testing)
     {
      unittest=new MyUnitTest();
     }

   if(g_unit_testing_OnInit)
     {
      unittest.runAllTests();
     }

   if(g_unit_testing_OnLoop)
     {
      datetime prev_time=TimeLocal();
      while(true)
        {
         if((TimeLocal()-prev_time)>=1) //Do stuff once per second
           {
            prev_time=TimeLocal();

            unittest.runAllTests();

           }
         Sleep(g_loop_ms);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UT_OnDeinit()
  {
   if(g_unit_testing)
     {
      unittest.printSummary();
     }

   delete unittest;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UT_OnTick()
  {
   if(g_unit_testing && g_unit_testing_OnTick)
     {
      unittest.runAllTests();
     }
  }

//+------------------------------------------------------------------+
