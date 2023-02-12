# ARM template version for MSSPs

This is version of the Azure Sentinel template includes Azure Lighthouse delegation/s as part of the deployment. The template performs the following tasks:

- Creates resource group (if given resource group doesn't exist yet)
- Creates the **Azure Lighthouse** registration definition
- Creates the **Azure Lighthouse** registration assignments to the resource group that will contain the Azure Sentinel resources
- Creates Log Analytics workspace (if given workspace doesn't exist yet)
- Installs Azure Sentinel on top of the workspace (if not installed yet)
- Optional tasks
    - Enables the following Data Connectors: 
        + Azure Activity
        + Azure Security Center
        + Azure Active Directory Identity Protection
        + Office 365 (Sharepoint, Exchange and Teams)
        + Microsoft Cloud App Security
        + Azure Advanced Threat Protection
        + Microsoft Defender Advanced Threat Protection
        + Security Events
        + Linux Syslog
        + DNS (Preview)
        + Windows Firewall
    - Enables analytics rules for selected Microsoft 1st party products 
    - Enables Fusion rule and ML Behavior Analytics rules for RDP or SSH (if selected)
    - Enables Scheduled analytics rules that apply to all the enabled connectors 

    [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Ffn-githubproxy-prod.azurewebsites.net%2Fapi%2Ffn-githubproxy%3Fcode%3DNvzGPLuXcu5NgGFnlTqiBTE1xY7rM-CZo3WgC1ZFeM0zAzFuoQbRKA%3D%3D%26gitHubUrl%3Dhttps%3A%2F%2Fraw.githubusercontent.com%2FPatriotConsultingTech%2Fmxdr-lighthouse%2Fmain%2Fazure-sentinel%2FMSSPVersion%2Fmsspdeploy.json%3F/createUIDefinitionUri/https%3A%2F%2Ffn-githubproxy-prod.azurewebsites.net%2Fapi%2Ffn-githubproxy%3Fcode%3DNvzGPLuXcu5NgGFnlTqiBTE1xY7rM-CZo3WgC1ZFeM0zAzFuoQbRKA%3D%3D%26gitHubUrl%3Dhttps%3A%2F%2Fraw.githubusercontent.com%2FPatriotConsultingTech%2Fmxdr-lighthouse%2Fmain%2Fazure-sentinel%2FMSSPVersion%2FcreateUiDefinition.json)
