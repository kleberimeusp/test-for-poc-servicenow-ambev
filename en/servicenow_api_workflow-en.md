
# ServiceNow API Workflow Implementation

## 1. Scripted REST API

### API Details:
- **Name**: `RequestStatusAPI`
- **API ID**: `request_status_api`
- **Namespace**: `custom`

### Endpoint Resource:
- **Path**: `/submit-request`
- **Method**: `POST`

### Script:
```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var responseBody = {};
    try {
        var requestBody = request.body.data;
        var requestId = requestBody.requestId;
        var requestStatus = requestBody.status;

        // Validation
        if (!requestId || !requestStatus) {
            response.setStatus(400);
            response.setBody({ error: "Missing requestId or status" });
            return;
        }

        // Update Request Table
        var gr = new GlideRecord('u_request_table');
        gr.addQuery('u_request_id', requestId);
        gr.query();

        if (gr.next()) {
            gr.u_status = requestStatus; // Update status
            gr.update();

            // Log the action
            var logGr = new GlideRecord('u_auditing_logs');
            logGr.initialize();
            logGr.u_action = 'Status Updated';
            logGr.u_request_id = requestId;
            logGr.u_status = requestStatus;
            logGr.insert();

            responseBody.message = "Request status updated successfully.";
            response.setStatus(200);
        } else {
            responseBody.error = "Request ID not found.";
            response.setStatus(404);
        }
    } catch (error) {
        responseBody.error = "Error occurred: " + error.message;
        response.setStatus(500);
    }

    response.setBody(responseBody);
})(request, response);
```

---

## 2. Flow Designer Workflow

### Steps:
1. **Trigger**: Record created/updated in the `Request Table`.
2. **Step 1**: Call the Scripted REST API `submit-request`.
   - **Endpoint**: `/api/custom/request_status_api/submit-request`
   - **Payload**:
   ```json
   {
       "requestId": "12345",
       "status": "Processing"
   }
   ```
3. **Step 2**: Validate the API response.
4. **Step 3**: Log the action in **Auditing Logs**.

---

## 3. Required Tables

### Request Table (`u_request_table`):
| Field Name     | Type    | Description               |
|----------------|---------|---------------------------|
| u_request_id   | String  | Unique Request ID         |
| u_status       | String  | Status of the request     |

### Auditing Logs (`u_auditing_logs`):
| Field Name     | Type        | Description               |
|----------------|-------------|---------------------------|
| u_action       | String      | Action performed          |
| u_request_id   | String      | Related Request ID        |
| u_status       | String      | Status after update       |
| u_timestamp    | DateTime    | Auto-generated timestamp  |

---

## 4. Summary Workflow
1. Requests are stored in the **Request Table**.
2. Flow Designer triggers the **Custom API** to process the request and update the status.
3. Actions and failures are logged in the **Auditing Logs** table for traceability.

---

**End of Document**
