
# Optional Implementation and Demonstration

## **About the Implementation**
The implementation is optional and can be carried out if there is sufficient time and an adequate environment for execution.

### **Objective**
Prepare a **practical demonstration** to illustrate the proposed solution, including:  
1. **Emulation of the legacy system** to simulate the behavior of **PONTO**.  
2. Development of **scripts and basic endpoints** in **ServiceNow**.  
3. Ensuring a demonstrable environment for code analysis and solution discussion.

---

## **2. Mocking the Legacy System**
If the **PONTO** legacy system is not available, the implementation should include a **mock** to emulate its functionalities:

### **Recommended Tools**  
- **Postman Mock Server**: To create simulated APIs with configurable responses.  
- **JSON Server**: A lightweight and quick alternative to emulate RESTful APIs.  

### **Mocked Endpoints**  
Simulate the following endpoints with the necessary data:
1. `GET /ponto/records`  
   - Returns existing clock-in records.  
   - Example response:
     ```json
     [
       {"id": 1, "employee": "John", "date": "2024-06-10", "time": "08:00"},
       {"id": 2, "employee": "Mary", "date": "2024-06-10", "time": "08:15"}
     ]
     ```  

2. `POST /ponto/clock-in`  
   - Receives a new clock-in record and returns success or error.  
   - Example request:
     ```json
     {"employee": "John", "date": "2024-06-10", "time": "08:00"}
     ```  
   - Success response:
     ```json
     {"status": "success", "message": "Clock-in recorded successfully."}
     ```  

3. `GET /ponto/status/{id}`  
   - Returns the processing status of a request.  
   - Example response:
     ```json
     {"id": 1, "status": "completed", "message": "Clock-in successfully recorded in the system."}
     ```  

---

## **3. Demonstration on Interview Day**
### **Focus Points:**
1. **Solution Presentation**:  
   - Explanation of the integration flow between ServiceNow and the mocked legacy system.  
   - Demonstration of the implemented code, including REST/SOAP calls.  

2. **Code and Architecture**:  
   - Presentation of scripts developed in **ServiceNow** (e.g., Flow Designer, Scripted REST APIs).  
   - Justification of technical decisions, such as **REST API usage**, logging, and auditing.  

3. **Integration Execution**:  
   - Testing simulated functionalities in a local environment (mock API).  
   - Displaying logs and integration responses.  

---

## **4. Technical Discussion**
During the interview, the discussion will focus on:  
1. **Code and Implementation**: Understanding the logic and challenges faced.  
2. **Adopted Solutions**: Justifications for the chosen technical decisions.  
3. **Experience with Technologies**: Presentation of practical experience with:  
   - **ServiceNow**  
   - **REST/SOAP Integrations**  
   - **Mocking APIs**  
   - **Monitoring Tools**  

---

## **5. Conclusion**
This optional implementation offers a practical demonstration of the integrated solution, allowing:  
- Validation of the proposed approach.  
- Understanding of the technical decisions.  
- Display of skills with the involved technologies.

The implemented solution can be presented and discussed on interview day to evaluate its robustness, scalability, and efficiency. 🚀
