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

        StudyGroup NewstudyGroup = _database.GetStudyGroupCourseViewById(NewGroupId);
        return Json(NewstudyGroup);
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

        UpdateGroup model = new UpdateGroup
        {
            Id = group.Id,
            Enrollment = group.Enrollment,
            StartDate = group.StartDate,
            EndDate = group.EndDate,
            Price = group.Price.ToString(),
            FormsTrainingId = group.FormsTrainingId,
            CityId = group.CityId,
            Duration = group.Duration,
            CourseId = group.CourseId,
            ScheduleDays = group.ScheduleDays.Select(sd => sd.Id).ToList()
        };

        return View(model);
    }

    [HttpPost]
    public IActionResult UpdateGroup(UpdateGroup model)
    {
        bool isUpdateStudyGroup = _database.UpdateStudyGroup(
            model.Id,
            model.Enrollment,
            model.StartDate,
            model.EndDate,
            Convert.ToDecimal(model.Price),
            model.FormsTrainingId,
            model.CityId,
            model.Duration
        );

        int[] array = model.ScheduleDays.ToArray();
        bool isUpdateScheduleDays = _database.UpdateScheduleDays(model.Id, array);

        StudyGroup NewstudyGroup = _database.GetStudyGroupById(model.Id);

        if (!isUpdateStudyGroup || !isUpdateScheduleDays || !ModelState.IsValid)
        {
            ModelState.AddModelError(string.Empty, "Не удалось обновить курс.");
            var errors = ModelState.ToDictionary(
                kvp => kvp.Key,
                kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()
            );
            return Json(new { success = false, errors });
        }

        // Логика сохранения данных

        return Json(new { success = true });
    }


    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}

