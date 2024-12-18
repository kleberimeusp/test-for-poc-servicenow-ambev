# C4 Model - Documentation

## 2.1. Level 1 - Context
### Description:
The main flow of interaction occurs between **ServiceNow** (request management platform) and the **PONTO System** (legacy), where time records are validated, processed and sent.

### Participants:
- **ServiceNow**: Central platform for workflow automation.
- **Employees**: Users who request clock-in registrations.
- **PONTO System**: External legacy system that receives clock-in submissions.

### Diagram:
![Level 1 - Context](img/01-C4Model-Context-en.png)

---

## 2.2. Level 2 - Containers
### Description:
The containers detail the systems and their main components.

#### **ServiceNow**:
1. **Flow Designer**: Manages automation workflows for querying and submitting to the PONTO system.
2. **Scripted REST API**: Implements custom endpoints for REST/SOAP communication.
3. **Database**: ServiceNow's native database for request logs and records.

#### **PONTO System**:
- **REST/SOAP API**: Interface for querying and submitting clock-in data.

#### **Monitoring Tool (Optional)**:
- **Performance Analytics** or integration with **Splunk/Datadog** for status and log monitoring.

### Diagrams:
1. **ServiceNow and PONTO System - Containers**  
![Level 2 - Containers](img/01-C4Model-Containers-en.png)

2. **Flow Designer - Detail**  
![Flow Designer](img/01-C4Model-Components-Container-02-en.png)

3. **PONTO System - Detail**  
![PONTO API](img/01-C4Model-Components-Container-en.png)

---

## 2.3. Level 3 - Components

### Description:
Details of individual components and their functions.

| **Component**          | **Function**                                           |
|-------------------------|--------------------------------------------------------|
| **Flow Designer**       | Manages workflows for querying and submissions.       |
| **Custom Scripts/API**  | Implements REST/SOAP calls.                           |
| **Auditing and Logs**   | Tracks actions and failures for traceability.         |
| **Request Table**       | Stores requests and their statuses.                   |
| **PONTO API Endpoint**  | Interface for the PONTO system.                       |

### Diagrams:
1. **Components - ServiceNow - Flow Designer**  
![Flow Designer - Components](img/01-C4Model-Components-en.png)

2. **Components - ServiceNow and PONTO System**  
![Components - ServiceNow and PONTO](img/01-C4Model-Components-SystemContext-en.png)

3. **System Context**  
![System Context - ServiceNow](img/01-C4Model-Components-SystemContext-02-en.png)  

---

## Flow Summary:
1. **Employees** submit timesheets via **ServiceNow**.
2. ServiceNow **Flow Designer** triggers **REST/SOAP** calls via **Custom Scripts/API**.
3. Data is sent to **POINT System**, which validates and stores the records.
4. The **Database** in ServiceNow stores logs and processed records.
5. Optional logs can be monitored with **Monitoring Tool**.

---

## System View and Flows
### System Context:
- **ServiceNow**: Centralizes the automation of requests.
- **POINT System**: Receives point submissions.

![Context - ServiceNow](img/01-C4Model-Components-SystemContext-en.png)
![Context - PONTO System](img/01-C4Model-Components-SystemContext-02-en.png)

---

## Summary:
- **Level 1**: Shows the relationship between users and the main systems.
- **Level 2**: Details the containers within the systems.
- **Level 3**: Focuses on the internal components and their responsibilities.

---

## Complete Flow
### Interaction Diagram
![Complete Interaction](img/01-C4Model-Components-SoftwareSystem-en.png)