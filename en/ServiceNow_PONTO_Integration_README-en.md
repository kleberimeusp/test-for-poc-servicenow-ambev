
# ServiceNow Integration with PONTO System

## Overview
This document outlines the configuration and implementation details for integrating ServiceNow with the PONTO system. It includes the setup for **development**, **homologation**, and **production** environments, along with guidelines for using mock data in development.

---

## 1. Environment Separation

### 1.1 Defined Environments
- **Development**: 
  - Uses mock data for testing.
  - Ensures no impact on real systems.
- **Homologation**:
  - Validates integration with controlled real data.
- **Production**:
  - Full integration with the live PONTO system.

### 1.2 Environment Configuration in ServiceNow
- Use `sys_properties` to define environment-specific configurations:
  - `integration.url.ponto.dev`: Development URL (mocked).
  - `integration.url.ponto.hml`: Homologation URL.
  - `integration.url.ponto.prd`: Production URL.

- **Flow Designer Variables**:
  Define dynamic URLs based on the environment:
  ```json
  {
    "env": "dev", 
    "base_url": "https://mock-api.ponto.dev"
  }
  ```

---

## 2. Mock Data Configuration

### 2.1 Mock API Setup
Mock APIs simulate the behavior of the PONTO system in development:
- **Mock Endpoint: Send Data**
  - URL: `/api/custom/ponto/send`
  - Response:
    ```json
    {
      "status": "success",
      "message": "Mock: Data sent successfully"
    }
    ```

- **Mock Endpoint: Check Status**
  - URL: `/api/custom/ponto/status`
  - Response:
    ```json
    {
      "status": "success",
      "integration_status": "completed",
      "last_sync": "2024-12-17T20:00:00"
    }
    ```

---

## 3. Workflow Configuration

### 3.1 Flow Designer Setup
Steps for workflows in ServiceNow:
1. **Authenticate**: Get a token using OAuth 2.0.
2. **Send Data**: Post data to the PONTO system (mock or real).
3. **Check Status**: Verify the integration status.
4. **Retrieve Logs**: Fetch error or audit logs.

Dynamic URL assignment based on environment:
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

## 4. Monitoring and Scalability

### 4.1 Monitoring
- **Development**:
  - Enable detailed logging for debugging.
- **Homologation**:
  - Alerts for integration issues.
- **Production**:
  - Real-time monitoring using ServiceNow Event Management.

### 4.2 Scalability
- **Rate Limiting**: Control concurrent requests.
- **Caching**: Reduce redundant calls.
- **Load Balancing**: Support high volumes of traffic.

---

## 5. Example API Calls

### Authentication
**Endpoint**: `/oauth_token.do`  
**Method**: `POST`  
**Request**:
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

### Send Data
**Endpoint**: `/api/custom/ponto/send`  
**Method**: `POST`  
**Request**:
```json
{
  "user_id": "12345",
  "check_in": "2024-12-17T09:00:00",
  "check_out": "2024-12-17T18:00:00"
}
```

---

### Retrieve Logs
**Endpoint**: `/api/custom/ponto/logs`  
**Method**: `GET`  
**Response**:
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

## 6. Documentation

- **Checklist for Environments**:
  - URLs and credentials.
  - sys_properties for environment-specific settings.
- **Testing Guide**:
  - Include scenarios for each environment.
  - Compare mock and real API responses.

---

## 7. License
This integration setup is licensed under the company XPTO License.
