using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security;
using Microsoft.Azure.Management.ResourceManager.Models;

namespace DeployArmTemplate
{
    class Program
    {
        static void Main(string[] args)
        {
            // Replace these with your own values.
            string subscriptionId = "your_subscription_id";
            string resourceGroupName = "your_resource_group_name";
            string armTemplateUrl = "https://raw.githubusercontent.com/your_repo/your_branch/your_arm_template.json";
            string githubToken = "your_github_token";

            // Create a secure string from the GitHub token.
            SecureString secureGithubToken = new SecureString();
            foreach (char c in githubToken)
            {
                secureGithubToken.AppendChar(c);
            }
            secureGithubToken.MakeReadOnly();

            // Download the ARM template from the private GitHub repository.
            string armTemplateJson;
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Token", githubToken);

                var response = client.GetAsync(armTemplateUrl).Result;
                armTemplateJson = response.Content.ReadAsStringAsync().Result;
            }

            // Create the deployment.
            var deployment = new Deployment
            {
                Properties = new DeploymentProperties
                {
                    Mode = DeploymentMode.Incremental,
                    Template = JObject.Parse(armTemplateJson),
                    Parameters = JObject.Parse("{}"),
                    DebugSetting = new DebugSetting
                    {
                        DetailLevel = DeploymentDebugDetailLevel.None
                    }
                }
            };

            // Use the Azure portal to create the resources.
            string deploymentUri = $"https://portal.azure.com/#create/Microsoft.Template/uri/{Uri.EscapeDataString(armTemplateUrl)}";
            deploymentUri = deploymentUri + $"&subscriptionId={subscriptionId}&resourceGroupName={resourceGroupName}&secureToken={secureGithubToken.ToString()}";
            System.Diagnostics.Process.Start(deploymentUri);
        }
    }
}

