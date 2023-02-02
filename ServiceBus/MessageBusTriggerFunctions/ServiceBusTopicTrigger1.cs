using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;

namespace labsservicebusfunctionapp
{
    public class ServiceBusTopicTrigger1
    {
        private readonly ILogger<ServiceBusTopicTrigger1> _logger;

        public ServiceBusTopicTrigger1(ILogger<ServiceBusTopicTrigger1> log)
        {
            _logger = log;
        }

        //[Disable] // when you want to disable a specific function inside your functionapp
        [FunctionName("ServiceBusTopicTrigger1")]
        public void Run([ServiceBusTrigger("labservicebustopic", "labServiceBusTopicSub1", Connection = "labsServiceBusNamespace_SERVICEBUS")] Message message, MessageReceiver messageReceiver)
        {
            // O servicebus do exemplo está configurado para autocomplete = false em host.json. Assim, todas as mensagens vão precisar enviar ao broker explicitamente o comdando para que esse saiba o que fazer com a mensagem na fila. 
            // Caso o comportamento do autocomplete variar entre mensagens e tópicos de um único servicebus, então ao invés de haver uma entrada em host.json, colocar um argumento AutoComplete = false logo após o argumento Connection. O default é autocomplete = true
            //https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger?tabs=in-process%2Cextensionv5&pivots=programming-language-csharp#attributes

            _logger.LogInformation($"C# ServiceBus queue trigger function processed message from topic1: {message.Body.ToString()}");
            _logger.LogInformation($"C# Message: {message.ToString()}, Delivery Count: {message.SystemProperties.DeliveryCount.ToString()}, LockToken: {message.SystemProperties.LockToken.ToString()}");

            //messageReceiver.AbandonAsync(message.SystemProperties.LockToken); // Quando não foi possível processar a mensagem por uma razão temporária. A mensagem volta pra fila para ser consumida novamente. 
            //messageReceiver.DeadLetterAsync(message.SystemProperties.LockToken); // Se der algum problema sem chance de nova tentativa
            // messageReceiver.RenewLockAsync(lockToken); Se precisar pedir renovação de um novo ciclo de renew de lock da mensagem
            messageReceiver.CompleteAsync(message.SystemProperties.LockToken); // Quando a mensagem foi processada com sucesso e a função está avisando ao servicebus que a mensagem pode sair da fila
            // Caso nenhum comando for enviado ao ServiceBus, então esse vai esperar o lock da mensagem expirar e disponibilizar a mensagem na fila novamente para uma nova tentativa até alcançar o número máximo de tentativas de entrega. 
        }
    }
}
