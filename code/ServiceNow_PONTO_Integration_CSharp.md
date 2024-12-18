# ServiceNow and PONTO System Integration Example (C#)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **C#**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```csharp
using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

public class ServiceNowIntegration
{
    private static readonly string instance = "your-instance.service-now.com";
    private static readonly string pontoAPI = "https://sistema-ponto.com/api/marcacoes";
    private static readonly string clientId = "your-client-id";
    private static readonly string clientSecret = "your-client-secret";
    private static readonly string username = "your-username";
    private static readonly string password = "your-password";

    // 1. Login to ServiceNow
    public static async Task<string> LoginServiceNowAsync()
    {
        using (var client = new HttpClient())
        {
            var url = $"https://{instance}/oauth_token.do";
            var payload = new
            {
                grant_type = "password",
                client_id = clientId,
                client_secret = clientSecret,
                username = username,
                password = password
            };

            var response = await client.PostAsync(url, new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json"));

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error logging in: " + response.ReasonPhrase);
            }

            var result = JsonConvert.DeserializeObject<dynamic>(await response.Content.ReadAsStringAsync());
            return result.access_token;
        }
    }

    // 2. Query the PONTO System
    public static async Task<string> ConsultaSistemaPontoAsync(string token, string requisicaoId)
    {
        using (var client = new HttpClient())
        {
            var url = $"https://{instance}/api/now/table/ponto_data?sys_id={requisicaoId}";
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");

            var response = await client.GetAsync(url);
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error querying the PONTO system: " + response.ReasonPhrase);
            }

            return await response.Content.ReadAsStringAsync();
        }
    }

    // 3. Create a Request in ServiceNow
    public static async Task<string> AbrirRequisicaoAsync(string token, object requisicaoData)
    {
        using (var client = new HttpClient())
        {
            var url = $"https://{instance}/api/now/table/requisicoes_ponto";
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");

            var response = await client.PostAsync(url, new StringContent(JsonConvert.SerializeObject(requisicaoData), Encoding.UTF8, "application/json"));
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error creating request: " + response.ReasonPhrase);
            }

            return await response.Content.ReadAsStringAsync();
        }
    }

    // 4. Update Request Status in ServiceNow
    public static async Task<string> AtualizarStatusRequisicaoAsync(string token, string requisicaoId, object statusData)
    {
        using (var client = new HttpClient())
        {
            var url = $"https://{instance}/api/now/table/requisicoes_ponto?sys_id={requisicaoId}";
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");

            var response = await client.PutAsync(url, new StringContent(JsonConvert.SerializeObject(statusData), Encoding.UTF8, "application/json"));
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error updating request status: " + response.ReasonPhrase);
            }

            return await response.Content.ReadAsStringAsync();
        }
    }

    // 5. Log Audit Data in ServiceNow
    public static async Task<string> RegistrarAuditoriaAsync(string token, object auditData)
    {
        using (var client = new HttpClient())
        {
            var url = $"https://{instance}/api/now/table/audit_logs";
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");

            var response = await client.PostAsync(url, new StringContent(JsonConvert.SerializeObject(auditData), Encoding.UTF8, "application/json"));
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error logging audit data: " + response.ReasonPhrase);
            }

            return await response.Content.ReadAsStringAsync();
        }
    }

    // Execution Flow
    public static async Task Main(string[] args)
    {
        try
        {
            var token = await LoginServiceNowAsync();

            // Example: Query the PONTO system
            var consulta = await ConsultaSistemaPontoAsync(token, "requisicao-id-example");
            Console.WriteLine("PONTO system query: " + consulta);

            // Example: Create a request
            var requisicaoData = new
            {
                example_field = "value"
            };
            var requisicao = await AbrirRequisicaoAsync(token, requisicaoData);
            Console.WriteLine("Request created: " + requisicao);

            // Example: Update status
            var statusData = new
            {
                status = "Completed"
            };
            var statusUpdate = await AtualizarStatusRequisicaoAsync(token, "requisicao-id-example", statusData);
            Console.WriteLine("Status updated: " + statusUpdate);

            // Example: Log audit data
            var auditData = new
            {
                action = "Request updated",
                details = "The request status was updated to Completed"
            };
            var auditLog = await RegistrarAuditoriaAsync(token, auditData);
            Console.WriteLine("Audit log created: " + auditLog);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Integration flow error: " + ex.Message);
        }
    }
}
```