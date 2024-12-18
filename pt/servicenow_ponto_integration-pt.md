
# Integração ServiceNow com Sistema PONTO

## Descrição do Processo
O processo de integração entre **ServiceNow** e o sistema **PONTO** para gerenciar solicitações de marcação de ponto envolve:
1. **Consulta ao Sistema PONTO**: Validação de marcações existentes antes de abrir uma nova requisição.
2. **Abertura de Requisição no ServiceNow**: Solicitação de marcação de ponto validada e registrada.
3. **Envio Automático ao Sistema PONTO**: Integração para envio de dados de marcação.
4. **Atualização de Status**: Validação no sistema PONTO e atualização do status no ServiceNow.
5. **Auditoria e Logs**: Rastreabilidade detalhada das ações e falhas.

---

## 1. Consulta ao Sistema PONTO

### Scripted REST API: Consultar Marcações
- **Endpoint**: `/api/custom/ponto_api/consult-clockin`
- **Método**: `GET`

### Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var employeeId = request.queryParams.employeeId;
        if (!employeeId) {
            response.setStatus(400);
            response.setBody({ error: "Missing parameter: employeeId" });
            return;
        }

        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('GET');
        client.setEndpoint('https://legacy.ponto-system.com/api/clock-in?employeeId=' + employeeId);

        var result = client.execute();
        var statusCode = result.getStatusCode();
        var responseBodyRaw = result.getBody();

        if (statusCode == 200) {
            responseBody = JSON.parse(responseBodyRaw);
            response.setStatus(200);
        } else {
            responseBody.error = "Failed to fetch data.";
            responseBody.details = responseBodyRaw;
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.error = "Error: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Envio Automático ao Sistema PONTO

### Scripted REST API: Enviar Marcações
- **Endpoint**: `/api/custom/ponto_api/send-clockin`
- **Método**: `POST`

### Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var requestBody = request.body.data;

        if (!requestBody.employeeId || !requestBody.clockInTime) {
            response.setStatus(400);
            response.setBody({ error: "Missing fields: employeeId or clockInTime" });
            return;
        }

        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('POST');
        client.setEndpoint('https://legacy.ponto-system.com/api/clock-in');
        client.setRequestHeader('Content-Type', 'application/json');
        client.setRequestBody(JSON.stringify(requestBody));

        var result = client.execute();
        var statusCode = result.getStatusCode();

        if (statusCode == 200) {
            responseBody.message = "Clock-in successfully submitted.";
            response.setStatus(200);
        } else {
            responseBody.error = "Failed to send clock-in data.";
            responseBody.details = result.getBody();
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.error = "Error: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 3. Tabelas Requeridas

### Request Table (`u_request_table`)
| Campo           | Tipo        | Descrição                    |
|-----------------|-------------|------------------------------|
| u_request_id    | String      | ID da solicitação            |
| u_employee_id   | String      | Identificação do colaborador |
| u_clockin_time  | DateTime    | Horário da marcação          |
| u_status        | String      | Status da requisição         |

### Auditing Logs (`u_auditing_logs`)
| Campo           | Tipo        | Descrição                    |
|-----------------|-------------|------------------------------|
| u_action        | String      | Ação realizada               |
| u_employee_id   | String      | Identificação do colaborador |
| u_details       | String      | Detalhes do resultado        |
| u_timestamp     | DateTime    | Data e hora da ação          |

---

## 4. Fluxo no Flow Designer

### Passos do Workflow:
1. **Trigger**: Submissão manual ou evento.
2. **Step 1**: Chama a API `consult-clockin` para validar marcações existentes.
3. **Step 2**: Se a validação for aprovada, cria um registro na **Request Table**.
4. **Step 3**: Chama a API `send-clockin` para enviar os dados ao sistema PONTO.
5. **Step 4**: Consulta novamente o status e atualiza o registro.
6. **Step 5**: Registra logs de sucesso ou falha na **Auditing Logs**.

---

## 5. Tratamento de Erros e Auditoria

### Tratamento de Erros:
- Validação de parâmetros obrigatórios.
- Registro de falhas ao consultar ou enviar dados.
- Implementação de status `Erro` no registro, caso a operação falhe.

### Auditoria e Logs:
- Cada ação é registrada na tabela **Auditing Logs** para rastreabilidade.
- Detalhes de erros são armazenados para análise.

---

## Resumo do Processo
1. **Consulta Inicial**: Verificação no sistema PONTO.
2. **Solicitação**: Registro validado no ServiceNow.
3. **Envio**: Integração com sistema legado via API.
4. **Atualização**: Status atualizado e logs registrados.
5. **Auditoria**: Rastreabilidade completa das ações.

---

**End of Document**
