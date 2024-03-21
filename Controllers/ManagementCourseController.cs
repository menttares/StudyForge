using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using StudyForge.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Newtonsoft.Json;
using StudyForge.Services;

namespace StudyForge.Controllers;

[Authorize]
public class ManagementCourseController : Controller
{
    private readonly ILogger<HomeController> _logger;


    private PostgresDataService _database;

    public ManagementCourseController(ILogger<HomeController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }


    public IActionResult Main()
    {

        return View();
    }

    public IActionResult Profile()
    {
        var login = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(login.Value);

        var data = _database.GetProfileData(id);
        return PartialView(data.Result);
    }

    public IActionResult Courses()
    {

        var login = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(login.Value);


        var data = _database.GetProfileCourses(id);

        return PartialView(data.Result);
    }

    [HttpGet]
    public IActionResult Applications()
    {
        var login = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(login.Value);

        var data = _database.GetApplicationsByStatus(1, id);

        return PartialView(data.Result);
    }

    [HttpPost]
    public IActionResult Application(int statusId)
    {
        var login = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var idParse = int.Parse(login.Value);

        var data = _database.GetApplicationsByStatus(statusId, idParse);
        var result = JsonConvert.SerializeObject(data.Result);
        return Json(result);
    }


    [HttpPost]
    public IActionResult ApplicationChangeStatus(int statusId, int ApplicationID)
    {
        _database.ChangeApplicationStatus(statusId, ApplicationID);
        return Ok();
    }
}
