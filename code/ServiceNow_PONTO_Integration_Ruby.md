# ServiceNow and PONTO System Integration Example (Ruby)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **Ruby**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```ruby
require 'net/http'
require 'uri'
require 'json'

INSTANCE = 'your-instance.service-now.com'
CLIENT_ID = 'your-client-id'
CLIENT_SECRET = 'your-client-secret'
USERNAME = 'your-username'
PASSWORD = 'your-password'

# 1. Login to ServiceNow
def login_service_now
  uri = URI("https://#{INSTANCE}/oauth_token.do")
  payload = {
    grant_type: 'password',
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    username: USERNAME,
    password: PASSWORD
  }

  response = make_request(uri, 'POST', payload)
  response['access_token']
end

# 2. Query the PONTO System
def consulta_sistema_ponto(token, requisicao_id)
  uri = URI("https://#{INSTANCE}/api/now/table/ponto_data?sys_id=#{requisicao_id}")
  make_request(uri, 'GET', nil, token)
end

# 3. Create a Request in ServiceNow
def abrir_requisicao(token, requisicao_data)
  uri = URI("https://#{INSTANCE}/api/now/table/requisicoes_ponto")
  make_request(uri, 'POST', requisicao_data, token)
end

# 4. Update Request Status
def atualizar_status_requisicao(token, requisicao_id, status_data)
  uri = URI("https://#{INSTANCE}/api/now/table/requisicoes_ponto?sys_id=#{requisicao_id}")
  make_request(uri, 'PUT', status_data, token)
end

# 5. Log Audit Data
def registrar_auditoria(token, audit_data)
  uri = URI("https://#{INSTANCE}/api/now/table/audit_logs")
  make_request(uri, 'POST', audit_data, token)
end

# Helper method to make HTTP requests
def make_request(uri, method, payload = nil, token = nil)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = case method
            when 'POST' then Net::HTTP::Post.new(uri)
            when 'PUT' then Net::HTTP::Put.new(uri)
            when 'GET' then Net::HTTP::Get.new(uri)
            else raise "Unsupported HTTP method: #{method}"
            end

  request['Content-Type'] = 'application/json'
  request['Authorization'] = "Bearer #{token}" if token
  request.body = payload.to_json if payload

  response = http.request(request)
  unless response.is_a?(Net::HTTPSuccess)
    raise "HTTP Error: #{response.code} #{response.message} - #{response.body}"
  end

  JSON.parse(response.body)
end

# Execution Flow
begin
  token = login_service_now

  # Example: Query the PONTO system
  consulta = consulta_sistema_ponto(token, 'requisicao-id-example')
  puts "PONTO system query: #{consulta}"

  # Example: Create a request
  requisicao_data = { example_field: 'value' }
  requisicao = abrir_requisicao(token, requisicao_data)
  puts "Request created: #{requisicao}"

  # Example: Update request status
  status_data = { status: 'Completed' }
  status_update = atualizar_status_requisicao(token, 'requisicao-id-example', status_data)
  puts "Status updated: #{status_update}"

  # Example: Log audit data
  audit_data = {
    action: 'Request updated',
    details: 'The request status was updated to Completed'
  }
  audit_log = registrar_auditoria(token, audit_data)
  puts "Audit log created: #{audit_log}"

rescue StandardError => e
  puts "Integration flow error: #{e.message}"
end
```
