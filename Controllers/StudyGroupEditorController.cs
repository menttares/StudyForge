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
public class StudyGroupEditorController : Controller
{
    private readonly ILogger<StudyGroupEditorController> _logger;

    private PostgresDataService _database;


    public StudyGroupEditorController(ILogger<StudyGroupEditorController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }


    [HttpPost("/StudyGroupEditor/New/{CourseId}")]
    public IActionResult New(int CourseId)
    {
        int NewGroupId = _database.CreateStudyGroup(
            CourseId,
            10,
            DateTime.Now,
            null,
            10,
            1,
            1,
            10);
        return Ok(NewGroupId);
    }

    [HttpDelete("/StudyGroupEditor/Delete/{GroupId}")]
    public IActionResult Delete(int GroupId)
    {
        int result = _database.DeleteStudyGroupById(GroupId);
        return Ok(result);
    }


    public IActionResult Group(int GroupId)
    {
        var group = _database.GetStudyGroupById(GroupId);
        ViewData["GroupId"] = GroupId;
        ViewData["Days"] = _database.GetAllDays();
        ViewData["Cities"] = _database.GetAllCities();
        ViewData["FormsTraining"] = _database.GetAllFormsTraining();
        return View(group);
    }

    [HttpPost]
    public IActionResult UpdateGroup(Group studyGroup, List<int> ScheduleDays)
    {
        bool isUpdateStudyGroup = _database.UpdateStudyGroup(
            studyGroup.Id,
            studyGroup.Enrollment,
            studyGroup.StartDate,
            studyGroup.EndDate,
            studyGroup.Price,
            studyGroup.FormsTrainingId,
            studyGroup.CityId,
            studyGroup.Duration
        );

        bool isUpdateScheduleDays = _database.UpdateScheduleDays(studyGroup.Id, ScheduleDays.ToArray());

        if (isUpdateStudyGroup && isUpdateScheduleDays)
        {
            return Ok();
        }

        return BadRequest();
    }


    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}


public record Group
{
    public int Id { get; set; }
    public int Enrollment { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public decimal Price { get; set; }
    public int FormsTrainingId { get; set; }
    public int CityId { get; set; }
    public int Duration { get; set; }
    public int CourseId { get; set; }

};