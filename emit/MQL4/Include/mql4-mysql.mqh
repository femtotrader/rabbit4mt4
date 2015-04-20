//+----------------------------------------------------------------------------+
//|                                                             mql4-mysql.mqh |
//+----------------------------------------------------------------------------+
//|                                                      Built by Sergey Lukin |
//|                                                    contact@sergeylukin.com |
//|                                                                            |
//| This libarry is highly based on following:                                 |
//|                                                                            |
//| - MySQL wrapper by "russel": http://codebase.mql4.com/5040                 |
//| - MySQL wrapper modification by "vedroid": http://codebase.mql4.com/8122   |
//| - EAX Mysql: http://www.mql5.com/en/code/855                               |
//| - This thread: http://forum.mql4.com/60708 (Cheers to user "gchrmt4" for   |
//|   expanded explanations on how to deal with ANSI <-> UNICODE hell in MQL4  |
//|                                                                            |
//+----------------------------------------------------------------------------+
#property copyright "Unlicense"
#property link      "http://unlicense.org/"
 
#import "kernel32.dll"
   int lstrlenA(int);
   void RtlMoveMemory(uchar & arr[], int, int);
   int LocalFree(int); // May need to be changed depending on how the DLL allocates memory
#import
 
#import "msvcrt.dll"
  // TODO extend/handle 32/64 bit codewise
  int memcpy(char &Destination[], int Source, int Length);
  int memcpy(char &Destination[], long Source, int Length);
  int memcpy(int &dst,  int src, int cnt);
  int memcpy(long &dst,  long src, int cnt);  
#import
 
#import "libmysql.dll"
int     mysql_init          (int dbConnectId);
int     mysql_errno         (int dbConnectId);
int     mysql_error         (int dbConnectId);
int     mysql_real_connect  (int dbConnectId, uchar & host[], uchar & user[], uchar & password[], uchar & db[], int port, int socket, int clientflag);
int     mysql_real_query    (int dbConnectId, uchar & query[], int length);
int     mysql_query         (int dbConnectId, uchar & query[]);
void    mysql_close         (int dbConnectId);
int     mysql_store_result  (int dbConnectId);
int     mysql_use_result    (int dbConnectId);
int     mysql_insert_id     (int dbConnectId);
 
int     mysql_fetch_row     (int resultStruct);
int     mysql_fetch_field   (int resultStruct);
int     mysql_fetch_lengths (int resultStruct);
int     mysql_num_fields    (int resultStruct);
int     mysql_num_rows      (int resultStruct);
void    mysql_free_result   (int resultStruct);
#import
 
//+----------------------------------------------------------------------------+
//| Connect to MySQL and write connection ID to the first argument             |
//| Probably not the most elegant way but it works well for simple purposes    |
//| and is flexible enough to allow multiple connections                       |
//+----------------------------------------------------------------------------+
bool init_MySQL(int & dbConnectId, string host, string user, string pass, string dbName, int port = 3306, int socket = 0, int client = 0) {
    dbConnectId = mysql_init(dbConnectId);
    
    if ( dbConnectId == 0 ) {
        Print("init_MySQL: mysql_init failed. There was insufficient memory to allocate a new object");
        return (false);
    }
    
    // Convert the strings to uchar[] arrays
   uchar hostChar[];
   StringToCharArray(host, hostChar);
   uchar userChar[];
   StringToCharArray(user, userChar);
   uchar passChar[];
   StringToCharArray(pass, passChar);
   uchar dbNameChar[];
   StringToCharArray(dbName, dbNameChar);
    
    int result = mysql_real_connect(dbConnectId, hostChar, userChar, passChar, dbNameChar, port, socket, client); 
    
    if ( result != dbConnectId ) {
        int errno = mysql_errno(dbConnectId);
        string error = mql4_mysql_ansi2unicode(mysql_error(dbConnectId));
        
        Print("init_MySQL: mysql_errno: ", errno,"; mysql_error: ", error);
        return (false);
    }
    return (true);
}

//+----------------------------------------------------------------------------+
//|                                                                            |
//+----------------------------------------------------------------------------+
void deinit_MySQL(int dbConnectId){
    mysql_close(dbConnectId);
}

//+----------------------------------------------------------------------------+
//| Check whether there was an error with last query                           |
//|                                                                            |
//| return (true): no error; (false): there was an error;                      |
//+----------------------------------------------------------------------------+
bool MySQL_NoError(int dbConnectId) {
    int errno = mysql_errno(dbConnectId);
    string error = mql4_mysql_ansi2unicode(mysql_error(dbConnectId));
    
    if ( errno > 0 ) {
        Print("MySQL_NoError: mysql_errno: ", errno,"; mysql_error: ", error);
        return (false);
    }
    return (true);
}

//+----------------------------------------------------------------------------+
//| Simply run a query, perfect for actions like INSERTs, UPDATEs, DELETEs     |
//+----------------------------------------------------------------------------+
bool MySQL_Query(int dbConnectId, string query) {
    uchar queryChar[];
    StringToCharArray(query, queryChar);
    
    mysql_query(dbConnectId, queryChar);
    if ( MySQL_NoError(dbConnectId) ) {
        return (true);
    }
    return (false);
}
 
//+----------------------------------------------------------------------------+
//| Fetch row(s) in a 2-dimansional array                                      |
//|                                                                            |
//| return (-1): error; (0): 0 rows selected; (1+): some rows selected;         |
//+----------------------------------------------------------------------------+
int MySQL_FetchArray(int dbConnectId, string query, string & data[][]){

    if ( !MySQL_Query(dbConnectId, query) ) {
        return (-1);
    }
        
    int resultStruct = mysql_store_result(dbConnectId);
    
    if ( !MySQL_NoError(dbConnectId) ) {
        Print("mysqlFetchArray: resultStruct: ", resultStruct);
        return (-1);
    }
    int num_rows   = mysql_num_rows(resultStruct);
    int num_fields = mysql_num_fields(resultStruct);
    
    char byte[];
    
    if ( num_rows == 0 ) {  // 0 rows selected;
        return (0);
    }
    
    ArrayResize(data, num_rows);

    
    for ( int i = 0; i < num_rows; i++ ) {
    
      int row_ptr = mysql_fetch_row(resultStruct);
      int len_ptr = mysql_fetch_lengths(resultStruct);
      
      for ( int j = 0; j < num_fields; j++ ) {
         //Print(i, j);
         int leng;
         memcpy(leng, len_ptr + j*sizeof(int), sizeof(int));
         
         //Print("resize");
         ArrayResize(byte,leng+1);
         ArrayInitialize(byte,0);
         
         //Print("memcpy");
         int row_ptr_pos;
         //Print("memcpy1");
         memcpy(row_ptr_pos, row_ptr + j*sizeof(int), sizeof(int));
         //Print("memcpy2");
         memcpy(byte, row_ptr_pos, leng);
         
         //Print("s");
         string s = CharArrayToString(byte);
         data[i][j] = s;
         
         //Print("LocalFree");
         LocalFree(leng);
         LocalFree(row_ptr_pos);
      }
    }
    
    mysql_free_result(resultStruct);
    
    if ( MySQL_NoError(dbConnectId) ) {
        return (num_rows);
    }    
    return (-1);
}

//+----------------------------------------------------------------------------+
//| Lovely function that helps us to get ANSI strings from DLLs to our UNICODE |
//| format                                                                     |
//| http://forum.mql4.com/60708                                                |
//+----------------------------------------------------------------------------+
string mql4_mysql_ansi2unicode(int ptrStringMemory)
{
  int szString = lstrlenA(ptrStringMemory);
  uchar ucValue[];
  ArrayResize(ucValue, szString + 1);
  RtlMoveMemory(ucValue, ptrStringMemory, szString + 1);
  string str = CharArrayToString(ucValue);
  LocalFree(ptrStringMemory);
  return str;
}
//+----------------------------------------------------------------------------+

