workspace "Integração ServiceNow-PONTO" "Diagrama de Contêineres entre ServiceNow e Sistema PONTO" {
    model {
        servicenow = softwareSystem "ServiceNow" "Plataforma central de automação de workflows" {
            flowDesigner = container "Designer de Fluxo" "Gerencia o fluxo automatizado de consultas e envios ao sistema PONTO" "ServiceNow"
            restAPI = container "API REST Script" "Implementa endpoints personalizados para comunicação REST/SOAP" "ServiceNow"
            database = container "Banco de Dados" "Banco de dados nativo para registros e logs de solicitações" "ServiceNow"
        }

        pontoSistema = softwareSystem "Sistema PONTO" "Sistema legado externo que recebe registros de ponto" {
            api = container "API REST/SOAP" "Interface para consultas e envios de registros de ponto" "Sistema PONTO"
        }

        sistemaMonitoramento = softwareSystem "Ferramenta de Monitoramento" "Performance Analytics/Splunk/Datadog" "Monitora logs e status"

        flowDesigner -> restAPI "Aciona chamadas REST/SOAP"
        restAPI -> api "Envia dados de registro de ponto"
        api -> database "Armazena dados processados"
        api -> sistemaMonitoramento "Envia logs e status"
        sistemaMonitoramento -> servicenow "Fornece dados de monitoramento"
    }

    views {
        container servicenow "DiagramaDeConteineres" {
            description "Diagrama de contêineres mostrando os contêineres do ServiceNow e Sistema PONTO, com seus relacionamentos."
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
            element "Ferramenta de Monitoramento" {
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
