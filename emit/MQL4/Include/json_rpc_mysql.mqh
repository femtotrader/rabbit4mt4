//+------------------------------------------------------------------+
//|                                               json_rpc_mysql.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init_table_names(string table_prefix)
  {
   g_table_name_rpc=table_prefix+"json_rpc";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_reply_to_from_request_id(string request_id)
  {
   string reply_to;
   reply_to=StringSubstr(request_id,0,22);
   StringReplace(reply_to,"-","0");
//reply_to = StringConcatenate("amq.gen-", reply_to);
   reply_to=StringConcatenate("rpc_queue_resp-",reply_to);
   return(reply_to);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_json_rpc_from_db(int db_connect_id,string terminal_id)
  {
   string query;
   query="SELECT request_id, request FROM `"+g_table_name_rpc+"` where `terminal_id`="+quote(terminal_id)+" and not was_received ORDER BY `id`;";
//query="SELECT request_id, request, reply_to FROM `"+g_table_name_rpc+"` where `terminal_id`="+quote(terminal_id)+" and not was_received ORDER BY `id`;";
//ToFix: see https://github.com/sergeylukin/mql4-mysql/issues/1
//Access violation read to 0xA7E209F6 in 'msvcrt.dll' when fetching 3 columns (and not when fetching 2) 
//Print(query);

//logging_debug(query);

   int nb_rpc_in_db=0;
   int result=-1;

   string data[][3];  // NB_COLS_RPC important: second dimension size must be equal to the number of columns

                      //Print("Fetching");
   result=MySQL_FetchArray(db_connect_id,query,data);
//Print("Fetched");

   JSONParser *parser=new JSONParser();

   if(result==0)
     {
      //logging_debug("no data fetch");
      nb_rpc_in_db=0;
        } else if(result==-1) {
      logging_error("some errors occured");
      nb_rpc_in_db=0;
        } else {
      nb_rpc_in_db = ArrayRange(data, 0); // RPC count
      int num_cols = ArrayRange(data, 1); // number of columns
      logging_debug("Query was successful. Printing rows... ("+IntegerToString(nb_rpc_in_db)+"rows x "+IntegerToString(num_cols)+"cols)");

      string s_json_rpc_request;
      //string id;
      string request_id;
      string request_id_from_db;
      string s_json_rpc_response;
      string s_reply_to;

      for(int i=0; i<nb_rpc_in_db; i++)
        {
         // get data from DB
         //id=data[i][0];
         request_id_from_db=data[i][0]; //0 request_id is the 1rst column
         s_json_rpc_request=data[i][1]; //1 JSON RPC request is the 2nd column
                                        //s_reply_to=data[i][2]; //2 reply_to is the 3rd column
         //logging_info(s_json_rpc_request);

         // UPDATE table to set that this RPC was received (and to avoid to execute same RPC several times)
         query="UPDATE `"+g_table_name_rpc+"` SET `was_received`=TRUE WHERE `terminal_id`="+quote(terminal_id)+" AND `request_id`="+quote(request_id_from_db)+";";
         //logging_debug(query);
         result=MySQL_Query(db_connect_id,query);
         if(result!=1)
           {
            logging_critical("UPDATE query 'was_received' failed");
           }

         // Execute RPC
         // request_id and s_json_rpc_response are passed as reference
         // in order to output request_id and s_json_rpc_response
         result=Execute_JSON_RPC_Request(parser,s_json_rpc_request,request_id,s_json_rpc_response);
         if(request_id!=request_id_from_db)
           {
            logging_error("request_id!=request_id_from_db");
            logging_error("request_id_from_db: "+request_id_from_db);
            logging_error("request_id: "+request_id);
            break;
           }
         s_reply_to=get_reply_to_from_request_id(request_id_from_db); // BadFix: uggly fix - workarround MySQL FetchArray bug
         if(result!=0)
           {
            logging_error("RPC JSON parsing error");
            break;
           }
         logging_info(StringFormat("reply_to: %s",s_reply_to));
         logging_info(StringFormat("response: %s",s_json_rpc_response));
         if(s_json_rpc_response!="")
           {
            string msg=StringFormat("Sending '%s' to '%s'",s_json_rpc_response,s_reply_to);
            logging_info(msg);
            SendMessageToQueue(s_reply_to,s_json_rpc_response);
           }

         // Send_JSON_RPC_Response(s_reply_to, s_json_rpc_response);

         // question: should void return a null response or nothing ?

         Sleep(3000);
         //Sleep(g_sleep_ms);

        }

      delete parser;
     }
  }
//+------------------------------------------------------------------+
//| remove previous RPC from DB to ensure not to run                 |
//| RPC several times                                                |
//+------------------------------------------------------------------+
int remove_json_rpc_from_db(int db_connect_id,string terminal_id)
  {
   string query;
   query="DELETE FROM `"+g_table_name_rpc+"` WHERE `terminal_id`="+quote(terminal_id)+";";
//Print(query);
   int result;
   result=MySQL_Query(db_connect_id,query);
   if(result!=1)
     {
      logging_critical("DELETE query failed");
      logging_info("result="+IntegerToString(result));
     }
   return(result);
  }
//+------------------------------------------------------------------+
