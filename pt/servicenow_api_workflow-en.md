
# Implementação do Fluxo de Trabalho da API do ServiceNow

## 1. Scripted REST API

### Detalhes da API:
- **Nome**: `RequestStatusAPI`
- **ID da API**: `request_status_api`
- **Namespace**: `custom`

### Recurso do Endpoint:
- **Caminho**: `/submit-request`
- **Método**: `POST`

### Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var requestBody = request.body.data;
        var requestId = requestBody.requestId;
        var requestStatus = requestBody.status;

        // Validação
        if (!requestId || !requestStatus) {
            response.setStatus(400);
            response.setBody({ error: "Faltando requestId ou status" });
            return;
        }

        // Atualizar Tabela de Solicitações
        var gr = new GlideRecord('u_request_table');
        gr.addQuery('u_request_id', requestId);
        gr.query();

        if (gr.next()) {
            gr.u_status = requestStatus; // Atualiza o status
            gr.update();

            // Registra a ação
            var logGr = new GlideRecord('u_auditing_logs');
            logGr.initialize();
            logGr.u_action = 'Status Atualizado';
            logGr.u_request_id = requestId;
            logGr.u_status = requestStatus;
            logGr.insert();

            responseBody.message = "Status da solicitação atualizado com sucesso.";
            response.setStatus(200);
        } else {
            responseBody.error = "ID da solicitação não encontrado.";
            response.setStatus(404);
        }
    } catch (error) {
        responseBody.error = "Ocorreu um erro: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Fluxo de Trabalho no Flow Designer

### Etapas:
1. **Disparador**: Registro criado/atualizado na tabela `Request Table`.
2. **Etapa 1**: Chama a API Scripted REST `submit-request`.
   - **Endpoint**: `/api/custom/request_status_api/submit-request`
   - **Payload**:
   ```json
   {
       "requestId": "12345",
       "status": "Processing"
   }
   ```
3. **Etapa 2**: Valida a resposta da API.
4. **Etapa 3**: Registra a ação nos **Logs de Auditoria**.

---

## 3. Tabelas Necessárias

### Tabela de Solicitações (`u_request_table`):
| Nome do Campo   | Tipo    | Descrição                   |
|-----------------|---------|-----------------------------|
| u_request_id    | String  | ID único da solicitação     |
| u_status        | String  | Status da solicitação       |

### Logs de Auditoria (`u_auditing_logs`):
| Nome do Campo   | Tipo        | Descrição                   |
|-----------------|-------------|-----------------------------|
| u_action        | String      | Ação realizada              |
| u_request_id    | String      | ID da solicitação relacionada|
| u_status        | String      | Status após atualização      |
| u_timestamp     | DateTime    | Timestamp gerado automaticamente|

---

## 4. Resumo do Fluxo de Trabalho
1. As solicitações são armazenadas na **Tabela de Solicitações**.
2. O Flow Designer aciona a **API Customizada** para processar a solicitação e atualizar o status.
3. Ações e falhas são registradas na tabela de **Logs de Auditoria** para rastreabilidade.

---

**Fim do Documento**
