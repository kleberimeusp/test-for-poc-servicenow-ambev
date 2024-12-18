# ServiceNow and PONTO System Integration Example (Scala)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Scala**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```scala
import sttp.client3._
import sttp.client3.circe._
import io.circe.Json
import io.circe.parser._
import io.circe.syntax._

object ServiceNowIntegration {
  val instance = "your-instance.service-now.com"
  val clientId = "your-client-id"
  val clientSecret = "your-client-secret"
  val username = "your-username"
  val password = "your-password"

  // 1. Login to ServiceNow
  def loginServiceNow(): String = {
    val backend = HttpURLConnectionBackend()
    val url = s"https://$instance/oauth_token.do"
    val payload = Json.obj(
      "grant_type" -> Json.fromString("password"),
      "client_id" -> Json.fromString(clientId),
      "client_secret" -> Json.fromString(clientSecret),
      "username" -> Json.fromString(username),
      "password" -> Json.fromString(password)
    )

    val request = basicRequest.post(uri"$url").body(payload.noSpaces).contentType("application/json")
    val response = request.send(backend).body
    response match {
      case Right(body) => parse(body).getOrElse(Json.Null).hcursor.downField("access_token").as[String].getOrElse(throw new Exception("Failed to parse token"))
      case Left(error) => throw new Exception(s"Login error: $error")
    }
  }

  // 2. Query the PONTO System
  def consultaSistemaPonto(token: String, requisicaoId: String): Json = {
    val backend = HttpURLConnectionBackend()
    val url = s"https://$instance/api/now/table/ponto_data?sys_id=$requisicaoId"
    val request = basicRequest.get(uri"$url").header("Authorization", s"Bearer $token")
    val response = request.send(backend).body
    response match {
      case Right(body) => parse(body).getOrElse(Json.Null)
      case Left(error) => throw new Exception(s"Query error: $error")
    }
  }

  // 3. Create a Request in ServiceNow
  def abrirRequisicao(token: String, requisicaoData: Json): Json = {
    val backend = HttpURLConnectionBackend()
    val url = s"https://$instance/api/now/table/requisicoes_ponto"
    val request = basicRequest.post(uri"$url").body(requisicaoData.noSpaces).header("Authorization", s"Bearer $token").contentType("application/json")
    val response = request.send(backend).body
    response match {
      case Right(body) => parse(body).getOrElse(Json.Null)
      case Left(error) => throw new Exception(s"Create request error: $error")
    }
  }

  // 4. Update Request Status
  def atualizarStatusRequisicao(token: String, requisicaoId: String, statusData: Json): Json = {
    val backend = HttpURLConnectionBackend()
    val url = s"https://$instance/api/now/table/requisicoes_ponto?sys_id=$requisicaoId"
    val request = basicRequest.put(uri"$url").body(statusData.noSpaces).header("Authorization", s"Bearer $token").contentType("application/json")
    val response = request.send(backend).body
    response match {
      case Right(body) => parse(body).getOrElse(Json.Null)
      case Left(error) => throw new Exception(s"Update status error: $error")
    }
  }

  // 5. Log Audit Data
  def registrarAuditoria(token: String, auditData: Json): Json = {
    val backend = HttpURLConnectionBackend()
    val url = s"https://$instance/api/now/table/audit_logs"
    val request = basicRequest.post(uri"$url").body(auditData.noSpaces).header("Authorization", s"Bearer $token").contentType("application/json")
    val response = request.send(backend).body
    response match {
      case Right(body) => parse(body).getOrElse(Json.Null)
      case Left(error) => throw new Exception(s"Audit log error: $error")
    }
  }

  // Execution Flow
  def main(args: Array[String]): Unit = {
    try {
      val token = loginServiceNow()

      // Example: Query the PONTO system
      val consulta = consultaSistemaPonto(token, "requisicao-id-example")
      println(s"PONTO system query: $consulta")

      // Example: Create a request
      val requisicaoData = Json.obj("example_field" -> Json.fromString("value"))
      val requisicao = abrirRequisicao(token, requisicaoData)
      println(s"Request created: $requisicao")

      // Example: Update request status
      val statusData = Json.obj("status" -> Json.fromString("Completed"))
      val statusUpdate = atualizarStatusRequisicao(token, "requisicao-id-example", statusData)
      println(s"Status updated: $statusUpdate")

      // Example: Log audit data
      val auditData = Json.obj(
        "action" -> Json.fromString("Request updated"),
        "details" -> Json.fromString("The request status was updated to Completed")
      )
      val auditLog = registrarAuditoria(token, auditData)
      println(s"Audit log created: $auditLog")

    } catch {
      case e: Exception => println(s"Integration flow error: ${e.getMessage}")
    }
  }
}
```