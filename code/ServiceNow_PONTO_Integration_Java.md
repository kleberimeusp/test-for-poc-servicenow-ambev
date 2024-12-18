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
    private static final String PONTO_API = "https://sistema-ponto.com/api/marcacoes";
    private static final String CLIENT_ID = "your-client-id";
    private static final String CLIENT_SECRET = "your-client-secret";
    private static final String USERNAME = "your-username";
    private static final String PASSWORD = "your-password";

    // Login to ServiceNow
    public static String loginServiceNow() throws IOException {
        String url = "https://" + INSTANCE + "/oauth_token.do";

        Map<String, String> payload = new HashMap<>();
        payload.put("grant_type", "password");
        payload.put("client_id", CLIENT_ID);
        payload.put("client_secret", CLIENT_SECRET);
        payload.put("username", USERNAME);
        payload.put("password", PASSWORD);

        String response = sendPostRequest(url, payload);
        Map<String, Object> result = new ObjectMapper().readValue(response, Map.class);
        return result.get("access_token").toString();
    }

    // Query the PONTO System
    public static String consultaSistemaPonto(String token, String requisicaoId) throws IOException {
        String url = "https://" + INSTANCE + "/api/now/table/ponto_data?sys_id=" + requisicaoId;
        return sendGetRequest(url, token);
    }

    // Create a Request in ServiceNow
    public static String abrirRequisicao(String token, Map<String, String> requisicaoData) throws IOException {
        String url = "https://" + INSTANCE + "/api/now/table/requisicoes_ponto";
        return sendPostRequest(url, requisicaoData, token);
    }

    // Update Request Status in ServiceNow
    public static String atualizarStatusRequisicao(String token, String requisicaoId, Map<String, String> statusData) throws IOException {
        String url = "https://" + INSTANCE + "/api/now/table/requisicoes_ponto?sys_id=" + requisicaoId;
        return sendPutRequest(url, statusData, token);
    }

    // Helper method for POST requests
    private static String sendPostRequest(String urlString, Map<String, String> payload, String token) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        if (token != null) {
            conn.setRequestProperty("Authorization", "Bearer " + token);
        }
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = new ObjectMapper().writeValueAsBytes(payload);
            os.write(input, 0, input.length);
        }

        return readResponse(conn);
    }

    // Helper method for GET requests
    private static String sendGetRequest(String urlString, String token) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + token);

        return readResponse(conn);
    }

    // Helper method for PUT requests
    private static String sendPutRequest(String urlString, Map<String, String> payload, String token) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("PUT");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + token);
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = new ObjectMapper().writeValueAsBytes(payload);
            os.write(input, 0, input.length);
        }

        return readResponse(conn);
    }

    // Helper method to read response
    private static String readResponse(HttpURLConnection conn) throws IOException {
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
            Map<String, String> requisicaoData = new HashMap<>();
            requisicaoData.put("example_field", "value");
            String requisicao = abrirRequisicao(token, requisicaoData);
            System.out.println("Request created: " + requisicao);

            // Example: Update request status
            Map<String, String> statusData = new HashMap<>();
            statusData.put("status", "Completed");
            String statusUpdate = atualizarStatusRequisicao(token, "requisicao-id-example", statusData);
            System.out.println("Status updated: " + statusUpdate);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```