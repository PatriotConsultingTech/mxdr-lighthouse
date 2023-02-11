using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;

namespace patriot.mxdr.githubutil
{
    public class githubproxy
    {
        private UrlChecker checker;
        private string githubAccessToken;

        public githubproxy(IConfiguration config)
        {
            checker = new UrlChecker(config);
            githubAccessToken = config.GetSection("githubAccessToken").Value;
        }

        private async Task<string> DownloadFileFromGitHub(string gitHubURL)
        {
            string strAuthHeader = "token " + githubAccessToken;
            HttpClient client = new HttpClient();
            client.DefaultRequestHeaders.Add("Accept", "application/vnd.github.v3.raw");
            client.DefaultRequestHeaders.Add("Authorization", strAuthHeader);
            Stream stream = await client.GetStreamAsync(gitHubURL);
            StreamReader reader = new StreamReader(stream);
            return reader.ReadToEnd();
        }

        [FunctionName("fn-githubproxy")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
    
            log.LogInformation("C# HTTP trigger received");

            string code = null;
            string gitHubURL = null;
            string errorMessage = null;
            ObjectResult result = null;

            try
            {
                gitHubURL = req.Query["gitHubURL"];
                bool isUrlAllowed = checker.CheckUrl(gitHubURL);
                if (isUrlAllowed)
                    code = await DownloadFileFromGitHub(gitHubURL);
                else
                    errorMessage = "Url is not allowed";
            }
            catch (Exception e)
            {
                errorMessage = e.Message;
            }

            if (null != errorMessage)
                result = new BadRequestObjectResult(errorMessage + ", URL passed in = " + gitHubURL);
            else
                result = new OkObjectResult(code);
            
            log.LogInformation("C# HTTP trigger finished");
            return result;
        }
    }
}
