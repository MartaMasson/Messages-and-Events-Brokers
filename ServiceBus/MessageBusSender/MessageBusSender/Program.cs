using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;

namespace MessageBusSender
{
    internal class Program
    {
        static async Task Main(string[] args)
        {
            // the client that owns the connection and can be used to create senders and receivers
            ServiceBusClient client;

            // the sender used to publish messages to the queue
            ServiceBusSender sender;

            // number of messages to be sent to the queue
            const int numOfMessages = 10;


            var clientOptions = new ServiceBusClientOptions()
            {
                TransportType = ServiceBusTransportType.AmqpWebSockets
            };
            client = new ServiceBusClient("Coloque aqui a connection string do servicebus", clientOptions);

            //sender = client.CreateSender("labservicebusqueue"); // queue
            sender = client.CreateSender("labservicebustopic"); // topic

            // create a batch 
            using ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync();

            string mymsg = "";

            for (int i = 1; i <= numOfMessages; i++)
            {

                mymsg = $"Message in queue/topic - commit testing 2 - {i}";

                // try adding a message to the batch
                if (!messageBatch.TryAddMessage(new ServiceBusMessage(mymsg)))
                {
                    // if it is too large for the batch
                    throw new Exception($"{mymsg} is too large to fit in the batch.");
                }
                else
                {
                    Console.WriteLine(mymsg);
                }
            }

            try
            {
                // Use the producer client to send the batch of messages to the Service Bus queue
                await sender.SendMessagesAsync(messageBatch);
                Console.WriteLine($"A batch of {numOfMessages} messages has been published to the queue.");
            }
            finally
            {
                // Calling DisposeAsync on client types is required to ensure that network
                // resources and other unmanaged objects are properly cleaned up.
                await sender.DisposeAsync();
                await client.DisposeAsync();
            }

            Console.WriteLine("Press any key to end the application");
            Console.ReadKey();

        }
    }
}




