# ServiceNow and PONTO System Integration Example (Python)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Python**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```python
import requests
import json

INSTANCE = "your-instance.service-now.com"
CLIENT_ID = "your-client-id"
CLIENT_SECRET = "your-client-secret"
USERNAME = "your-username"
PASSWORD = "your-password"

# 1. Login to ServiceNow
def login_service_now():
    url = f"https://{INSTANCE}/oauth_token.do"
    payload = {
        "grant_type": "password",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "username": USERNAME,
        "password": PASSWORD,
    }
    response = requests.post(url, data=payload)
    response.raise_for_status()
    return response.json()["access_token"]

# 2. Query the PONTO System
def consulta_sistema_ponto(token, requisicao_id):
    url = f"https://{INSTANCE}/api/now/table/ponto_data?sys_id={requisicao_id}"
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

# 3. Create a Request in ServiceNow
def abrir_requisicao(token, requisicao_data):
    url = f"https://{INSTANCE}/api/now/table/requisicoes_ponto"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    response = requests.post(url, headers=headers, json=requisicao_data)
    response.raise_for_status()
    return response.json()

# 4. Update Request Status
def atualizar_status_requisicao(token, requisicao_id, status_data):
    url = f"https://{INSTANCE}/api/now/table/requisicoes_ponto?sys_id={requisicao_id}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    response = requests.put(url, headers=headers, json=status_data)
    response.raise_for_status()
    return response.json()

# 5. Log Audit Data
def registrar_auditoria(token, audit_data):
    url = f"https://{INSTANCE}/api/now/table/audit_logs"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    response = requests.post(url, headers=headers, json=audit_data)
    response.raise_for_status()
    return response.json()

# Execution Flow
if __name__ == "__main__":
    try:
        token = login_service_now()

        # Example: Query the PONTO system
        consulta = consulta_sistema_ponto(token, "requisicao-id-example")
        print("PONTO system query:", consulta)

        # Example: Create a request
        requisicao_data = {"example_field": "value"}
        requisicao = abrir_requisicao(token, requisicao_data)
        print("Request created:", requisicao)

        # Example: Update request status
        status_data = {"status": "Completed"}
        status_update = atualizar_status_requisicao(token, "requisicao-id-example", status_data)
        print("Status updated:", status_update)

        # Example: Log audit data
        audit_data = {
            "action": "Request updated",
            "details": "The request status was updated to Completed",
        }
        audit_log = registrar_auditoria(token, audit_data)
        print("Audit log created:", audit_log)

    except requests.RequestException as e:
        print("Integration flow error:", e)
```
