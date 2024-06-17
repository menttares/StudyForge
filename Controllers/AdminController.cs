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
using Microsoft.AspNetCore.Http.HttpResults;

namespace StudyForge.Controllers;


[Authorize(Roles = "admin")]
public class AdminController : Controller
{
    private readonly ILogger<HomeController> _logger;

    private PostgresDataService _database;


    public AdminController(ILogger<HomeController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }


    public IActionResult Main()
    {
        return View();
    }

    public PartialViewResult Accounts()
    {

        List<UserProfileInfo> data = _database.GetUserProfilesInfo();

        return PartialView(data);
    }


    [HttpPost]
    public IActionResult UpdateAccount(int accountId, bool confirmation)
    {
        bool isUpdate = _database.UpdateAccountConfirmation(accountId, confirmation);

        if (!isUpdate)
            return BadRequest();

        return Ok();
    }

    public PartialViewResult Statistics()
    {
        List<CourseStatistics> statistics = _database.GetCoursesPerSection();
        return PartialView(statistics);
    }


    [HttpPost("admin/unban-course")]
    public IActionResult UnbanCourse(int CourseId)
    {
        bool success = _database.DeleteBan(CourseId);

        if (!success)
        {
            return BadRequest();
        }

        return Ok();
    }

    [HttpPost("admin/ban-course")]
    public IActionResult BanCourse(int courseId,string reason )
    {
        int userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));
        int NewId = _database.AddBan(courseId, userId, reason);
        if (NewId == 0) 
            return BadRequest();
        return Ok();
    }

    public PartialViewResult Bans()
    {
        List<BannedCourseView> bannedAccountViews = _database.GetAllBannedCourses();

        return PartialView(bannedAccountViews);
    }
}
