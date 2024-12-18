
# Implementação da API do ServiceNow para Fluxo de Trabalho de Registro de Ponto

## 1. Scripted REST API
Esta API gerencia o envio de marcações de ponto de funcionários e as envia para o sistema PONTO.

### Etapas de Criação:
1. Navegue para **System Web Services > Scripted REST APIs** no ServiceNow.
2. Clique em **New** para criar uma API personalizada.
3. **Campos Básicos**:
   - **Nome**: `EmployeeClockInAPI`
   - **ID da API**: `employee_clockin_api`
   - **Namespace**: `custom`

### Recurso do Endpoint
- **Caminho Relativo**: `/submit-clock-in`
- **Método HTTP**: `POST`

### Script da API REST:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        // Obtém os dados da requisição
        var requestBody = request.body.data;
        var employeeId = requestBody.employeeId;
        var clockInTime = requestBody.clockInTime;

        // Valida os dados
        if (!employeeId || !clockInTime) {
            response.setStatus(400); // Requisição Inválida
            response.setBody({ error: "Faltando employeeId ou clockInTime" });
            return;
        }

        // Cria uma requisição para o sistema legado PONTO
        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('POST');
        client.setEndpoint('https://legacy.ponto-system.com/api/clock-in');
        client.setRequestHeader('Content-Type', 'application/json');

        // Constrói o payload para o sistema PONTO
        var payload = {
            employeeId: employeeId,
            clockInTime: clockInTime
        };
        client.setRequestBody(JSON.stringify(payload));

        // Executa a requisição
        var result = client.execute();
        var httpResponseCode = result.getStatusCode();
        var httpResponseBody = result.getBody();

        // Manipula a resposta
        if (httpResponseCode == 200) {
            responseBody.status = "Sucesso";
            responseBody.message = "Dados de marcação enviados com sucesso.";
            response.setStatus(200);
        } else {
            responseBody.status = "Erro";
            responseBody.message = "Falha ao enviar os dados de marcação.";
            responseBody.details = httpResponseBody;
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.status = "Exceção";
        responseBody.message = error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Fluxo de Trabalho no Flow Designer
O **Flow Designer** orquestra o envio dos dados de marcação de ponto.

### Etapas para Criar o Fluxo:
1. Navegue para **Flow Designer**.
2. Crie um novo fluxo:
   - **Nome**: `Submit Employee Clock-In`

3. **Disparadores**:
   - Disparador manual ou evento baseado em registro (ex.: registro de funcionário atualizado).

4. **Etapas**:
   - **Etapa 1**: Chama a API Scripted REST `/submit-clock-in` usando o método POST.
   - **Etapa 2**: Captura a resposta da API.
   - **Etapa 3**: Registra a resposta em uma tabela do banco de dados.

---

## 3. Banco de Dados (Logs e Registros)
Crie uma tabela no ServiceNow para armazenar os logs das marcações de ponto.

### Configuração da Tabela:
- **Nome**: `ClockIn_Logs`
- **Campos**:
  - **ID do Funcionário**: String
  - **Hora da Marcação**: Data/Hora
  - **Status**: String (Sucesso/Erro)
  - **Detalhes da Resposta**: String

### Fluxo de Registro:
- Use uma ação **Create Record** no Flow Designer para registrar os resultados da chamada da API.

---

## Resumo do Fluxo de Trabalho
1. Os funcionários enviam os dados de marcação para o ServiceNow.
2. O ServiceNow valida e encaminha os dados para o sistema PONTO via uma API Scripted REST.
3. A resposta da API é armazenada em uma tabela dedicada para registro e relatórios.

---

**Fim do Documento**
