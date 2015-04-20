// inspired from https://www.rabbitmq.com/tutorials/tutorial-five-dotnet.html

using System;
using System.Text;

using RabbitMQ;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Newtonsoft.Json;


class ReceiveDOM
{
    public static void Main(string[] args)
    {
        var factory = new ConnectionFactory() { HostName = "localhost" };
        string m_topics = "topic_logs";
        using (var connection = factory.CreateConnection())
        {
            using (var channel = connection.CreateModel())
            {
                channel.ExchangeDeclare(m_topics, "topic");
                var queueName = channel.QueueDeclare();
                var bindingkeys = args;

                if (args.Length < 1)
                {
                    //Console.Error.WriteLine("Usage: {0} [binding_key... (use # for all) ]",
                    //                        Environment.GetCommandLineArgs()[0]);
                    //Environment.ExitCode = 1;
                    //return;
                    Console.WriteLine("Receiving all DOM data using routingkey '#'");
                    channel.QueueBind(queueName, m_topics, "#");
                }

                foreach (var bindingKey in bindingkeys)
                {
                    channel.QueueBind(queueName, m_topics, bindingKey);
                    Console.WriteLine("Receiving DOM data from to '" + bindingKey + "'");
                }

                Console.WriteLine(" [*] Waiting for DOM. " +
                                  "To exit press CTRL+C");

                var consumer = new QueueingBasicConsumer(channel);
                channel.BasicConsume(queueName, true, consumer);

                while (true)
                {
                    var ea = (BasicDeliverEventArgs)consumer.Queue.Dequeue();
                    var body = ea.Body;
                    var message = Encoding.UTF8.GetString(body);
                    var routingKey = ea.RoutingKey;

                    Console.WriteLine(" [x] Received DOM data from '{0}'", routingKey);
                    //Console.WriteLine(" [x] Received '{0}':'{1}'",
                    //                  routingKey, message);

                    var deserialized = JsonConvert.DeserializeObject(message);

                    Console.WriteLine(deserialized);

                    // http://james.newtonking.com/json/help/index.html?topic=html/QueryingLINQtoJSON.htm

                    //deserialized

                }
            }
        }
    }
}