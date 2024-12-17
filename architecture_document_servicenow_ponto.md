
# Architecture Document - ServiceNow Integration with PONTO System

## **1. Objective**
This document presents the end-to-end architecture for the integration between **ServiceNow** and the **PONTO System**, including the technical decisions taken and the use of the **C4 model** to describe the solution.

---

## **2. C4 Model**

### **2.1. Level 1 - Context**
The main interaction is between **ServiceNow** (request management platform) and the **PONTO System** (legacy), where clock-in records are checked, validated, and submitted.

- **ServiceNow**: Central platform for workflow automation.
- **Employees**: Users who request clock-in registrations.
- **PONTO System**: External legacy system that receives the clock-in submissions.

### **2.2. Level 2 - Containers**
- **ServiceNow**:
  - **Flow Designer**: Manages the automation flow for queries and submissions to the PONTO system.
  - **Scripted REST API**: Implements custom endpoints for REST/SOAP communication.
  - **Database**: ServiceNow’s native database for request logs and records.
- **PONTO System**:
  - REST/SOAP API: Interface for querying and submitting clock-in data.

- **Monitoring Tool (Optional):**
  - **Performance Analytics** or integration with **Splunk**/**Datadog** for status and log monitoring.

### **2.3. Level 3 - Components**
| **Component**                | **Function**                                  |
|------------------------------|-----------------------------------------------|
| **Flow Designer**            | Manages workflows for querying and submissions.|
| **Custom Scripts/API**       | Implements REST/SOAP calls.                   |
| **Auditing and Logs**        | Tracks actions and failures for traceability. |
| **Request Table**            | Stores requests and their statuses.           |
| **PONTO API Endpoint**       | Interface for the PONTO system.               |

---

## **3. Process Flow**

1. **PONTO System Query**:  
   - ServiceNow performs a **GET call** to check existing clock-ins.  
   - The response is stored in ServiceNow’s database.

2. **Request Validation and Submission**:  
   - The employee submits a clock-in request through ServiceNow.  
   - ServiceNow validates and stores the data.

3. **Submission to PONTO System**:  
   - ServiceNow performs a **POST call** with the validated data to the PONTO System.

4. **Status Verification**:  
   - ServiceNow queries the status using **GET** or waits for a callback.  
   - Updates the request table with the result.

5. **Auditing and Logs**:  
   - All actions are logged for auditing and traceability purposes.

---

## **4. Technical Decisions**

| **Decision**                           | **Justification**                           |
|----------------------------------------|--------------------------------------------|
| **REST/SOAP API**                      | Flexibility in integrating with legacy systems.|
| **ServiceNow Performance Analytics**   | Native and integrated monitoring solution. |
| **Auditing via Logs**                  | Ensures traceability and quick issue resolution.|
| **Asynchronous Queue (Optional)**      | Prevents overload during peak request periods.|

---

## **5. Tools Used**

- **ServiceNow**: Primary platform for workflow management and automation.  
- **PONTO System**: Legacy system with an integration API.  
- **Monitoring Tools**:  
  - **Performance Analytics** (native) or integration with **Splunk**/**Datadog**.  
- **Mock API** (optional): Use **Postman** or **JSON Server** to simulate the PONTO API.  

---

## **6. Conclusion**
This document provides a detailed end-to-end architecture using the C4 model to describe the solution in layers. Technical decisions were made focusing on robustness, scalability, and traceability to ensure efficient integration between ServiceNow and the legacy PONTO system.
