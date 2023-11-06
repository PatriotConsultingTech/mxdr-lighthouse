# ARM template version for MSSPs

This is version of the Azure Sentinel template includes Azure Lighthouse delegations as part of the deployment. The template performs the following tasks:

- Creates resource group (if given resource group doesn't exist yet)
- Creates the **Azure Lighthouse** registration definition
- Creates the **Azure Lighthouse** registration assignments to the resource group that will contain the Azure Sentinel resources
- Creates Log Analytics workspace
- Installs Azure Sentinel on top of the workspace 
- Sets workspace retention, daily cap and commitment tiers if desired
- Enables UEBA with the relevant identity providers (AAD and/or AD)
- Enables health diagnostics for Analytics Rules, Data Connectors and Automation Rules
- Installs Content Hub solutions from a predefined list in three categories: 1st party, Essentials and Training
- Enables Data Connectors from this list:
    + Azure Active Directory (with the ability to select which data types will be ingested)
    + Azure Active Directory Identity Protection
    + Azure Activity (from current subscription)
    + Dynamics 365
    + Microsoft 365 Defender
    + Microsoft Defender for Cloud
    + Microsoft Insider Risk Management
    + Microsoft Power BI
    + Microsoft Project
    + Office 365
    + Threat Intelligence Platforms
- Enables analytics rules (Scheduled and NRT) included in the selected Content Hub solutions, with the ability to filter by severity
- Enables analytics rules (Scheduled and NRT) that use any of the selected Data connectors, with the ability to filter by severity
- Enables analytics rules (Scheduled and NRT) included in the selected Content Hub solutions, with the ability to filter by severity
- Enables analytics rules (Scheduled and NRT) that use any of the selected Data connectors, with the ability to filter by severity 


    [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FPatriotConsultingTech%2Fmxdr-lighthouse%2Fmain%2Fazure-sentinel%2FMSSPVersion%2Fmsspdeploy.json%3F/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FPatriotConsultingTech%2Fmxdr-lighthouse%2Fmain%2Fazure-sentinel%2FMSSPVersion%2FcreateUiDefinition.json)

