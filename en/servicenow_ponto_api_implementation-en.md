
# ServiceNow API Implementation

## 1. Scripted REST API
The Scripted REST API implements custom endpoints for REST/SOAP communication.

### Creation Steps:
1. Navigate to: **System Web Services > Scripted REST APIs**.
2. Click on **New** to create a new custom API.
3. **Basic Fields**:
   - **Name**: `PontoSystemAPI`
   - **API ID**: `ponto_system_api`
   - **Namespace**: `custom`

4. **Add Resource**:
   - **Name**: `sendClockInData`
   - **HTTP Method**: `POST`
   - **Relative Path**: `/clock-in`

### REST Endpoint Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var clockInData = request.body.data; // Receive body data

        // Construct a request to the legacy system
        var client = new sn_ws.RESTMessageV2();
        client.setHttpMethod('POST');
        client.setEndpoint('https://legacy.ponto-system.com/clock-in');
        client.setRequestHeader('Content-Type', 'application/json');
        client.setRequestBody(JSON.stringify(clockInData));

        var result = client.execute();
        var httpResponseCode = result.getStatusCode();

        // Handle response
        if (httpResponseCode == 200) {
            responseBody.message = "Clock-in data successfully sent.";
            response.setStatus(200);
        } else {
            responseBody.message = "Error sending clock-in data.";
            response.setStatus(500);
        }
    } catch (error) {
        responseBody.message = "Exception occurred: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Flow Designer
The Flow Designer orchestrates the automation to send data to the **PONTO System**.

### Steps to Create Flow:
1. Navigate to **Flow Designer**.
2. Click **New Flow**:
   - **Name**: `Submit Clock-In Data`

3. **Triggers**:
   - **Manual Trigger** or event-based (e.g., "Record Inserted").

4. **Steps**:
   - **Step 1**: Call Scripted REST API.
     - Use **REST Step** to make a `POST` call.
     - **URL**: `/api/custom/ponto_system_api/clock-in`
     - **Body**: Include clock-in data payload.

5. **Log Results** in Database:
   - Use **Create Record** to log results to the database table.

---

## 3. Database (Logs and Records)
A native ServiceNow table to store logs and processed data.

### Table Creation:
1. Navigate to **System Definition > Tables**.
2. Create a new table:
   - **Name**: `Ponto_ClockIn_Logs`
   - Add fields:
     - **Clock-In Data**: String
     - **Status**: String
     - **Timestamp**: Date/Time

3. In the Flow Designer:
   - Use **Create Record** to log data.

---

## Workflow Summary:
- **Flow Designer** triggers and orchestrates data flow.
- **Scripted REST API** handles communication with the PONTO system.
- **Database** stores logs and results for further reference.

---

**End of Document**
