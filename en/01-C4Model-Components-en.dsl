workspace "ServiceNow-PONTO Integration" "Component Diagram for ServiceNow and PONTO System" {
    model {
        servicenow = softwareSystem "ServiceNow" "Central platform for workflow automation" {
            flowDesigner = container "Flow Designer" "Manages the automation flow for queries and submissions to the PONTO system" "ServiceNow" {
                customScriptsAPI = component "Custom Scripts/API" "Implements REST/SOAP calls" "JavaScript/Python"
                auditingLogs = component "Auditing and Logs" "Tracks actions and failures for traceability" "Logging/Monitoring"
                requestTable = component "Request Table" "Stores requests and their statuses" "ServiceNow Table"
            }
        }

        pontoSystem = softwareSystem "PONTO System" "External legacy system that receives clock-in submissions" {
            pontoAPI = container "PONTO API Endpoint" "Interface for the PONTO system" "REST/SOAP API"
        }
    }

    views {


        styles {
            element "Component" {
                background "#85C1E9"
                color "#000000"
                shape "roundedbox"
            }
            element "Container" {
                background "#1168BD"
                color "#FFFFFF"
                shape "roundedbox"
            }
            element "Software System" {
                background "#08427B"
                color "#FFFFFF"
                shape "roundedbox"
            }
            relationship "Relationship" {
                color "#707070"
            }
        }
    }
}