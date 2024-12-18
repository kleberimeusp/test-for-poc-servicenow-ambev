
# ServiceNow Integration with PONTO System

## Process Description
The integration process between **ServiceNow** and the **PONTO** system to manage clock-in requests involves:
1. **PONTO System Consultation**: Validate existing clock-ins before opening a new request.
2. **Opening a Request in ServiceNow**: Clock-in request is validated and registered.
3. **Automatic Submission to the PONTO System**: Integration to send clock-in data.
4. **Status Update**: Validation in the PONTO system and status update in ServiceNow.
5. **Audit and Logs**: Detailed traceability of actions and failures.

---

## 1. PONTO System Consultation

### Scripted REST API: Check Clock-Ins
- **Endpoint**: `/api/custom/ponto_api/consult-clockin`
- **Method**: `GET`

### Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var employeeId = request.queryParams.employeeId;
        if (!employeeId) {
            response.setStatus(400);
            response.setBody({ error: "Missing parameter: employeeId" });
            return;
        }

        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('GET');
        client.setEndpoint('https://legacy.ponto-system.com/api/clock-in?employeeId=' + employeeId);

        var result = client.execute();
        var statusCode = result.getStatusCode();
        var responseBodyRaw = result.getBody();

        if (statusCode == 200) {
            responseBody = JSON.parse(responseBodyRaw);
            response.setStatus(200);
        } else {
            responseBody.error = "Failed to fetch data.";
            responseBody.details = responseBodyRaw;
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.error = "Error: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Automatic Submission to the PONTO System

### Scripted REST API: Submit Clock-Ins
- **Endpoint**: `/api/custom/ponto_api/send-clockin`
- **Method**: `POST`

### Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var requestBody = request.body.data;

        if (!requestBody.employeeId || !requestBody.clockInTime) {
            response.setStatus(400);
            response.setBody({ error: "Missing fields: employeeId or clockInTime" });
            return;
        }

        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('POST');
        client.setEndpoint('https://legacy.ponto-system.com/api/clock-in');
        client.setRequestHeader('Content-Type', 'application/json');
        client.setRequestBody(JSON.stringify(requestBody));

        var result = client.execute();
        var statusCode = result.getStatusCode();

        if (statusCode == 200) {
            responseBody.message = "Clock-in successfully submitted.";
            response.setStatus(200);
        } else {
            responseBody.error = "Failed to send clock-in data.";
            responseBody.details = result.getBody();
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.error = "Error: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 3. Required Tables

### Request Table (`u_request_table`)
| Field Name      | Type        | Description                  |
|-----------------|-------------|------------------------------|
| u_request_id    | String      | Request ID                   |
| u_employee_id   | String      | Employee identification      |
| u_clockin_time  | DateTime    | Clock-in timestamp           |
| u_status        | String      | Request status               |

### Auditing Logs (`u_auditing_logs`)
| Field Name      | Type        | Description                  |
|-----------------|-------------|------------------------------|
| u_action        | String      | Action performed             |
| u_employee_id   | String      | Employee identification      |
| u_details       | String      | Result details               |
| u_timestamp     | DateTime    | Timestamp of the action      |

---

## 4. Workflow in Flow Designer

### Workflow Steps:
1. **Trigger**: Manual submission or event.
2. **Step 1**: Call the API `consult-clockin` to validate existing clock-ins.
3. **Step 2**: If validation is approved, create a record in the **Request Table**.
4. **Step 3**: Call the API `send-clockin` to send data to the PONTO system.
5. **Step 4**: Query the status again and update the record.
6. **Step 5**: Log success or failure in the **Auditing Logs**.

---

## 5. Error Handling and Auditing

### Error Handling:
- Validate required parameters.
- Log failures when querying or sending data.
- Implement an `Error` status in the record if the operation fails.

### Auditing and Logs:
- Each action is recorded in the **Auditing Logs** table for traceability.
- Error details are stored for analysis.

---

## Process Summary
1. **Initial Consultation**: Check in the PONTO system.
2. **Request Submission**: Validated record in ServiceNow.
3. **Submission**: Integration with the legacy system via API.
4. **Update**: Status updated, and logs recorded.
5. **Auditing**: Full traceability of actions.

---

**End of Document**
