workspace "Integração ServiceNow-PONTO" "Diagrama de Componentes entre ServiceNow e Sistema PONTO" {
    model {
        servicenow = softwareSystem "ServiceNow" "Plataforma central de automação de workflows" {
            flowDesigner = container "Flow Designer" "Gerencia o fluxo automatizado para consultas e envios ao sistema PONTO" "ServiceNow" {
                customScriptsAPI = component "Scripts/Customizados e API" "Implementa chamadas REST/SOAP" "JavaScript/Python"
                auditingLogs = component "Auditoria e Logs" "Rastreia ações e falhas para rastreabilidade" "Log/Monitoramento"
                requestTable = component "Tabela de Solicitações" "Armazena solicitações e seus status" "Tabela ServiceNow"
            }
        }

        pontoSystem = softwareSystem "Sistema PONTO" "Sistema legado externo que recebe registros de ponto" {
            pontoAPI = container "PONTO API Endpoint" "Interface para o sistema PONTO" "API REST/SOAP"
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
