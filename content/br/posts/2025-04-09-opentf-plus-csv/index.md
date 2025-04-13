---
title: "OpenTofu + CSV"
date: 2025-04-09
toc: false
#comments: true
---

# 🧾Guia Prático: Usando Arquivos CSV no OpenTofu

## Intro 

Há pessoas que têm um amor incontrolável por planilhas. Pois é… acabei me envolvendo nesse mundo também. Desde que comecei a trabalhar com *infraestrutura como código*, sempre procurei formas de automatizar tarefas repetitivas e agilizar processos, e, durante esse caminho de transiçaõ de controles por fora do código, estavam em planilhas, e as opções que eu estava trabalhando era muito verboso, mesmo reutilizando código não era prático como ler uma planilha.

Foi aí que, há alguns anos, descobri que o [OpenTofu](https://opentofu.org/) permite integrar arquivos CSV diretamente com o Terraform. A ideia é simples: usar listagens em formato `.csv` (como as que usamos pra inventariar regras de firewall, DNS, ou rotas de rede) e automatizar a criação desses recursos.

Neste guia, vou mostrar como você pode usar dados de um CSV para criar **rotas em uma Route Table** e **entradas de DNS**, de maneira fácil e replicável.

Todos os exemplos estão disponíveis no repositório [github.com/drylabs/posts](https://github.com/Gustavmk/drylabs-site-examples/tree/tofu-plus-csv/tf/tofu-plus-csv).

No final desse artigo você aprenderá a consumir CSV com OpenTofu/Terraform em seus projetos. 


## 📁Exemplo 1 – Criando Entradas na Route Table com CSV

1. CSV + mapping

Antes de tudo, vamos criar o nosso arquivo CSV chamado `vnet_routes.csv`, com as colunas necessárias:

```csv
route_name,address_prefix,next_hop_type,next_hop_ip
route0,1.1.1.1/32,Internet,null
route1,1.1.1.2/32,VirtualNetworkGateway,null
route2,1.1.1.3/32,VnetLocal,null
route4,1.1.1.4/32,None,null
route5,1.1.1.5/32,VirtualAppliance,10.0.0.1
```

> 💡Esse arquivo precisa estar no diretório raiz do seu módulo tf

2. Buscando csv e armazenando e decodificando ele no OpenTofu

Local value que define o nome *vnet_routes*, onde podemos relacionar diversas novas vezes a partir dele.
O arquivo CSV precsia ser armazenado a partir do diretório raiz do modulo em referência.

```terraform
locals {
  vnet_routes = csvdecode(file("${path.module}/vnet_routes.csv"))
}
```

1. Consumindo o locals na route table

```terraform
resource "azurerm_route" "vnet_routes" {
  for_each            = { for routes in local.csv_vnet_routes : routes.route_name => routes } 

  route_table_name    = azurerm_route_table.main.name
  resource_group_name = azurerm_resource_group.main.name

  name                   = each.value.route_name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  
  next_hop_in_ip_address = (each.value.next_hop_type == "VirtualAppliance") == true ? each.value.next_hop_ip : null
}
```

### 🔍 O que está acontecendo aqui?

#### Expressão for_each

`for_each = { for routes in local.csv_vnet_routes : routes.route_name => routes }`

Nessa parte o OpenTofu itera sobre os dados do local.csv_vnet_routes. Desta forma, é criado um mapa usando route_name como chave. Assim, cada rota será gerenciada de forma independente. Iremos observar esse comportamento mais adiante, após a aplicação do código.

#### Expressão ternária

`next_hop_in_ip_address = (each.value.next_hop_type == "VirtualAppliance") == true ? each.value.`

  - Se next_hop_type for "VirtualAppliance", o IP de próximo salto (next_hop_ip) será usado.
  - Caso contrário, o campo será null.


## Exemplo 2 - Criando entradas de DNS usando locals para definir um valor csv sem ter um arquivo csv no repositório


### 🔍 O que está acontecendo aqui?

## ✅Resultado final 

Para aplicar o código acima, foi utilizado o `tofu init, tofu plan -out tfplan e tofu apply "tfplan"`.

Todas as rotas e registros DNS definidos nas planilhas serão criados automaticamente.

![apply](tofu-apply.png)


🧠Dicas Úteis

- ✅Prefira for_each ao invés de count: O for_each funciona melhor que count quando os dados são baseados em mapas. Isso possibilita uma fácil manutenção, pois a remoção de uma entrada não afetará no ciclo de vida dos demais recursos.
- 🧩Campos opcionais (como o next_hop_ip) podem ser tratados com ternários, como mostrado acima.
- 🗃️Padronize os cabeçalhos do CSV: mantenha os nomes simples e sem espaços para facilitar o uso direto nas expressões each.value.


📚 Referências

- [Tofu - csvdecode()](https://opentofu.org/docs/language/functions/csvdecode/)
- [Tofu - for_each](https://opentofu.org/docs/language/meta-arguments/for_each/)
- [Tofu - Ternário / Conditional Expressions](https://opentofu.org/docs/language/expressions/conditionals/)
