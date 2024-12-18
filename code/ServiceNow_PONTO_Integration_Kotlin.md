# ServiceNow and PONTO System Integration Example (Kotlin)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Kotlin**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```kotlin
import java.net.HttpURLConnection
import java.net.URL
import com.fasterxml.jackson.databind.ObjectMapper

const val INSTANCE = "your-instance.service-now.com"
const val CLIENT_ID = "your-client-id"
const val CLIENT_SECRET = "your-client-secret"
const val USERNAME = "your-username"
const val PASSWORD = "your-password"

val objectMapper = ObjectMapper()

// 1. Login to ServiceNow
fun loginServiceNow(): String {
    val url = URL("https://$INSTANCE/oauth_token.do")
    val payload = mapOf(
        "grant_type" to "password",
        "client_id" to CLIENT_ID,
        "client_secret" to CLIENT_SECRET,
        "username" to USERNAME,
        "password" to PASSWORD
    )

    val response = makeHttpRequest(url, "POST", payload)
    return response["access_token"] as String
}

// 2. Query the PONTO System
fun consultaSistemaPonto(token: String, requisicaoId: String): Map<String, Any> {
    val url = URL("https://$INSTANCE/api/now/table/ponto_data?sys_id=$requisicaoId")
    return makeHttpRequest(url, "GET", null, token)
}

// 3. Create a Request in ServiceNow
fun abrirRequisicao(token: String, requisicaoData: Map<String, String>): Map<String, Any> {
    val url = URL("https://$INSTANCE/api/now/table/requisicoes_ponto")
    return makeHttpRequest(url, "POST", requisicaoData, token)
}

// 4. Update Request Status
fun atualizarStatusRequisicao(token: String, requisicaoId: String, statusData: Map<String, String>): Map<String, Any> {
    val url = URL("https://$INSTANCE/api/now/table/requisicoes_ponto?sys_id=$requisicaoId")
    return makeHttpRequest(url, "PUT", statusData, token)
}

// 5. Log Audit Data
fun registrarAuditoria(token: String, auditData: Map<String, String>): Map<String, Any> {
    val url = URL("https://$INSTANCE/api/now/table/audit_logs")
    return makeHttpRequest(url, "POST", auditData, token)
}

// Helper method to make HTTP requests
fun makeHttpRequest(url: URL, method: String, payload: Any? = null, token: String? = null): Map<String, Any> {
    val connection = url.openConnection() as HttpURLConnection
    connection.requestMethod = method
    connection.setRequestProperty("Content-Type", "application/json")
    token?.let {
        connection.setRequestProperty("Authorization", "Bearer $it")
    }

    payload?.let {
        connection.doOutput = true
        val outputStream = connection.outputStream
        outputStream.write(objectMapper.writeValueAsBytes(it))
        outputStream.flush()
        outputStream.close()
    }

    val responseCode = connection.responseCode
    if (responseCode !in 200..299) {
        throw RuntimeException("HTTP Error: $responseCode ${connection.responseMessage}")
    }

    val responseStream = connection.inputStream
    val response = responseStream.bufferedReader().use { it.readText() }
    return objectMapper.readValue(response, Map::class.java) as Map<String, Any>
}

// Execution Flow
fun main() {
    try {
        val token = loginServiceNow()

        // Example: Query the PONTO system
        val consulta = consultaSistemaPonto(token, "requisicao-id-example")
        println("PONTO system query: $consulta")

        // Example: Create a request
        val requisicaoData = mapOf("example_field" to "value")
        val requisicao = abrirRequisicao(token, requisicaoData)
        println("Request created: $requisicao")

        // Example: Update request status
        val statusData = mapOf("status" to "Completed")
        val statusUpdate = atualizarStatusRequisicao(token, "requisicao-id-example", statusData)
        println("Status updated: $statusUpdate")

        // Example: Log audit data
        val auditData = mapOf(
            "action" to "Request updated",
            "details" to "The request status was updated to Completed"
        )
        val auditLog = registrarAuditoria(token, auditData)
        println("Audit log created: $auditLog")

    } catch (e: Exception) {
        println("Integration flow error: ${e.message}")
    }
}
```
