using Microsoft.Extensions.Configuration;
using System.Web;

namespace patriot.mxdr.githubutil
{
    public class UrlChecker
    {
        private string[] allowedPaths;

        public UrlChecker(IConfiguration config)
        {
            allowedPaths = config.GetSection("AllowedPaths").Value.Split(",");
        }

        public bool CheckUrl(string url)
        {
            if (string.IsNullOrEmpty(url)) return false; 
            string decodedUrl = HttpUtility.UrlDecode(url);
            foreach (string allowedPath in allowedPaths)
            {
                string decodedAllowedPath = HttpUtility.UrlDecode(allowedPath);
                if (url.Contains(allowedPath) || decodedUrl.Contains(decodedAllowedPath))
                {
                    return true;
                }
            }
            return false;
        }
    }
}