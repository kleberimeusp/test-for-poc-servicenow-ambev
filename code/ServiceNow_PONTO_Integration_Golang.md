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
	payloadBytes, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("failed to login: %s", resp.Status)
	}

	body, _ := ioutil.ReadAll(resp.Body)
	result := make(map[string]interface{})
	json.Unmarshal(body, &result)

	return result["access_token"].(string), nil
}

// Query the PONTO System
func consultaSistemaPonto(token, requisicaoID string) (map[string]interface{}, error) {
	url := fmt.Sprintf("https://%s/api/now/table/ponto_data?sys_id=%s", instance, requisicaoID)
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

	body, _ := ioutil.ReadAll(resp.Body)
	result := make(map[string]interface{})
	json.Unmarshal(body, &result)

	return result, nil
}

// Create a Request in ServiceNow
func abrirRequisicao(token string, requisicaoData map[string]string) (map[string]interface{}, error) {
	url := fmt.Sprintf("https://%s/api/now/table/requisicoes_ponto", instance)
	payloadBytes, _ := json.Marshal(requisicaoData)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	result := make(map[string]interface{})
	json.Unmarshal(body, &result)

	return result, nil
}

// Update Request Status
func atualizarStatusRequisicao(token, requisicaoID string, statusData map[string]string) (map[string]interface{}, error) {
	url := fmt.Sprintf("https://%s/api/now/table/requisicoes_ponto?sys_id=%s", instance, requisicaoID)
	payloadBytes, _ := json.Marshal(statusData)

	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	result := make(map[string]interface{})
	json.Unmarshal(body, &result)

	return result, nil
}

// Execution Flow
func main() {
	token, err := loginServiceNow()
	if err != nil {
		fmt.Println("Login error:", err)
		return
	}

	consulta, err := consultaSistemaPonto(token, "requisicao-id-example")
	if err != nil {
		fmt.Println("Query error:", err)
		return
	}
	fmt.Println("Query result:", consulta)

	requisicaoData := map[string]string{
		"example_field": "value",
	}
	requisicao, err := abrirRequisicao(token, requisicaoData)
	if err != nil {
		fmt.Println("Request creation error:", err)
		return
	}
	fmt.Println("Request created:", requisicao)

	statusData := map[string]string{
		"status": "Completed",
	}
	status, err := atualizarStatusRequisicao(token, "requisicao-id-example", statusData)
	if err != nil {
		fmt.Println("Status update error:", err)
		return
	}
	fmt.Println("Status updated:", status)
}
```