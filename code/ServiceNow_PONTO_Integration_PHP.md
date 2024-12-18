# ServiceNow and PONTO System Integration Example (PHP)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **PHP**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```php
<?php

$instance = "your-instance.service-now.com";
$clientId = "your-client-id";
$clientSecret = "your-client-secret";
$username = "your-username";
$password = "your-password";

// 1. Login to ServiceNow
function loginServiceNow() {
    global $instance, $clientId, $clientSecret, $username, $password;

    $url = "https://" . $instance . "/oauth_token.do";
    $payload = [
        "grant_type" => "password",
        "client_id" => $clientId,
        "client_secret" => $clientSecret,
        "username" => $username,
        "password" => $password,
    ];

    $response = makeHttpRequest($url, "POST", $payload);
    return $response["access_token"];
}

// 2. Query the PONTO System
function consultaSistemaPonto($token, $requisicaoId) {
    global $instance;

    $url = "https://" . $instance . "/api/now/table/ponto_data?sys_id=" . $requisicaoId;
    return makeHttpRequest($url, "GET", null, $token);
}

// 3. Create a Request in ServiceNow
function abrirRequisicao($token, $requisicaoData) {
    global $instance;

    $url = "https://" . $instance . "/api/now/table/requisicoes_ponto";
    return makeHttpRequest($url, "POST", $requisicaoData, $token);
}

// 4. Update Request Status
function atualizarStatusRequisicao($token, $requisicaoId, $statusData) {
    global $instance;

    $url = "https://" . $instance . "/api/now/table/requisicoes_ponto?sys_id=" . $requisicaoId;
    return makeHttpRequest($url, "PUT", $statusData, $token);
}

// 5. Log Audit Data
function registrarAuditoria($token, $auditData) {
    global $instance;

    $url = "https://" . $instance . "/api/now/table/audit_logs";
    return makeHttpRequest($url, "POST", $auditData, $token);
}

// Helper function to make HTTP requests
function makeHttpRequest($url, $method, $data = null, $token = null) {
    $ch = curl_init();

    $headers = ["Content-Type: application/json"];
    if ($token) {
        $headers[] = "Authorization: Bearer " . $token;
    }

    $options = [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_HTTPHEADER => $headers,
    ];

    if ($data) {
        $options[CURLOPT_POSTFIELDS] = json_encode($data);
    }

    curl_setopt_array($ch, $options);
    $response = curl_exec($ch);

    if (curl_errno($ch)) {
        throw new Exception("Request error: " . curl_error($ch));
    }

    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    if ($httpCode >= 400) {
        throw new Exception("HTTP error code: " . $httpCode . " Response: " . $response);
    }

    curl_close($ch);
    return json_decode($response, true);
}

// Execution Flow
try {
    $token = loginServiceNow();

    // Example: Query the PONTO system
    $consulta = consultaSistemaPonto($token, "requisicao-id-example");
    echo "PONTO system query: ", json_encode($consulta), "\n";

    // Example: Create a request
    $requisicaoData = ["example_field" => "value"];
    $requisicao = abrirRequisicao($token, $requisicaoData);
    echo "Request created: ", json_encode($requisicao), "\n";

    // Example: Update request status
    $statusData = ["status" => "Completed"];
    $statusUpdate = atualizarStatusRequisicao($token, "requisicao-id-example", $statusData);
    echo "Status updated: ", json_encode($statusUpdate), "\n";

    // Example: Log audit data
    $auditData = [
        "action" => "Request updated",
        "details" => "The request status was updated to Completed",
    ];
    $auditLog = registrarAuditoria($token, $auditData);
    echo "Audit log created: ", json_encode($auditLog), "\n";

} catch (Exception $e) {
    echo "Integration flow error: ", $e->getMessage(), "\n";
}

?>
```