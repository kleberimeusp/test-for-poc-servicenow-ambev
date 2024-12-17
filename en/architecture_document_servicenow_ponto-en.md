
# Documento de Arquitetura - Integração ServiceNow com Sistema PONTO

## **1. Objetivo**
Este documento apresenta a arquitetura ponta a ponta para a integração entre **ServiceNow** e o **Sistema PONTO**, incluindo as decisões técnicas tomadas e a utilização do modelo **C4** para descrever a solução.

---

## **2. Modelo C4**

### **2.1. Nível 1 - Contexto**
A interação principal é entre **ServiceNow** (plataforma de gestão de solicitações) e o **Sistema PONTO** (legado), onde as marcações de ponto são verificadas, validadas e registradas.

- **ServiceNow**: Plataforma central para automação do fluxo de trabalho.
- **Colaboradores**: Usuários que solicitam a marcação de ponto.
- **Sistema PONTO**: Sistema externo legado que recebe as marcações.

### **2.2. Nível 2 - Contêineres**
- **ServiceNow**:
  - **Flow Designer**: Gerencia o fluxo de automação para consultas e envio ao Sistema PONTO.
  - **Scripted REST API**: Implementa endpoints personalizados para comunicação REST/SOAP.
  - **Database**: Banco de dados nativo do ServiceNow para registros de solicitações e logs.
- **Sistema PONTO**:
  - API REST/SOAP: Interface para consulta e envio de dados de marcação.

- **Ferramenta de Monitoramento (Opcional):**
  - **Performance Analytics** ou integração com **Splunk**/**Datadog** para monitorar status e logs.

### **2.3. Nível 3 - Componentes**
| **Componente**                  | **Função**                                     |
|--------------------------------|-----------------------------------------------|
| **Flow Designer**              | Gerencia os fluxos de consulta e envio.       |
| **Custom Scripts/API**         | Implementação das chamadas REST/SOAP.         |
| **Auditoria e Logs**           | Registra ações e falhas para rastreamento.    |
| **Tabela de Solicitações**     | Armazena as solicitações e seus status.       |
| **Endpoint PONTO API**         | Interface do Sistema PONTO para integração.   |

---

## **3. Fluxo do Processo**

1. **Consulta ao Sistema PONTO**:  
   - ServiceNow realiza uma chamada **GET** para verificar marcações existentes.  
   - A resposta é armazenada na tabela de dados no ServiceNow.

2. **Validação e Abertura da Solicitação**:  
   - O colaborador envia a solicitação de marcação no ServiceNow.  
   - O sistema valida os dados e os armazena.  

3. **Envio ao Sistema PONTO**:  
   - ServiceNow faz uma chamada **POST** com os dados validados para o Sistema PONTO.

4. **Verificação de Status**:  
   - ServiceNow consulta o status usando **GET** ou aguarda callback.  
   - Atualiza a tabela de solicitações com o resultado.

5. **Auditoria e Logs**:  
   - Todas as ações são registradas para fins de auditoria e rastreamento.

---

## **4. Decisões Técnicas**

| **Decisão**                                | **Justificativa**                           |
|-------------------------------------------|-------------------------------------------|
| **REST/SOAP API**                         | Flexibilidade na integração com sistemas legados. |
| **ServiceNow Performance Analytics**      | Monitoramento nativo e integrado.          |
| **Auditoria via Logs**                    | Garantia de rastreamento e resolução rápida. |
| **Fila Assíncrona (Opcional)**            | Evitar sobrecarga em picos de requisições. |

---

## **5. Ferramentas Utilizadas**

- **ServiceNow**: Principal plataforma de gestão e automação.  
- **Sistema PONTO**: Sistema legado com API de integração.  
- **Ferramenta de Monitoramento**:  
  - **Performance Analytics** (nativo) ou integração com **Splunk**/**Datadog**.  
- **Mock API** (opcional): Uso do **Postman** ou **JSON Server** para simular PONTO API.  

---

## **6. Conclusão**
Este documento detalha a arquitetura ponta a ponta, utilizando o modelo C4 para descrever a solução em camadas. As decisões técnicas foram tomadas com foco em robustez, escalabilidade e rastreabilidade para garantir uma integração eficiente entre ServiceNow e o sistema legado PONTO.
