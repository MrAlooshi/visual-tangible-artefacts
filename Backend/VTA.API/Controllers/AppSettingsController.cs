using Microsoft.AspNetCore.Mvc;

namespace VTA.API.Controllers;

[Route("api")]
[ApiController]
public class AppSettingsController : ControllerBase
{
    /// <summary>
    /// Serves the app settings configuration for the Flutter frontend
    /// </summary>
    /// <returns>JSON configuration object</returns>
    [HttpGet("app_settings")]
    public IActionResult GetAppSettings()
    {
        var appSettings = new
        {
            ApiSettings = new
            {
                BaseUrl = new
                {
                    Local = "http://localhost:5192/api/",
                    Remote = "http://localhost:5192/api/"
                }
            },
            ElevenLabs = new
            {
                LocalhostUrl = "http://localhost:5192/api/elevenlabs",
                ProductionUrl = "https://api.elevenlabs.io/v1"
            }
        };

        return Ok(appSettings);
    }
}


