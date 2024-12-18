# ServiceNow and PONTO System Integration Example (Node.js)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Node.js**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```javascript
const axios = require('axios');

const instance = "your-instance.service-now.com";
const pontoAPI = "https://sistema-ponto.com/api/marcacoes";
const clientId = "your-client-id";
const clientSecret = "your-client-secret";
const username = "your-username";
const password = "your-password";

// 1. Login to ServiceNow
async function loginServiceNow() {
    const url = `https://${instance}/oauth_token.do`;
    const payload = {
        grant_type: "password",
        client_id: clientId,
        client_secret: clientSecret,
        username: username,
        password: password,
    };

    try {
        const response = await axios.post(url, payload);
        return response.data.access_token; // Returns the access token
    } catch (error) {
        console.error("Error logging in: ", error.response?.data || error);
        throw error;
    }
}

// 2. Query the PONTO System
async function consultaSistemaPonto(token, requisicaoId) {
    const url = `https://${instance}/api/now/table/ponto_data?sys_id=${requisicaoId}`;

    try {
        const response = await axios.get(url, {
            headers: { Authorization: `Bearer ${token}` },
        });
        return response.data.result; // Returns queried data
    } catch (error) {
        console.error("Error querying the PONTO system: ", error.response?.data || error);
        throw error;
    }
}

// 3. Create a Request in ServiceNow
async function abrirRequisicao(token, requisicaoData) {
    const url = `https://${instance}/api/now/table/requisicoes_ponto`;

    try {
        const response = await axios.post(url, requisicaoData, {
            headers: { Authorization: `Bearer ${token}` },
        });
        return response.data.result; // Returns details of the created request
    } catch (error) {
        console.error("Error creating request: ", error.response?.data || error);
        throw error;
    }
}

// 4. Update Request Status
async function atualizarStatusRequisicao(token, requisicaoId, statusData) {
    const url = `https://${instance}/api/now/table/requisicoes_ponto?sys_id=${requisicaoId}`;

    try {
        const response = await axios.put(url, statusData, {
            headers: { Authorization: `Bearer ${token}` },
        });
        return response.data.result; // Returns the updated record
    } catch (error) {
        console.error("Error updating request status: ", error.response?.data || error);
        throw error;
    }
}

// 5. Log Audit Data
async function registrarAuditoria(token, auditData) {
    const url = `https://${instance}/api/now/table/audit_logs`;

    try {
        const response = await axios.post(url, auditData, {
            headers: { Authorization: `Bearer ${token}` },
        });
        return response.data.result; // Returns the audit log record
    } catch (error) {
        console.error("Error logging audit data: ", error.response?.data || error);
        throw error;
    }
}

// Execution Flow
(async () => {
    try {
        const token = await loginServiceNow();

        // Example: Query the PONTO system
        const consulta = await consultaSistemaPonto(token, "requisicao-id-example");
        console.log("PONTO system query: ", consulta);

        // Example: Create a request
        const requisicao = await abrirRequisicao(token, {
            example_field: "value",
        });
        console.log("Request created: ", requisicao);

        // Example: Update request status
        const statusUpdate = await atualizarStatusRequisicao(token, "requisicao-id-example", {
            status: "Completed",
        });
        console.log("Status updated: ", statusUpdate);

        // Example: Log audit data
        const auditLog = await registrarAuditoria(token, {
            action: "Request updated",
            details: "The request status was updated to Completed",
        });
        console.log("Audit log created: ", auditLog);
    } catch (error) {
        console.error("Integration flow error: ", error);
    }
})();
```