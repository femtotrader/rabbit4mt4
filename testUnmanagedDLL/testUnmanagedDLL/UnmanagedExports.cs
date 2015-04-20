using System;
using System.Text;
using System.Threading;
using RGiesecke.DllExport;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Collections.Generic;

/*
 * Metatrader / RabbitMQ bridge
 * 
 * FemtoTrader <femto.trader@gmail.com>
 * 
 * Additional packages can be installed
 * using NuGet http://www.nuget.org/
 * 
 * Dependencies:
 *  - RabbitMQ.Client
 *  
 * This project is inspired from
 * http://vb6-to-csharp.blogspot.fr/2012/04/code-to-export-c-dll-to-metatrader.html
 * https://sites.google.com/site/robertgiesecke/Home/uploads
 * https://sites.google.com/site/robertgiesecke/Home/uploads
 * 
 * In you like this feel free to send me some crypto coins
 * https://sites.google.com/site/femtotrader/donate 
 * 
 */
using System.Web.Script.Serialization; // default JSON (System.Web.Extensions)
//using Newtonsoft.Json; // installed using NuGet 

public class TickDouble
{
    public double bid { get; set; }
    public double ask { get; set; }
}

public class TickDecimal
{
    public decimal bid { get; set; }
    public decimal ask { get; set; }
}

public class TickString
{
    public string bid { get; set; }
    public string ask { get; set; }
}

public class ReceivedOrder
{
    public string stop_loss { get; set; }
    public string take_profit { get; set; }
    public string volume { get; set; }
    public string expiration { get; set; }
    public string open_price { get; set; }
}

public class Worker
{
    // This method will be called when the thread is started.

    public IConnection m_connection;
    //public string m_terminal_id;

    public void DoWork()
    {

        IModel channel = m_connection.CreateModel();

        //string rpc_queue = "rpc_queue_" + m_routingkey_root; // terminal_id
        string rpc_queue = "rpc_queue";
        channel.QueueDeclare(rpc_queue, false, false, false, null);
        channel.BasicQos(0, 1, false);
        var consumer = new QueueingBasicConsumer(channel);
        channel.BasicConsume(rpc_queue, false, consumer);
        MessageBox.Show(" [x] Awaiting RPC requests on '" + rpc_queue + "'");

        _shouldStop = false;
        
        while (!_shouldStop)
        {
            MessageBox.Show("worker thread: working...");


            /*
            MessageBox.Show("wait message");

            string response = null;
            var ea = (BasicDeliverEventArgs)consumer.Queue.Dequeue();

            var body = ea.Body;
            var props = ea.BasicProperties;
            var replyProps = channel.CreateBasicProperties();
            replyProps.CorrelationId = props.CorrelationId;

            try
            {
                var message = Encoding.UTF8.GetString(body);
                MessageBox.Show(message);
                //m_message = message.ToString();
                //int n = int.Parse(message);
                //Console.WriteLine(" [.] fib({0})", message);
                //response = fib(n).ToString();
            }
            catch (Exception e)
            {
                MessageBox.Show(" [.] Exception");
                //MessageBox.Show(" [.] " + e.Message);
                response = "";
            }
            finally
            {
                MessageBox.Show("finally");
                //var responseBytes = Encoding.UTF8.GetBytes(response);
                //channel.BasicPublish("", props.ReplyTo, replyProps, responseBytes);
                //channel.BasicAck(ea.DeliveryTag, false);
            }
             */
        }
        MessageBox.Show("worker thread: terminating gracefully.");
    }
    public void RequestStop()
    {
        _shouldStop = true;
    }
    // Volatile is used as hint to the compiler that this data
    // member will be accessed by multiple threads.
    private volatile bool _shouldStop;
}


namespace Rabbit4mt4DLL
{
    public static class Test
    {
        private static string m_hostName = "";
        private static string m_exchange = "";
        private static string m_routingkey_root = "";
        private static IConnection m_connection;

        private static string m_message = "";

        private static bool m_wait_message;

        //private static DateTime m_dt_init;

        /*
         * Initialize RabbitMQ connection
         */
        [DllExport("InitializeMQConnection", CallingConvention = CallingConvention.StdCall)]
        public static int InitializeMQConnection([MarshalAs(UnmanagedType.LPWStr)] string hostName, [MarshalAs(UnmanagedType.LPWStr)] string username, [MarshalAs(UnmanagedType.LPWStr)] string password, [MarshalAs(UnmanagedType.LPWStr)] string virtualhost, [MarshalAs(UnmanagedType.LPWStr)] string exchange, [MarshalAs(UnmanagedType.LPWStr)] string routingkey_root)
        {
            try
            {

                m_hostName = hostName; // "localhost";

                m_exchange = exchange; //"topic_logs";
                m_routingkey_root = routingkey_root;

                //m_dt_init = DateTime.UtcNow;
                m_wait_message = true;

                m_message = "Sample message";
                
                ConnectionFactory factory = new ConnectionFactory();
                factory.HostName = m_hostName;
                factory.UserName = username;
                factory.Password = password;
                factory.VirtualHost = virtualhost;
                
                m_connection = factory.CreateConnection();
                return (0);
            }
            catch (Exception e)
            {
                ShowDLLException(e);
                return (1);
            } 

        }

        /*
         * Display message box with exception message
         */
        private static void ShowDLLException(Exception e)
        {
            MessageBox.Show(e.Message, "DLL exception", MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
        }


        /*
         * Send tick to an exchange m_exchange
         */
        [DllExport("SendTickToMQ", CallingConvention = CallingConvention.StdCall)]
        public static int SendTickToMQ([MarshalAs(UnmanagedType.LPWStr)] string symbol, double bid, double ask)
        {
            try
            {
                IModel channel = m_connection.CreateModel();
                channel.ExchangeDeclare(m_exchange, "topic");

                string m_routingkey = m_routingkey_root + "." + "events" + "." + "ticks" + "." + symbol.ToLower();
                string message = GetTickMessage(bid, ask);
                channel.BasicPublish(m_exchange, m_routingkey, null, Encoding.UTF8.GetBytes(message));
                channel.Close();
                return (0);
            }
            catch (Exception e)
            {
                ShowDLLException(e);
                return(1);
            }
        }

        /*
         * Send message to an exchange m_exchange
         */
        [DllExport("SendMessageToMQ", CallingConvention = CallingConvention.StdCall)]
        public static int SendMessageToMQ([MarshalAs(UnmanagedType.LPWStr)] string routingkey, [MarshalAs(UnmanagedType.LPWStr)] string message)
        {
            try
            {
                IModel channel = m_connection.CreateModel();
                channel.ExchangeDeclare(m_exchange, "topic");
                channel.BasicPublish(m_exchange, routingkey, null, Encoding.UTF8.GetBytes(message));
                channel.Close();
                return (0);
            }
            catch (Exception e)
            {
                ShowDLLException(e);
                return (1);
            }
        
        }


        /*
         * Send message to a queue (directly to a queue without exchange)
         */
        [DllExport("SendMessageToQueue", CallingConvention = CallingConvention.StdCall)]
        public static int SendMessageToQueue([MarshalAs(UnmanagedType.LPWStr)] string queue, [MarshalAs(UnmanagedType.LPWStr)] string message)
        {
            try
            {
                IModel channel = m_connection.CreateModel();
                channel.QueueDeclare(queue, false, false, false, null);
                channel.BasicPublish("", queue, null, Encoding.UTF8.GetBytes(message));
                channel.Close();
                return (0);
            }
            catch (Exception e)
            {
                ShowDLLException(e);
                return (1);
            }

        }

        /*
         * Close RabbitMQ connection
         */
        [DllExport("CloseMQConnection", CallingConvention = CallingConvention.StdCall)]
        public static int CloseMQConnection()
        {
            try
            {
                m_connection.Close();
                return (0);
            }
            catch (Exception e)
            {
                ShowDLLException(e);
                return (1);
            }
        }

        /*
         * Display Input string in a message box and return a string to MT4
         * we are using MarshalAs(UnmanagedType.LPWStr) with MT4 build>=600
         */
        [DllExport("returnString", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string returnString([MarshalAs(UnmanagedType.LPWStr)] string Input)
        {
            MessageBox.Show("Received: " + Input);
            return ("SEND to MT4 (" + Input + ")");
        }

        private static string GetTickMessage(double bid, double ask)
        {
            TickString tick = new TickString();
            tick.bid = bid.ToString();
            tick.ask = ask.ToString();
            //string msg = JsonConvert.SerializeObject(tick);
            JavaScriptSerializer ser = new JavaScriptSerializer();
            string msg = ser.Serialize(tick);
            return (msg);
        }

        /*
         * Returns Rabbit4mt4 version
         */
        [DllExport("GetMQVersion", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string GetMQVersion()
        {
            //DateTime m_dt_init = DateTime.UtcNow;
            //return ("Rabbit4mt4 v1.0.0 " + m_dt_init.ToString());
            string msg;
            msg = "Rabbit4mt4 v1.0.0 " + m_routingkey_root;
            return (msg);
        }


        [DllExport("DisableWaitMessage", CallingConvention = CallingConvention.StdCall)]
        public static int DisableWaitMessage()
        {
            m_wait_message = false;
            return (0);
        }

        [DllExport("EnableWaitMessage", CallingConvention = CallingConvention.StdCall)]
        public static int EnableWaitMessage()
        {
            m_wait_message = true;
            return (0);
        }


        [DllExport("WaitMessage", CallingConvention = CallingConvention.StdCall)]
        public static int WaitMessage()
        {

            // Create the thread object. This does not start the thread.
            Worker workerObject = new Worker();
            workerObject.m_connection = m_connection;

            Thread workerThread = new Thread(workerObject.DoWork);

            // Start the worker thread.
            workerThread.Start();
            MessageBox.Show("main thread: Starting worker thread...");

            // Loop until worker thread activates.
            while (!workerThread.IsAlive) ;

            // Put the main thread to sleep for 1 millisecond to
            // allow the worker thread to do some work:
            Thread.Sleep(1);

            // Request that the worker thread stop itself:
            workerObject.RequestStop();

            // Use the Join method to block the current thread 
            // until the object's thread terminates.
            workerThread.Join();
            MessageBox.Show("main thread: Worker thread has terminated.");
            
            //while (m_wait_message)
            //{ 
            //    MessageBox.Show("WaitMessage");
            //}

            /*


            //while (m_wait_message)
            while (true)
            {


            } */

            return (0);
        }


        [DllExport("GetMessage", CallingConvention = CallingConvention.StdCall)]
        [return: MarshalAs(UnmanagedType.LPWStr)]
        public static string GetMessage()
        {
            return (m_message);
        }

    }
}