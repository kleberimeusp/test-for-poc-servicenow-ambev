
# Implementação da API do ServiceNow

## 1. Scripted REST API
A API Scripted REST implementa endpoints personalizados para comunicação REST/SOAP.

### Etapas de Criação:
1. Navegue para: **System Web Services > Scripted REST APIs**.
2. Clique em **New** para criar uma nova API personalizada.
3. **Campos Básicos**:
   - **Nome**: `PontoSystemAPI`
   - **ID da API**: `ponto_system_api`
   - **Namespace**: `custom`

4. **Adicione um Recurso**:
   - **Nome**: `sendClockInData`
   - **Método HTTP**: `POST`
   - **Caminho Relativo**: `/clock-in`

### Script do Endpoint REST:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var clockInData = request.body.data; // Recebe os dados do corpo

        // Constrói uma requisição para o sistema legado
        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('POST');
        client.setEndpoint('https://legacy.ponto-system.com/clock-in');
        client.setRequestHeader('Content-Type', 'application/json');
        client.setRequestBody(JSON.stringify(clockInData));

        var result = client.execute();
        var httpResponseCode = result.getStatusCode();

        // Manipula a resposta
        if (httpResponseCode == 200) {
            responseBody.message = "Dados de marcação enviados com sucesso.";
            response.setStatus(200);
        } else {
            responseBody.message = "Erro ao enviar os dados de marcação.";
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.message = "Ocorreu uma exceção: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Flow Designer
O Flow Designer orquestra a automação para envio de dados ao **Sistema PONTO**.

### Etapas para Criar o Fluxo:
1. Navegue para **Flow Designer**.
2. Clique em **New Flow**:
   - **Nome**: `Submit Clock-In Data`

3. **Disparadores**:
   - **Trigger Manual** ou baseado em evento (ex.: "Registro Inserido").

4. **Etapas**:
   - **Etapa 1**: Chamar a API Scripted REST.
     - Use o **REST Step** para fazer uma chamada `POST`.
     - **URL**: `/api/custom/ponto_system_api/clock-in`
     - **Body**: Inclua o payload de dados da marcação.

5. **Registrar Resultados** no Banco de Dados:
   - Use o **Create Record** para registrar os resultados na tabela do banco de dados.

---

## 3. Banco de Dados (Logs e Registros)
Uma tabela nativa do ServiceNow para armazenar logs e dados processados.

### Criação da Tabela:
1. Navegue para **System Definition > Tables**.
2. Crie uma nova tabela:
   - **Nome**: `Ponto_ClockIn_Logs`
   - Adicione os campos:
     - **Clock-In Data**: String
     - **Status**: String
     - **Timestamp**: Data/Hora

3. No Flow Designer:
   - Use o **Create Record** para registrar os dados.

---

## Resumo do Fluxo de Trabalho:
- O **Flow Designer** aciona e orquestra o fluxo de dados.
- A **API Scripted REST** lida com a comunicação com o sistema PONTO.
- O **Banco de Dados** armazena os logs e resultados para referência futura.

---

**Fim do Documento**
