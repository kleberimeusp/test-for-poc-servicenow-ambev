# ServiceNow and PONTO System Integration Example (Java)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Java**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```java
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;

public class ServiceNowIntegration {

    private static final String INSTANCE = "your-instance.service-now.com";
    private static final String CLIENT_ID = "your-client-id";
    private static final String CLIENT_SECRET = "your-client-secret";
    private static final String USERNAME = "your-username";
    private static final String PASSWORD = "your-password";

    // 1. Login to ServiceNow
    public static String loginServiceNow() throws Exception {
        String url = String.format("https://%s/oauth_token.do", INSTANCE);
        Map<String, String> payload = new HashMap<>();
        payload.put("grant_type", "password");
        payload.put("client_id", CLIENT_ID);
        payload.put("client_secret", CLIENT_SECRET);
        payload.put("username", USERNAME);
        payload.put("password", PASSWORD);

        String response = sendPostRequest(url, payload, null);
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> result = mapper.readValue(response, Map.class);
        return result.get("access_token").toString();
    }

    // 2. Query the PONTO System
    public static String consultaSistemaPonto(String token, String requisicaoId) throws Exception {
        String url = String.format("https://%s/api/now/table/ponto_data?sys_id=%s", INSTANCE, requisicaoId);
        return sendGetRequest(url, token);
    }

    // 3. Create a Request in ServiceNow
    public static String abrirRequisicao(String token, Map<String, Object> requisicaoData) throws Exception {
        String url = String.format("https://%s/api/now/table/requisicoes_ponto", INSTANCE);
        return sendPostRequest(url, requisicaoData, token);
    }

    // 4. Update Request Status
    public static String atualizarStatusRequisicao(String token, String requisicaoId, Map<String, Object> statusData) throws Exception {
        String url = String.format("https://%s/api/now/table/requisicoes_ponto?sys_id=%s", INSTANCE, requisicaoId);
        return sendPutRequest(url, statusData, token);
    }

    // 5. Log Audit Data
    public static String registrarAuditoria(String token, Map<String, Object> auditData) throws Exception {
        String url = String.format("https://%s/api/now/table/audit_logs", INSTANCE);
        return sendPostRequest(url, auditData, token);
    }

    // Helper methods
    private static String sendPostRequest(String urlString, Map<String, Object> payload, String token) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        if (token != null) {
            conn.setRequestProperty("Authorization", "Bearer " + token);
        }
        conn.setDoOutput(true);

        ObjectMapper mapper = new ObjectMapper();
        String jsonPayload = mapper.writeValueAsString(payload);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonPayload.getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            return response.toString();
        }
    }

    private static String sendGetRequest(String urlString, String token) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + token);

        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            return response.toString();
        }
    }

    private static String sendPutRequest(String urlString, Map<String, Object> payload, String token) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("PUT");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + token);
        conn.setDoOutput(true);

        ObjectMapper mapper = new ObjectMapper();
        String jsonPayload = mapper.writeValueAsString(payload);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonPayload.getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            return response.toString();
        }
    }

    public static void main(String[] args) {
        try {
            String token = loginServiceNow();

            // Example: Query the PONTO system
            String consulta = consultaSistemaPonto(token, "requisicao-id-example");
            System.out.println("PONTO system query: " + consulta);

            // Example: Create a request
            Map<String, Object> requisicaoData = new HashMap<>();
            requisicaoData.put("example_field", "value");
            String requisicao = abrirRequisicao(token, requisicaoData);
            System.out.println("Request created: " + requisicao);

            // Example: Update request status
            Map<String, Object> statusData = new HashMap<>();
            statusData.put("status", "Completed");
            String statusUpdate = atualizarStatusRequisicao(token, "requisicao-id-example", statusData);
            System.out.println("Status updated: " + statusUpdate);

            // Example: Log audit data
            Map<String, Object> auditData = new HashMap<>();
            auditData.put("action", "Request updated");
            auditData.put("details", "The request status was updated to Completed");
            String auditLog = registrarAuditoria(token, auditData);
            System.out.println("Audit log created: " + auditLog);

        } catch (Exception e) {
            System.err.println("Integration flow error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```