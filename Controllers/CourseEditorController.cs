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
public class CourseEditorController : Controller
{
    private readonly ILogger<CourseEditorController> _logger;

    private PostgresDataService _database;


    public CourseEditorController(ILogger<CourseEditorController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }


    public IActionResult Course(int CourseId)
    {
        ViewData["CourseId"] = CourseId;
        return View();
    }

    [HttpGet]
    public IActionResult Main(int CourseId)
    {
        Course course = _database.GetCourseInfo(CourseId);
        ViewData["Subsections"] = _database.GetSubsections();
        ViewData["User"] = course;
        UpdateCourse updateCourse = new UpdateCourse()
        {
            CourseId = course.CourseId,
            SectionId = course.SectionId,
            CourseName = course.CourseName,
            CourseDescription = course.CourseDescription,
            CourseClosed = course.CourseClosed,
        };

        return PartialView(updateCourse);
    }

    [HttpPost]
    public IActionResult CoursePut(UpdateCourse courseViewModel)
    {


        bool isUpdate = _database.UpdateCourse(
            courseViewModel.CourseId,
            courseViewModel.CourseName,
            courseViewModel.SectionId,
            courseViewModel.CourseDescription,
            courseViewModel.CourseClosed
        );



        if (!isUpdate || !ModelState.IsValid)
        {
            ModelState.AddModelError(string.Empty, "Не удалось обновить курс.");
            return Json(new { success = false, errors = ModelState.ToDictionary(kvp => kvp.Key, kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()) });
        }

        // Логика сохранения данных

        return Json(new { success = true });
    }


    public IActionResult StudyGroups(int CourseId)
    {
        ViewData["CourseId"] = CourseId;
        List<StudyGroup> studyGroups = _database.GetAllStudyGroupCourse(CourseId);

        return PartialView(studyGroups);
    }


    public IActionResult Programs(int CourseId)
    {
        List<ProgramCourse> programs = _database.GetProgramsByCourseId(CourseId);
        ViewData["CourseId"] = CourseId;
        return PartialView(programs);
    }

    [HttpPost]
    public IActionResult CreateProgram(int CourseId)
    {
        int ProgramID = _database.CreateProgramCourse(
            "Новый",
            null,
            CourseId
        );


        ProgramCourse newProgramCourse = new ProgramCourse();
        newProgramCourse.Id = ProgramID;
        newProgramCourse.Name = "Новый";
        newProgramCourse.Description = "";
        newProgramCourse.CourseId = CourseId;

        return Ok(newProgramCourse);
    }

    [HttpPut]
    public IActionResult UpdateProgram(ProgramCourse program)
    {
        bool isUpdate = _database.UpdateProgramCourse(
            program.Id,
            program.Name,
            program.Description
        );

        if (!isUpdate)
            return BadRequest();

        return Ok();
    }


    [HttpDelete]
    public IActionResult DeleteProgram(int id)
    {
        bool isDelete = _database.DeleteProgramCourse(id);

        if (!isDelete)
            return BadRequest();

        return Ok();
    }


    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
