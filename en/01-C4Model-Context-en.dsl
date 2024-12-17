workspace "ServiceNow-PONTO Integration" "Context Diagram for ServiceNow and PONTO System" {
    model {
        employees = person "Employees" "Users who request clock-in registrations"
        servicenow = softwareSystem "ServiceNow" "Central platform for workflow automation"
        pontoSystem = softwareSystem "PONTO System" "External legacy system that receives clock-in submissions"

        // Relationships
        employees -> servicenow "Submits clock-in requests"
        servicenow -> pontoSystem "Sends validated clock-in records"
        pontoSystem -> servicenow "Returns status (success or error)"
    }

    views {
        systemContext servicenow "ContextDiagram" {
            description "Context diagram showing interactions between Employees, ServiceNow, and PONTO System."
            include *
            autolayout lr 
        }

        // Styles for elements
        styles {
            element "Person" {
                background "#08427B"
                color "#FFFFFF"
                shape "person"
                border "solid"
            }
            element "Software System" {
                background "#1168BD"
                color "#FFFFFF"
                shape "roundedbox"
            }
            relationship "Relationship" {
                color "#707070"
            }
        }
    }
}
