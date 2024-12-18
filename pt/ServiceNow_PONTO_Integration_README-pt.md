
# Integração do ServiceNow com o Sistema PONTO

## Visão Geral
Este documento descreve a configuração e os detalhes de implementação para integrar o ServiceNow ao sistema PONTO. Inclui a configuração para os ambientes de **desenvolvimento**, **homologação** e **produção**, juntamente com diretrizes para o uso de dados mock no desenvolvimento.

---

## 1. Separação de Ambientes

### 1.1 Ambientes Definidos
- **Desenvolvimento**: 
  - Utiliza dados mock para testes.
  - Garante que não haverá impacto em sistemas reais.
- **Homologação**:
  - Valida a integração com dados reais controlados.
- **Produção**:
  - Integração completa com o sistema PONTO em produção.

### 1.2 Configuração de Ambiente no ServiceNow
- Use `sys_properties` para definir configurações específicas para cada ambiente:
  - `integration.url.ponto.dev`: URL do ambiente de desenvolvimento (mockado).
  - `integration.url.ponto.hml`: URL do ambiente de homologação.
  - `integration.url.ponto.prd`: URL do ambiente de produção.

- **Variáveis no Flow Designer**:
  Defina URLs dinâmicas com base no ambiente:
  ```json
  {
    "env": "dev", 
    "base_url": "https://mock-api.ponto.dev"
  }
  ```

---

## 2. Configuração de Dados Mock

### 2.1 Configuração do Mock API
Mocks simulam o comportamento do sistema PONTO no ambiente de desenvolvimento:
- **Endpoint Mock: Enviar Dados**
  - URL: `/api/custom/ponto/send`
  - Resposta:
    ```json
    {
      "status": "success",
      "message": "Mock: Data sent successfully"
    }
    ```

- **Endpoint Mock: Verificar Status**
  - URL: `/api/custom/ponto/status`
  - Resposta:
    ```json
    {
      "status": "success",
      "integration_status": "completed",
      "last_sync": "2024-12-17T20:00:00"
    }
    ```

---

## 3. Configuração de Workflows

### 3.1 Configuração do Flow Designer
Passos para os workflows no ServiceNow:
1. **Autenticação**: Obtenha um token usando OAuth 2.0.
2. **Enviar Dados**: Envie os dados ao sistema PONTO (mock ou real).
3. **Verificar Status**: Confirme o status da integração.
4. **Recuperar Logs**: Obtenha logs de erro ou auditoria.

Atribuição dinâmica de URL com base no ambiente:
```javascript
if (env === "dev") {
    base_url = "https://mock-api.ponto.dev";
} else if (env === "hml") {
    base_url = "https://api-hml.ponto.com";
} else {
    base_url = "https://api.ponto.com";
}
```

---

## 4. Monitoramento e Escalabilidade

### 4.1 Monitoramento
- **Desenvolvimento**:
  - Ative logs detalhados para depuração.
- **Homologação**:
  - Configure alertas para falhas de integração.
- **Produção**:
  - Monitore em tempo real usando o **Event Management** do ServiceNow.

### 4.2 Escalabilidade
- **Limitação de Taxa**: Controle requisições simultâneas.
- **Caching**: Reduza chamadas redundantes.
- **Balanceamento de Carga**: Suporte para altos volumes de tráfego.

---

## 5. Exemplos de Chamadas de API

### Autenticação
**Endpoint**: `/oauth_token.do`  
**Método**: `POST`  
**Requisição**:
```json
{
  "grant_type": "password",
  "client_id": "<CLIENT_ID>",
  "client_secret": "<CLIENT_SECRET>",
  "username": "<USERNAME>",
  "password": "<PASSWORD>"
}
```

---

### Enviar Dados
**Endpoint**: `/api/custom/ponto/send`  
**Método**: `POST`  
**Requisição**:
```json
{
  "user_id": "12345",
  "check_in": "2024-12-17T09:00:00",
  "check_out": "2024-12-17T18:00:00"
}
```

---

### Recuperar Logs
**Endpoint**: `/api/custom/ponto/logs`  
**Método**: `GET`  
**Resposta**:
```json
{
  "logs": [
    {
      "timestamp": "2024-12-17T09:00:00",
      "event": "Mock: Check-in processed",
      "status": "success"
    }
  ]
}
```

---

## 6. Documentação

- **Checklist para Ambientes**:
  - URLs e credenciais.
  - sys_properties para configurações específicas do ambiente.
- **Guia de Testes**:
  - Incluir cenários para cada ambiente.
  - Comparar respostas mockadas e reais.

---

## 7. Licença
Esta configuração de integração está licenciada sob a empresa XPTO.
