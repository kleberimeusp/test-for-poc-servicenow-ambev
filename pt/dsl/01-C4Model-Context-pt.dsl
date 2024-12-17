workspace "Integração ServiceNow-PONTO" "Diagrama de Contexto entre ServiceNow e Sistema PONTO" {
    model {
        empregados = person "Empregados" "Usuários que solicitam registros de ponto"
        servicenow = softwareSystem "ServiceNow" "Plataforma central de automação de workflows"
        pontoSistema = softwareSystem "Sistema PONTO" "Sistema legádo externo que recebe registros de ponto"

        // Relacionamentos
        empregados -> servicenow "Envia solicitações de registro de ponto"
        servicenow -> pontoSistema "Envia registros de ponto validados"
        pontoSistema -> servicenow "Retorna status (sucesso ou erro)"
    }

    views {
        systemContext servicenow "DiagramaDeContexto" {
            description "Diagrama de contexto mostrando interações entre Empregados, ServiceNow e Sistema PONTO."
            include *
            autolayout lr 
        }

        // Estilos para elementos
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
