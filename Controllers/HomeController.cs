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


public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    private readonly IEmailService _emailService;

    private PostgresDataService _database;


    public HomeController(ILogger<HomeController> logger, PostgresDataService database, IEmailService emailService)
    {
        _logger = logger;
        _database = database;
        _emailService = emailService;
    }

    public IActionResult Index()
    {

        return View();
    }

    [HttpGet]
    public IActionResult Search()
    {
        var categories = _database.GetCategoriesWithSubsections();

        return View(categories);
    }

    [HttpGet("/[controller]/CourseHome/{CourseId}")]
    public IActionResult CourseHome(int CourseId)
    {
        Course course = _database.GetCourseInfo(CourseId);
        List<CourseAndGroupView> studyGroups = _database.getCourseStudyGroupsView(CourseId);
        UserProfileInfo userProfileInfo = _database.GetUserProfileInfo(course.AccountId);
        List<ProgramCourse> programCourses = _database.GetProgramsByCourseId(CourseId);

        ViewData["isBannedCourse"] = _database.IsCourseBanned(CourseId);
        ViewData["studyGroups"] = studyGroups;
        ViewData["userProfileInfo"] = userProfileInfo;
        ViewData["program"] = programCourses;

        return View(course);
    }


    [HttpPost]
    public IActionResult Search(SearchModel searchModel)
    {

        var data = _database.FilterCoursesAndGroups(
            searchModel.SectionId,
            searchModel.StartDate,
            searchModel.EndDate,
            searchModel.MinPrice,
            searchModel.MaxPrice,
            searchModel.DurationHours,
            searchModel.Organization,
            searchModel.FreeStudyGroup,
            searchModel.SearchQuery
        );
        return Json(data);
    }

    [HttpPost("[controller]/SearchSection/{SectionId}")]
    public IActionResult SearchSection(int SectionId)
    {

        var data = _database.FilterCoursesAndGroups(
            SectionId
        );
        return Json(data);
    }


    [HttpPost]
    public IActionResult CreateApplication([FromForm] Application model)
    {
        int newId = _database.CreateApplication(
            model.IdStudyGroup,
            model.FirstName,
            model.LastName,
            model.Surname,
            model.Phone,
            model.Birthday,
            model.Email
        );

        if (newId == 0)
        {
            return BadRequest();
        }

        return Ok();
    }

    public IActionResult Privacy()
    {
        return View();
    }




    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
