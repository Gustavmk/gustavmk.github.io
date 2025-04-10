---
title: "OpenTofu + CSV"
date: 2025-04-09
toc: false
#comments: true
---

Há pessoas que possuem um vicio incontrolável por planilhas e acabei me envolvendo nesse mundo também. De uma forma semelhante, desde que comecei a trabalhar com infraestrutura como código, sempre procurei maneiras de automatizar tarefas repetitivas e otimizar processos. Há uns anos atrás, me deparei com o OpenTofu a possibilidade de integrar isso com arquivos CSV.Tipicos das planilhas que usamos geralmente para inventariar regras de firewall e afins.

O exemplo que compartilho hoje é para usuários que queiram integrar esse cenário para criação de DNS ou regras de firewall ou qualquer outro cenário que você possuirá uma lista e precisa de uma função de iteração dessa listagem. 

- Arquivo CSV

```csv
route_name,resource_group_name,route_table_name,address_prefix,next_hop_type,next_hop_in_ip_address
route0,rg-teste,AwesomeRouteTable_v2,1.1.1.1/32,Internet,null
route1,rg-teste,AwesomeRouteTable_v2,2.2.2.2/32,VirtualAppliance,10.0.0.1
route2,rg-teste,AwesomeRouteTable_v2,3.2.2.2/32,VirtualAppliance,10.0.0.1
route3,rg-teste,AwesomeRouteTable_v2,4.2.2.2/32,VirtualAppliance,10.0.0.1
route4,rg-teste,AwesomeRouteTable_v2,5.2.2.2/32,VirtualAppliance,10.0.0.1
route5,rg-teste,AwesomeRouteTable_v2,6.2.2.2/32,VirtualAppliance,10.0.0.1
route6,rg-teste,AwesomeRouteTable_v2,7.2.2.2/32,VirtualAppliance,10.0.0.1
```

- Armazenando informação em um Local

Local value que define o nome *vnet_routes*, onde podemos relacionar diversas novas vezes a partir dele.
O arquivo CSV precsia ser armazenado a partir do diretório raiz do modulo em referência.

```terraform
locals {
  vnet_routes = csvdecode(file("${path.module}/vnet_routes.csv"))
}
```

- Aplicar excelll
1. This is a for_each loop that references the CSV file from the local value.
  - I've also set it to assign a key of the route_name (from the CSV file) to each route, making a map (key/value pair) of the data.
  - This lets me change or destroy routes without having to re-create all of the routes, as you would with a list.
2. Cada linha do csv entra no laço definido por *função* 'each.value.' + coluna do csv.
3. Ternário. Função condicional que validará caso o tipo definido da coluna seja "VirtualAppliance". Quais são as possiveis condições:
   - Caso 1: Se "virtualAppliance" for verdadeiro, então ele definirá o next hop definido na ultima coluna do csv
   - Caso 2: Se "virtualAppliance" for False, então não haverá a configuraçõ da regra de Next Hop na rota.  
   
```terraform
resource "azurerm_route" "vnet_routes" {

  # 1
  for_each               = { for routes in local.vnet_routes : routes.route_name => routes }

  # 2
  name                   = each.value.route_name
  resource_group_name    = each.value.resource_group_name
  route_table_name       = each.value.route_table_name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type

  # 3
  next_hop_in_ip_address = (each.value.next_hop_type == "VirtualAppliance") == true ? each.value.next_hop_in_ip_address : null

  depends_on = [ azurerm_resource_group.my_rg ]
}
```
