---
layout: post
title:  "Azure Pipeline VMSS"
categories: [geral]
tags: [blog]
date:  2024-04-30
comments: true
---

### Azure Pipelines self-hosted em VMSS

Antes de qualquer coisa, deixo os creditos ao [Blog Yannick Reekmans](https://blog.yannickreekmans.be/use-azure-devops-to-create-self-hosted-azure-devops-build-agents-just-like-microsoft-does/) que há algum tempo compartilhou o modelo pelo qual me inspirei. 

O objetivo desse artigo é compartilhar como podemos criar nosso próprio Azure Pipeline como a Microsoft faz, utilizando Azure Virtual Machine Scale Set (VMSS) que é um tipo de infraestrutura IaaS auto escalável. Habilitar uma forma de conseguir criar modelos de imagem com Packer, através do repositório GIT que é disponibilizado do action-runners. Apesar do nome ter relação ao Github Actions, na verdade são modelos Packer e podem ser reutilizados em diferentes tipos de infraestrutura. 

O provisionamento dele pode ser complexo para quem está olhando pela primeira vez, então para poder descomplicar a aplicação na prática decidir criar um guia para compartilhar esse conteudo para você, meu querido leitor. 


### Hands-on

Para construir isso será recomendado seguir esse roteiro:

1. Criar o primeiro agent self-hosted com Azure CLI instalado 
    a. Tanto faz se será usado Windows ou Linux
    b. Pode utilizar o OpenTF para iniciar a infraestrutura, bastanto ativar a flag para provisionamento da VM de agent "ProvisionAndDeployFirstAgent"

2. Uma organização no Azure DevOps 
  a. Criar um Team Project ou usar um existente
  b. Configurar o Variable Group  "Image Generation Variables"
  c. criar as variaveis conforme Tabela de Referência da Variable Group


#### Tabela de Referência da Variable Group

| Key | Value Description |
|-------|-------|
| AZURE_AGENTS_RESOURCE_GROUP|a|
| AZURE_LOCATION||
| AZURE_RESOURCE_GROUP||
| AZURE_SUBSCRIPTION||
| AZURE_TENANT||
| BUILD_AGENT_SUBNET_NAME||
| BUILD_AGENT_VNET_NAME||
| BUILD_AGENT_VNET_RESOURCE_GROUP||
| CLIENT_ID||
| CLIENT_SECRET||
| GALLERY_NAME||
| GALLERY_RESOURCE_GROUP||
| RUN_VALIDATION_FLAG|true or false|
| VMSS_Ubuntu2004||
| VMSS_Ubuntu2204||
| VMSS_Windows2019 ||
| VMSS_Windows2022 ||








I hope you enjoy it! 😊
