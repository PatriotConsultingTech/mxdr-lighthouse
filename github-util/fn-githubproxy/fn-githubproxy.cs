using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net;
using Microsoft.Extensions.Primitives;
using System.Net.Http;

namespace patriot.mxdr.githubutil
{
    public static class githubproxy
    {
        [FunctionName("fn-githubproxy")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger received.");

            string githubAccessToken = "github_patto_11A32DTVY0C1dLUZFNSWdh_kh7wZ5zClgoKLjE1hCM6A0sYKXuYRMib8mB5eu7hPXw432PU76XK3aytOI1";

            string code = null;
            string gitHubURL = null;
            Exception error = null;

            try
            {
                gitHubURL = req.Query["gitHubURL"];
                string strAuthHeader = "token " + githubAccessToken;

                HttpClient client = new HttpClient();   
                client.DefaultRequestHeaders.Add("Accept", "application/vnd.github.v3.raw");
                client.DefaultRequestHeaders.Add("Authorization", strAuthHeader);

                Stream stream = await client.GetStreamAsync(gitHubURL);
                StreamReader reader = new StreamReader(stream);
                code = reader.ReadToEnd();
            }
            catch (Exception e)
            {
                error = e;
                // empty code var will signal error
            }
            ObjectResult result = null;
            if (null != code)
            {
                result = new OkObjectResult(code);
            }
            else
            {
                string errorMessage = null;
                if (null != error)
                {
                    errorMessage = error.Message;
                }
                result = new BadRequestObjectResult(errorMessage + ", URL passed in = " + gitHubURL);
            }
            return result;

        }
    }
}
