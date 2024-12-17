workspace "ServiceNow-PONTO Integration" "Container Diagram for ServiceNow and PONTO System" {
    model {
        servicenow = softwareSystem "ServiceNow" "Central platform for workflow automation" {
            flowDesigner = container "Flow Designer" "Manages the automation flow for queries and submissions to the PONTO system" "ServiceNow"
            restAPI = container "Scripted REST API" "Implements custom endpoints for REST/SOAP communication" "ServiceNow"
            database = container "Database" "Native database for request logs and records" "ServiceNow"
        }

        pontoSystem = softwareSystem "PONTO System" "External legacy system that receives clock-in submissions" {
            api = container "REST/SOAP API" "Interface for querying and submitting clock-in data" "PONTO System"
        }

        monitoringSystem = softwareSystem "Monitoring Tool" "Performance Analytics/Splunk/Datadog" "Monitors logs and statuses"

        flowDesigner -> restAPI "Triggers REST/SOAP calls"
        restAPI -> api "Sends clock-in data"
        api -> database "Stores processed data"
        api -> monitoringSystem "Sends logs and statuses"
        monitoringSystem -> servicenow "Provides monitoring data"
    }

    views {
        container servicenow "ContainerDiagram" {
            description "Container diagram showing ServiceNow and PONTO System containers, with their relationships."
            include *
            autolayout lr
        }

        styles {
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
            element "Monitoring Tool" {
                background "#A1B2C3"
                color "#000000"
                shape "hexagon"
            }
            relationship "Relationship" {
                color "#707070"
            }
        }
    }
}
