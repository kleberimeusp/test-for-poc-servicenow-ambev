
# ServiceNow API Implementation for Clock-In Workflow

## 1. Scripted REST API
This API handles employee clock-in submissions and sends them to the PONTO system.

### Creation Steps:
1. Navigate to **System Web Services > Scripted REST APIs** in ServiceNow.
2. Click on **New** to create a custom API.
3. **Basic Fields**:
   - **Name**: `EmployeeClockInAPI`
   - **API ID**: `employee_clockin_api`
   - **Namespace**: `custom`

### Endpoint Resource
- **Relative Path**: `/submit-clock-in`
- **HTTP Method**: `POST`

### REST API Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        // Obtain data from the request
        var requestBody = request.body.data;
        var employeeId = requestBody.employeeId;
        var clockInTime = requestBody.clockInTime;

        // Validate input
        if (!employeeId || !clockInTime) {
            response.setStatus(400); // Bad Request
            response.setBody({ error: "Missing employeeId or clockInTime" });
            return;
        }

        // Create a request to the legacy PONTO system
        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('POST');
        client.setEndpoint('https://legacy.ponto-system.com/api/clock-in');
        client.setRequestHeader('Content-Type', 'application/json');

        // Construct payload for PONTO system
        var payload = {
            employeeId: employeeId,
            clockInTime: clockInTime
        };
        client.setRequestBody(JSON.stringify(payload));

        // Execute the request
        var result = client.execute();
        var httpResponseCode = result.getStatusCode();
        var httpResponseBody = result.getBody();

        // Handle the response
        if (httpResponseCode == 200) {
            responseBody.status = "Success";
            responseBody.message = "Clock-in data successfully submitted.";
            response.setStatus(200);
        } else {
            responseBody.status = "Error";
            responseBody.message = "Failed to send clock-in data.";
            responseBody.details = httpResponseBody;
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.status = "Exception";
        responseBody.message = error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Flow Designer Workflow
The **Flow Designer** orchestrates the submission of clock-in data.

### Steps to Create the Flow:
1. Navigate to **Flow Designer**.
2. Create a new flow:
   - **Name**: `Submit Employee Clock-In`

3. **Triggers**:
   - Manual trigger or record-based event (e.g., Employee record updated).

4. **Steps**:
   - **Step 1**: Call the Scripted REST API `/submit-clock-in` using a POST method.
   - **Step 2**: Capture the API response.
   - **Step 3**: Log the response in a database table.

---

## 3. Database (Logs and Records)
Create a table in ServiceNow to store logs of clock-in submissions.

### Table Configuration:
- **Name**: `ClockIn_Logs`
- **Fields**:
  - **Employee ID**: String
  - **Clock-In Time**: Date/Time
  - **Status**: String (Success/Error)
  - **Response Details**: String

### Logging Workflow:
- Use a **Create Record** action in Flow Designer to log the results of the API call.

---

## Workflow Summary
1. Employees submit clock-in data to ServiceNow.
2. ServiceNow validates and forwards the data to the PONTO system via a Scripted REST API.
3. The API response is stored in a dedicated database table for logging and reporting.

---

**End of Document**
