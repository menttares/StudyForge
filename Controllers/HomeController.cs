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

    // Устанавливаем URL для метода котроллера
    [HttpGet("/[controller]/CourseHome/{CourseId}")]
    public IActionResult CourseHome(int CourseId)
    {
        // Получаем сам курс по ID
        Course course = _database.GetCourseInfo(CourseId);
        // Получаем все учебные группы связанные с ID курсом
        List<StudyGroup> studyGroups = _database.GetAllStudyGroupCourse(CourseId);
        // Получаем информацию о создателе курса
        UserProfileInfo userProfileInfo = _database.GetUserProfileInfo(course.AccountId);
        // Получаем все данные о программах курса
        List<ProgramCourse> programCourses = _database.GetProgramsByCourseId(CourseId);


        // Устанавливаем данные в данные представления

        ViewData["isBannedCourse"] = _database.IsCourseBanned(CourseId); // Проверяем на бан курса
        ViewData["studyGroups"] = studyGroups;
        ViewData["userProfileInfo"] = userProfileInfo;
        ViewData["program"] = programCourses;
        ViewData["Course"] = course;

        return View();
    }


    [HttpPost]
    public IActionResult Search(SearchModel searchModel)
    {

        var data = _database.FilterCoursesAndGroups(
            searchModel.SectionId,
            searchModel.StartDate,
            searchModel.MinPrice,
            searchModel.MaxPrice,
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
    public IActionResult CreateApplication([FromForm] ContactFormModel model)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values.SelectMany(v => v.Errors)
                                           .Select(e => e.ErrorMessage)
                                           .ToList();
            return Json(new { success = false, errors });
        }

        if (!model.Agreement)
        {
            return Json(new { success = false, errors = new List<string> { "Вы должны быть согласны на обработку" } });
        }
        int newId = _database.CreateApplication(
            model.IdStudyGroup,
            model.FirstName,
            model.LastName,
            model.MiddleName,
            model.Phone,
            model.Dob,
            model.Email
        );

        if (newId == 0)
        {
            return Json(new { success = false, errors = new List<string> { "Ошибка при создании заявки" } });
        }

        return Json(new { success = true });
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


    public ActionResult Noaccess()
    {
        return View();
    }
}
