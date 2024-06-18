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

    /// <summary>
    /// Конструктор контроллера CourseEditorController.
    /// </summary>
    /// <param name="logger">Интерфейс логгера.</param>
    /// <param name="database">Сервис работы с базой данных PostgreSQL.</param>
    public CourseEditorController(ILogger<CourseEditorController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }

    /// <summary>
    /// Просмотр курса.
    /// </summary>
    /// <param name="CourseId">Идентификатор курса.</param>
    /// <returns>Результат действия, возвращающий представление для просмотра курса.</returns>
    public IActionResult Course(int CourseId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return View("Block"); }

        ViewData["CourseId"] = CourseId;
        return View();
    }

    /// <summary>
    /// Главная информация о курсе (GET).
    /// </summary>
    /// <param name="CourseId">Идентификатор курса.</param>
    /// <returns>Результат действия, возвращающий частичное представление с основной информацией о курсе.</returns>
    [HttpGet]
    public IActionResult Main(int CourseId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return View("Block"); }

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

    /// <summary>
    /// Обновление информации о курсе (POST).
    /// </summary>
    /// <param name="courseViewModel">Модель данных для обновления курса.</param>
    /// <returns>Результат действия, возвращающий JSON с результатом операции.</returns>
    [HttpPost]
    public IActionResult CoursePut(UpdateCourse courseViewModel)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return View("Block"); }

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

    /// <summary>
    /// Получение групп обучения для курса.
    /// </summary>
    /// <param name="CourseId">Идентификатор курса.</param>
    /// <returns>Результат действия, возвращающий частичное представление с группами обучения для курса.</returns>
    public IActionResult StudyGroups(int CourseId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return View("Block"); }

        ViewData["CourseId"] = CourseId;
        List<StudyGroup> studyGroups = _database.GetAllStudyGroupCourse(CourseId);

        return PartialView(studyGroups);
    }

    /// <summary>
    /// Получение программ для курса.
    /// </summary>
    /// <param name="CourseId">Идентификатор курса.</param>
    /// <returns>Результат действия, возвращающий частичное представление с программами для курса.</returns>
    public IActionResult Programs(int CourseId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return View("Block"); }

        List<ProgramCourse> programs = _database.GetProgramsByCourseId(CourseId);
        ViewData["CourseId"] = CourseId;
        return PartialView(programs);
    }

    /// <summary>
    /// Создание новой программы для курса (POST).
    /// </summary>
    /// <param name="CourseId">Идентификатор курса.</param>
    /// <returns>Результат действия, возвращающий JSON с созданной программой курса.</returns>
    [HttpPost]
    public IActionResult CreateProgram(int CourseId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return View("Block"); }

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

    /// <summary>
    /// Обновление программы курса (PUT).
    /// </summary>
    /// <param name="program">Модель данных для обновления программы курса.</param>
    /// <returns>Результат действия, возвращающий успешный статус или ошибку.</returns>
    [HttpPut]
    public IActionResult UpdateProgram(ProgramCourse program)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return View("Block"); }

        bool isUpdate = _database.UpdateProgramCourse(
            program.Id,
            program.Name,
            program.Description
        );

        if (!isUpdate)
            return BadRequest();

        return Ok();
    }

    /// <summary>
    /// Удаление программы курса (DELETE).
    /// </summary>
    /// <param name="id">Идентификатор программы курса.</param>
    /// <returns>Результат действия, возвращающий успешный статус или ошибку.</returns>
    [HttpDelete]
    public IActionResult DeleteProgram(int id)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var idp = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(idp);

        if (!Confirmation)
        { return View("Block"); }

        bool isDelete = _database.DeleteProgramCourse(id);

        if (!isDelete)
            return BadRequest();

        return Ok();
    }

    /// <summary>
    /// Обработчик ошибок.
    /// </summary>
    /// <returns>Результат действия, возвращающий представление с информацией об ошибке.</returns>
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
