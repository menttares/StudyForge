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
        return PartialView(course);
    }

    [HttpPut]
    public IActionResult CoursePut([FromForm] CourseViewModel courseViewModel)
    {
        bool isUpdate = _database.UpdateCourse(
            courseViewModel.CourseId,
            courseViewModel.CourseName,
            courseViewModel.SectionId,
            courseViewModel.Description,
            courseViewModel.Closed
        );

        if (!isUpdate)
        {
            return BadRequest();
        }
        return Ok();
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
