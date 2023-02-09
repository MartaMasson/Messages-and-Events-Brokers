using System;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;


namespace EventHubSender
{
    class Program
    {

        // connection string to the Event Hubs namespace
        private const string connectionString = "Endpoint=sb://labseventhubnamespace.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=ZniOYyPO51Fbs230ewUP1kZtb55hydcev3LWlzYVqts=";

        // name of the event hub
        private const string eventHubName = "lab1eventhub";

        // number of events to be sent to the event hub
        private const int numOfEvents = 10;

        // The Event Hubs client types are safe to cache and use as a singleton for the lifetime
        // of the application, which is best practice when events are being published or read regularly.
        static EventHubProducerClient producerClient;

        static async Task Main(string[] args)
        {

            // Create a producer client that you can use to send events to an event hub
            producerClient = new EventHubProducerClient(connectionString, eventHubName);

            // Create a batch of events 
            using EventDataBatch eventBatch = await producerClient.CreateBatchAsync();

            for (int i = 1; i <= numOfEvents; i++)
            {

                if (!eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes($"Event collection teste com o time da BRF - {i}"))))
                {
                    // if it is too large for the batch
                    throw new Exception($"Event collection 1 - {i} is too large for the batch and cannot be sent.");
                }
                else
                {
                    Console.WriteLine($"Event collection 1 - {i} add to eventBatch.");

                }
            }

            try
            {
                // Use the producer client to send the batch of events to the event hub
                await producerClient.SendAsync(eventBatch);
                Console.WriteLine($"A batch of {numOfEvents} events has been published.");
            }
            finally
            {
                await producerClient.DisposeAsync();
            }

        }
    }
}
