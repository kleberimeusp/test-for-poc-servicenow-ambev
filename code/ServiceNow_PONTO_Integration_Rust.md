# ServiceNow and PONTO System Integration Example (Rust)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Rust**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```rust
use reqwest::blocking::{Client, Response};
use serde_json::{json, Value};
use std::error::Error;

const INSTANCE: &str = "your-instance.service-now.com";
const CLIENT_ID: &str = "your-client-id";
const CLIENT_SECRET: &str = "your-client-secret";
const USERNAME: &str = "your-username";
const PASSWORD: &str = "your-password";

// 1. Login to ServiceNow
fn login_service_now() -> Result<String, Box<dyn Error>> {
    let client = Client::new();
    let url = format!("https://{}/oauth_token.do", INSTANCE);
    let payload = json!({
        "grant_type": "password",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "username": USERNAME,
        "password": PASSWORD
    });

    let response: Value = client.post(&url).json(&payload).send()?.json()?;
    Ok(response["access_token"].as_str().unwrap().to_string())
}

// 2. Query the PONTO System
fn consulta_sistema_ponto(token: &str, requisicao_id: &str) -> Result<Value, Box<dyn Error>> {
    let client = Client::new();
    let url = format!("https://{}/api/now/table/ponto_data?sys_id={}", INSTANCE, requisicao_id);

    let response: Value = client
        .get(&url)
        .bearer_auth(token)
        .send()?
        .json()?;

    Ok(response)
}

// 3. Create a Request in ServiceNow
fn abrir_requisicao(token: &str, requisicao_data: Value) -> Result<Value, Box<dyn Error>> {
    let client = Client::new();
    let url = format!("https://{}/api/now/table/requisicoes_ponto", INSTANCE);

    let response: Value = client
        .post(&url)
        .bearer_auth(token)
        .json(&requisicao_data)
        .send()?
        .json()?;

    Ok(response)
}

// 4. Update Request Status
fn atualizar_status_requisicao(token: &str, requisicao_id: &str, status_data: Value) -> Result<Value, Box<dyn Error>> {
    let client = Client::new();
    let url = format!("https://{}/api/now/table/requisicoes_ponto?sys_id={}", INSTANCE, requisicao_id);

    let response: Value = client
        .put(&url)
        .bearer_auth(token)
        .json(&status_data)
        .send()?
        .json()?;

    Ok(response)
}

// 5. Log Audit Data
fn registrar_auditoria(token: &str, audit_data: Value) -> Result<Value, Box<dyn Error>> {
    let client = Client::new();
    let url = format!("https://{}/api/now/table/audit_logs", INSTANCE);

    let response: Value = client
        .post(&url)
        .bearer_auth(token)
        .json(&audit_data)
        .send()?
        .json()?;

    Ok(response)
}

// Execution Flow
fn main() -> Result<(), Box<dyn Error>> {
    let token = login_service_now()?;

    // Example: Query the PONTO system
    let consulta = consulta_sistema_ponto(&token, "requisicao-id-example")?;
    println!("PONTO system query: {}", consulta);

    // Example: Create a request
    let requisicao_data = json!({"example_field": "value"});
    let requisicao = abrir_requisicao(&token, requisicao_data)?;
    println!("Request created: {}", requisicao);

    // Example: Update request status
    let status_data = json!({"status": "Completed"});
    let status_update = atualizar_status_requisicao(&token, "requisicao-id-example", status_data)?;
    println!("Status updated: {}", status_update);

    // Example: Log audit data
    let audit_data = json!({
        "action": "Request updated",
        "details": "The request status was updated to Completed"
    });
    let audit_log = registrar_auditoria(&token, audit_data)?;
    println!("Audit log created: {}", audit_log);

    Ok(())
}
```
