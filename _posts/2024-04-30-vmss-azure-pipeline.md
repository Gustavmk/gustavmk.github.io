---
layout: post
title:  "Azure Pipeline VMSS"
categories: [CI, Azure DevOps]
tags: [devops]
date:  2024-04-30
comments: true
---

#### Azure Pipelines self-hosted em VMSS

O objetivo desse artigo é compartilhar como podemos criar nosso próprio Azure Pipeline como a Microsoft faz, utilizando Azure Virtual Machine Scale Set (VMSS) que é um tipo de infraestrutura IaaS auto escalável. Através de modelos de imagem com Packer,usando um repositório GIT para versionamento, que usaremos o prórpio da Github, [actions/runners-image](https://github.com/actions/runner-images). Apesar do nome ter relação ao Github Actions, na verdade são modelos Packer e podem ser reutilizados em diferentes tipos de infraestrutura.

Quando falamos de IaC, temos em mente um conceito de D.R.Y (Don't repeat yourself). Essa ideia, de possuir uma infraestrutura imutavel, evitar repetições de código e garantir que o provisionamento seja completamente automatizado é hyper empolgante para mim. Antes de qualquer coisa, deixo creditos ao [Yannick Reekmans](https://blog.yannickreekmans.be/use-azure-devops-to-create-self-hosted-azure-devops-build-agents-just-like-microsoft-does/), que há um tempo atŕas compartilhou em seu blog o modelo pelo qual me inspirei nesse post.
  
Antes de começar essa aprimoração do projeto, já vinha trabalhando em containers e criação de imagens para automação de builds para certas demandas de projetos. O próposito é alinhar DevOps, Azure, Azure DevOps, Azure Pipeline, Packer e Terraform, e, integrar todos esses elementos para obter agentes autoescaláveis. Porém, se você usa uma VM "nua", ou seja sem dependencias, tooling mandatório, suas jobs do pipeline ficam lentas, problemáticas e ocorre na grande maioria das vezes perda de performance. Isso acaba levando muitos times a utilizar o Agent microsoft-hosted, mas isso refletirá em custos devido a essa facilidade, e também perdemos todos os beneficios de ter a infraestrutura em nossas mãos.  

As imagens que vamos trabalhar para disponibilziar na galeria da Azure poderão ser demandadas pelas jobs de pipeline da sua organização, existem diversos beneficios nisso, como possibililidade de utilizar sua própria Virtual Network, para garantir a privacidade entre outros beneficios de performance que só são possíveis quando você tem maior controle da infraestrutura.

Esse exemplo será complexo para quem está olhando pela primeira vez essas tecnologias, então para poder descomplicar a aplicação na prática decidir criar um guia para compartilhar esse conteudo para você, meu querido leitor. 

#### Hands-on

![Design](/assets/posts/vmss-azure-pipeline/design.png)

Para construir isso será recomendado seguir esse roteiro:

1 Criar o primeiro *agent self-hosted* com Azure CLI instalado.
  - Tanto faz se será usado Windows ou Linux.
  - Pode utilizar o OpenTofu para iniciar a infraestrutura.
  - Faça clone do repositório <<[link](https://github.com/Gustavmk/azuredevops-buildagents)>>
  - esse mesmo repositório será importado posteriormente no Azure Repo

      ```bash
      git clone https://github.com/Gustavmk/azuredevops-buildagents
      cd azuredevops-buildagents/infra
      
      az login --use-device-code
      # az account list -o table  
      az account set --subscription "xxxx-xxx"
      
      tofu init
      tofu plan -out "tf.plan"
      tofu apply "tf.plan"
      ``` 

2 Criar/utilizar uma organização no Azure DevOps.
  - Criar um Team Project ou usar um existente.
  - Configurar o Variable Group  "Image Generation Variables".
  - criar as variaveis conforme Tabela de Referência da Variable Group.

    ![variable group](/assets/posts/vmss-azure-pipeline/variable_group.jpg)


3 Importar o repositório azuredevops-buildagent <<[link do repo](https://github.com/Gustavmk/azuredevops-buildagents)>>.

4 Configurar o pipeline.
  - pode pular essa etapa caso você tenha utilizado o OpenTofu.

5 Executar a primeira vez no Agent Pool primário.

6 Após o primeiro build, é posssível seguir com a criação do VMSS.

7 Remover o *agent pool* primário.

#### Tabela de Referência da Variable Group

 Key | Value |  Description | 
:-------|:-------:|:-------| 
AZURE_AGENTS_RESOURCE_GROUP| rg-devops | Resource Group para recursos do VMSS, imagens, vnet e VM 
AZURE_RESOURCE_GROUP| temp-packer | temp packer resource group
AZURE_LOCATION| [ Region ]| região onde está localizado os recursos
CLIENT_ID| [ Client ID da SP ]| Informação da Service Principal 
CLIENT_SECRET| [ Secret da SP ]| Informação da Service Principal 
AZURE_SUBSCRIPTION| [ Azure Subscription ID ]| Informação da Service Principal
AZURE_TENANT| [ Azure Tenant ID ] | Informação da Service Principal
BUILD_AGENT_SUBNET_NAME| subnet-azuredevops | Nome da subnet. Você pode customizar ou manter esse mesmo valor
BUILD_AGENT_VNET_NAME| vnet-example | Nome da Azure Virtual Network (VNET). Você pode customizar ou manter esse mesmo valor
BUILD_AGENT_VNET_RESOURCE_GROUP| rg-devops | Nome do Resource Group da VNET. Você pode customizar ou manter esse mesmo valor
GALLERY_NAME|gal_azure_devops| nome da Azure Compute Gallery
GALLERY_RESOURCE_GROUP| rg-devops | Nome do Resource Group da Compute Gallery
RUN_VALIDATION_FLAG|true or false| Ative apenas em necessidade de debug
VMSS_Ubuntu2004|| nome do vmss para executar etapa de update do mss na versão Ubuntu 20.04
VMSS_Ubuntu2204|| nome do vmss para executar etapa de update do vmss na versão Ubuntu 22.04
VMSS_Windows2019 || nome do vmss para executar etapa de update do vmss na versão Windows 2019
VMSS_Windows2022 ||nome do vmss para executar etapa de update do vmss na versão Windows 2022


I hope you enjoy it! 😊
