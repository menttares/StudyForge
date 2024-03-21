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

public class CoursesController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private PostgresDataService _database;

    public CoursesController(ILogger<HomeController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }


    [HttpGet("Courses")]

    public IActionResult Panel()
    {
        var dataSections = _database.GetAllSections();
        ViewData["Sections"] = dataSections.Result;
        return View();
    }


    [HttpGet("Course/{Id}")]
    public IActionResult Course(int Id)
    {

        var dataCourse = _database.GetCourseById(Id);
        var dataStudyGroup = _database.search_study_group_view(
            p_course_id: Id
        );
        var dataTeacher = _database.GetTeachersByCourseId(Id);
        var dataProgram = _database.GetProgramsByCourseId(Id);

        ViewData["Course"] = dataCourse.Result;
        ViewData["StudyGroup"] = dataStudyGroup.Result;
        ViewData["Teacher"] = dataTeacher.Result;
        ViewData["Program"] = dataProgram.Result;

        return View();
    }


    [HttpPost]
    public IActionResult Sections()
    {
        var dataResult = _database.GetAllSections();
        var sections = JsonConvert.SerializeObject(dataResult.Result);
        return Json(sections);
    }


    [HttpPost]
    public IActionResult Recording( RecordingModel data)
    {
        var result = _database.CreateApplication(
            studyGroupId: data.StudyGroupId,
            firstName: data.FirstName,
            phone: data.Phone,
            birthday: data.Birthday
        );

        return Ok(result.Result);
    }



    [HttpPost]
    public IActionResult Search(SearchModel data)
    {

        var dataResult = _database.search_study_group_view(
            p_category_id: data.idCategory,
            p_search_string: data.searchStr,
            p_form_of_study_id: data.idFormStudy,
            p_start_date: data.startDate,
            p_start_price: data.startPrice,
            p_end_price: data.endPrice
            );


        var studyGroups = JsonConvert.SerializeObject(dataResult.Result);
        return Json(studyGroups);
    }

    [HttpGet]
    public IActionResult SearchCategory([FromQuery] int Categoryid)
    {

        var dataResult = _database.search_study_group_view(
                p_category_id: Categoryid
            );


        var studyGroups = JsonConvert.SerializeObject(dataResult.Result);
        return Json(studyGroups);
    }




}
