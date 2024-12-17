
# Implementação e Demonstração Opcional

## **Sobre a Implementação**
A implementação é opcional e pode ser realizada caso haja tempo e ambiente adequado para execução.

### **Objetivo**
Preparar uma **demonstração prática** para ilustrar a solução proposta, incluindo:  
1. **Emulação do sistema legado** para simular o comportamento do **PONTO**.  
2. Desenvolvimento de **scripts e endpoints** básicos no **ServiceNow**.  
3. Garantir um ambiente demonstrável para análise de código e solução.  

---

## **2. Mock do Sistema Legado**
Caso o sistema legado **PONTO** não esteja disponível, a implementação deve incluir um **mock** para emular suas funcionalidades:

### **Ferramentas Recomendadas**  
- **Postman Mock Server**: Para criar APIs simuladas com respostas configuráveis.  
- **JSON Server**: Uma alternativa leve e rápida para emular APIs RESTful.  

### **Endpoints Mockados**  
Simule os seguintes endpoints com os dados necessários:
1. `GET /ponto/marcacoes`  
   - Retorna registros de marcações existentes.  
   - Exemplo de resposta:
     ```json
     [
       {"id": 1, "colaborador": "João", "data": "2024-06-10", "hora": "08:00"},
       {"id": 2, "colaborador": "Maria", "data": "2024-06-10", "hora": "08:15"}
     ]
     ```  

2. `POST /ponto/marcar`  
   - Recebe uma nova marcação de ponto e retorna sucesso ou erro.  
   - Exemplo de envio:
     ```json
     {"colaborador": "João", "data": "2024-06-10", "hora": "08:00"}
     ```  
   - Resposta de sucesso:
     ```json
     {"status": "success", "message": "Marcação registrada com sucesso."}
     ```  

3. `GET /ponto/status/{id}`  
   - Retorna o status do processamento de uma solicitação.  
   - Exemplo de resposta:
     ```json
     {"id": 1, "status": "completed", "message": "Marcação registrada no sistema."}
     ```  

---

## **3. Demonstração no Dia da Entrevista**
### **Pontos de Foco:**
1. **Apresentação da Solução**:  
   - Explicação do fluxo de integração entre ServiceNow e o sistema legado (mockado).  
   - Demonstração do código implementado, incluindo chamadas REST/SOAP.  

2. **Código e Arquitetura**:  
   - Apresentar os scripts desenvolvidos no **ServiceNow** (ex.: Flow Designer, Scripted REST APIs).  
   - Justificar decisões técnicas como uso de **REST API**, logs e auditoria.  

3. **Execução da Integração**:  
   - Testar as funcionalidades simuladas em um ambiente local (mock API).  
   - Mostrar logs e respostas da integração.  

---

## **4. Discussão Técnica**
Durante a entrevista, será discutido:  
1. **Código e Implementação**: Compreender a lógica adotada e os desafios enfrentados.  
2. **Soluções Adotadas**: Justificativas para as decisões técnicas tomadas.  
3. **Experiência com Tecnologias**: Apresentação da experiência prática com:  
   - **ServiceNow**  
   - **Integrações REST/SOAP**  
   - **Mocking APIs**  
   - **Ferramentas de Monitoramento**  

---

## **5. Conclusão**
Essa implementação opcional oferece uma demonstração prática da solução integrada, permitindo:  
- Validação da abordagem proposta.  
- Compreensão das decisões técnicas.  
- Exibição das habilidades nas tecnologias envolvidas.

A solução implementada poderá ser apresentada e discutida no dia da entrevista para avaliar sua robustez, escalabilidade e eficiência.
