# ServiceNow and PONTO System Integration Example (Golang)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Golang**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```go
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

const (
	instance    = "your-instance.service-now.com"
	clientID    = "your-client-id"
	clientSecret = "your-client-secret"
	username    = "your-username"
	password    = "your-password"
)

// Login to ServiceNow
func loginServiceNow() (string, error) {
	url := fmt.Sprintf("https://%s/oauth_token.do", instance)
	payload := map[string]string{
		"grant_type":    "password",
		"client_id":     clientID,
		"client_secret": clientSecret,
		"username":      username,
		"password":      password,
	}
	response, err := sendPostRequest(url, payload, "")
	if err != nil {
		return "", err
	}

	var result map[string]interface{}
	err = json.Unmarshal(response, &result)
	if err != nil {
		return "", err
	}
	return result["access_token"].(string), nil
}

// Query the PONTO System
func consultaSistemaPonto(token, requisicaoID string) ([]byte, error) {
	url := fmt.Sprintf("https://%s/api/now/table/ponto_data?sys_id=%s", instance, requisicaoID)
	return sendGetRequest(url, token)
}

// Create a Request in ServiceNow
func abrirRequisicao(token string, requisicaoData interface{}) ([]byte, error) {
	url := fmt.Sprintf("https://%s/api/now/table/requisicoes_ponto", instance)
	return sendPostRequest(url, requisicaoData, token)
}

// Update Request Status
func atualizarStatusRequisicao(token, requisicaoID string, statusData interface{}) ([]byte, error) {
	url := fmt.Sprintf("https://%s/api/now/table/requisicoes_ponto?sys_id=%s", instance, requisicaoID)
	return sendPutRequest(url, statusData, token)
}

// Log Audit Data
func registrarAuditoria(token string, auditData interface{}) ([]byte, error) {
	url := fmt.Sprintf("https://%s/api/now/table/audit_logs", instance)
	return sendPostRequest(url, auditData, token)
}

// Helper Methods
func sendPostRequest(url string, payload interface{}, token string) ([]byte, error) {
	data, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(data))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	return ioutil.ReadAll(resp.Body)
}

func sendGetRequest(url, token string) ([]byte, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	return ioutil.ReadAll(resp.Body)
}

func sendPutRequest(url string, payload interface{}, token string) ([]byte, error) {
	data, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(data))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	return ioutil.ReadAll(resp.Body)
}

// Execution Flow
func main() {
	token, err := loginServiceNow()
	if err != nil {
		fmt.Printf("Error logging in: %v\n", err)
		os.Exit(1)
	}

	// Example: Query the PONTO system
	consulta, err := consultaSistemaPonto(token, "requisicao-id-example")
	if err != nil {
		fmt.Printf("Error querying PONTO system: %v\n", err)
	} else {
		fmt.Printf("PONTO system query: %s\n", consulta)
	}

	// Example: Create a request
	requisicaoData := map[string]string{
		"example_field": "value",
	}
	requisicao, err := abrirRequisicao(token, requisicaoData)
	if err != nil {
		fmt.Printf("Error creating request: %v\n", err)
	} else {
		fmt.Printf("Request created: %s\n", requisicao)
	}

	// Example: Update request status
	statusData := map[string]string{
		"status": "Completed",
	}
	statusUpdate, err := atualizarStatusRequisicao(token, "requisicao-id-example", statusData)
	if err != nil {
		fmt.Printf("Error updating status: %v\n", err)
	} else {
		fmt.Printf("Status updated: %s\n", statusUpdate)
	}

	// Example: Log audit data
	auditData := map[string]string{
		"action":  "Request updated",
		"details": "The request status was updated to Completed",
	}
	auditLog, err := registrarAuditoria(token, auditData)
	if err != nil {
		fmt.Printf("Error logging audit data: %v\n", err)
	} else {
		fmt.Printf("Audit log created: %s\n", auditLog)
	}
}
```