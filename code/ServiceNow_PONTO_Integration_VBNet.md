# ServiceNow and PONTO System Integration Example (VB.Net)

This document outlines the complete integration flow between ServiceNow and the PONTO system, including examples for login, data queries, request creation, data submission, status updates, data validation, error logging, auditing, and logout, implemented in **VB.Net**.

## Prerequisites
- **Instance**: Your ServiceNow instance (e.g., `your-instance.service-now.com`).
- **API Key**: Details for authentication, including `client_id`, `client_secret`, `username`, and `password`.
- **PONTO API URL**: The endpoint for the PONTO system (e.g., `https://sistema-ponto.com/api/marcacoes`).

## Code Implementation

```vb.net
Imports System
Imports System.IO
Imports System.Net
Imports System.Text
Imports Newtonsoft.Json

Public Class ServiceNowIntegration

    Private Const Instance As String = "your-instance.service-now.com"
    Private Const PontoAPI As String = "https://sistema-ponto.com/api/marcacoes"
    Private Const ClientId As String = "your-client-id"
    Private Const ClientSecret As String = "your-client-secret"
    Private Const Username As String = "your-username"
    Private Const Password As String = "your-password"

    ' 1. Login to ServiceNow
    Public Shared Function LoginServiceNow() As String
        Dim url As String = $"https://{Instance}/oauth_token.do"
        Dim payload As New With {
            Key .grant_type = "password",
            Key .client_id = ClientId,
            Key .client_secret = ClientSecret,
            Key .username = Username,
            Key .password = Password
        }

        Dim response As String = SendPostRequest(url, JsonConvert.SerializeObject(payload))
        Dim result = JsonConvert.DeserializeObject(Of Dictionary(Of String, Object))(response)
        Return result("access_token").ToString()
    End Function

    ' 2. Query the PONTO System
    Public Shared Function ConsultaSistemaPonto(token As String, requisicaoId As String) As String
        Dim url As String = $"https://{Instance}/api/now/table/ponto_data?sys_id={requisicaoId}"
        Return SendGetRequest(url, token)
    End Function

    ' 3. Create a Request in ServiceNow
    Public Shared Function AbrirRequisicao(token As String, requisicaoData As Object) As String
        Dim url As String = $"https://{Instance}/api/now/table/requisicoes_ponto"
        Return SendPostRequest(url, JsonConvert.SerializeObject(requisicaoData), token)
    End Function

    ' 4. Update Request Status
    Public Shared Function AtualizarStatusRequisicao(token As String, requisicaoId As String, statusData As Object) As String
        Dim url As String = $"https://{Instance}/api/now/table/requisicoes_ponto?sys_id={requisicaoId}"
        Return SendPutRequest(url, JsonConvert.SerializeObject(statusData), token)
    End Function

    ' 5. Log Audit Data
    Public Shared Function RegistrarAuditoria(token As String, auditData As Object) As String
        Dim url As String = $"https://{Instance}/api/now/table/audit_logs"
        Return SendPostRequest(url, JsonConvert.SerializeObject(auditData), token)
    End Function

    ' Helper methods
    Private Shared Function SendPostRequest(url As String, payload As String, Optional token As String = Nothing) As String
        Dim request = CType(WebRequest.Create(url), HttpWebRequest)
        request.Method = "POST"
        request.ContentType = "application/json"
        If token IsNot Nothing Then
            request.Headers.Add("Authorization", $"Bearer {token}")
        End If

        Using streamWriter = New StreamWriter(request.GetRequestStream())
            streamWriter.Write(payload)
        End Using

        Dim response = CType(request.GetResponse(), HttpWebResponse)
        Using streamReader = New StreamReader(response.GetResponseStream())
            Return streamReader.ReadToEnd()
        End Using
    End Function

    Private Shared Function SendGetRequest(url As String, token As String) As String
        Dim request = CType(WebRequest.Create(url), HttpWebRequest)
        request.Method = "GET"
        request.Headers.Add("Authorization", $"Bearer {token}")

        Dim response = CType(request.GetResponse(), HttpWebResponse)
        Using streamReader = New StreamReader(response.GetResponseStream())
            Return streamReader.ReadToEnd()
        End Using
    End Function

    Private Shared Function SendPutRequest(url As String, payload As String, token As String) As String
        Dim request = CType(WebRequest.Create(url), HttpWebRequest)
        request.Method = "PUT"
        request.ContentType = "application/json"
        request.Headers.Add("Authorization", $"Bearer {token}")

        Using streamWriter = New StreamWriter(request.GetRequestStream())
            streamWriter.Write(payload)
        End Using

        Dim response = CType(request.GetResponse(), HttpWebResponse)
        Using streamReader = New StreamReader(response.GetResponseStream())
            Return streamReader.ReadToEnd()
        End Using
    End Function

    ' Execution Flow
    Public Shared Sub Main()
        Try
            Dim token = LoginServiceNow()

            ' Example: Query the PONTO system
            Dim consulta = ConsultaSistemaPonto(token, "requisicao-id-example")
            Console.WriteLine("PONTO system query: " & consulta)

            ' Example: Create a request
            Dim requisicaoData = New With {
                Key .example_field = "value"
            }
            Dim requisicao = AbrirRequisicao(token, requisicaoData)
            Console.WriteLine("Request created: " & requisicao)

            ' Example: Update request status
            Dim statusData = New With {
                Key .status = "Completed"
            }
            Dim statusUpdate = AtualizarStatusRequisicao(token, "requisicao-id-example", statusData)
            Console.WriteLine("Status updated: " & statusUpdate)

            ' Example: Log audit data
            Dim auditData = New With {
                Key .action = "Request updated",
                Key .details = "The request status was updated to Completed"
            }
            Dim auditLog = RegistrarAuditoria(token, auditData)
            Console.WriteLine("Audit log created: " & auditLog)

        Catch ex As Exception
            Console.WriteLine("Integration flow error: " & ex.Message)
        End Try
    End Sub

End Class
```