using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

//using Rabbit4mt4DLL;

/*
 * 
 * This console application is only use to test DLL
 * 
 * It can (should) send tick data (like MT4 is doing)
 * 
 */
namespace ConsoleApplicationTestRabbit4mt4
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Test Rabbit4mt4");
            //Rabbit4mt4DLL.Test.SendTickToMQ("EURUSD", 1.34, 1.35);
        }
    }
}
