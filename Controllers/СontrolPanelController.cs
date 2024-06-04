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
using StudyForge.Services;

namespace StudyForge.Controllers;

[Authorize]
public class СontrolPanelController : Controller
{
    private readonly ILogger<СontrolPanelController> _logger;

    private PostgresDataService _database;


    public СontrolPanelController(ILogger<СontrolPanelController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }

    [HttpGet("[Controller]")]
    public IActionResult Main()
    {

        return View();
    }

    public IActionResult Home()
    {
        return PartialView();
    }

    public IActionResult Statistics()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(ClaimIdentifier.Value);

        List<ApplicationStatistics> data = _database.GetApplicationsByCreator(id);

        return PartialView(data);
    }

    public IActionResult Applications()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(ClaimIdentifier.Value);

        List<Course> CourseInfo = _database.GetCoursesByProfile(id);

        return PartialView(CourseInfo);
    }

    [HttpGet]
    public IActionResult GetApplications(int courseId, int? statusId)
    {
        List<ApplicationDetails> applications = _database.GetApplications(courseId, statusId);
        return Json(applications);
    }
    
    [HttpPut("/СontrolPanel/ChangeApplicationStatus/{applicationId}/{newStatus}")]
    public IActionResult ChangeApplicationStatus(int applicationId, int newStatus)
    {
        bool isUpdate = _database.UpdateApplicationStatus(applicationId, newStatus);

        if (!isUpdate)
        {
            return BadRequest();
        }

        return Ok();
    }
    public IActionResult Profile()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(ClaimIdentifier.Value);

        UserProfileInfo profileInfo = _database.GetUserProfileInfo(id);
        ViewData["Specializations"] = _database.GetAllSpecializations();

        return PartialView(profileInfo);
    }

    [HttpPut]
    public IActionResult Profile(UpdateUserProfileModel data)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(ClaimIdentifier.Value);

        bool isUpdate = _database.UpdateUserProfile(
            id,
            data.name,
            data.aboutMe,
            data.specializationId
        );

        if (!isUpdate)
        {
            return BadRequest();
        }

        return Ok();
    }


    public IActionResult Courses()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(ClaimIdentifier.Value);

        List<Course> CourseInfo = _database.GetCoursesByProfile(id);

        return PartialView(CourseInfo);
    }

    [HttpPost]
    public IActionResult CreateCourses()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(ClaimIdentifier.Value);

        int insertedId = _database.CreateCourse(
            id,
            "Новый курс",
            1,
            "описание"
            );

        return Ok(insertedId);
    }


    [HttpDelete("/ControlPanel/DeleteCourse/{courseId}")]
    public IActionResult DeleteCourse(int courseId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

        var id = int.Parse(ClaimIdentifier.Value);

        _database.DeleteCourse(courseId);

        return Ok();
    }



    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
