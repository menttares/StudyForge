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
[Authorize(Roles = "user")]
public class СontrolPanelController : Controller
{
    private readonly ILogger<СontrolPanelController> _logger;
    private readonly IEmailService _emailService;
    private PostgresDataService _database;

    /// <summary>
    /// Конструктор контроллера ControlPanelController.
    /// </summary>
    /// <param name="logger">Интерфейс логгера.</param>
    /// <param name="database">Сервис работы с базой данных PostgreSQL.</param>
    /// <param name="emailService">Сервис отправки электронной почты.</param>
    public СontrolPanelController(ILogger<СontrolPanelController> logger, PostgresDataService database, IEmailService emailService)
    {
        _logger = logger;
        _database = database;
        _emailService = emailService;
    }

    /// <summary>
    /// Главная страница контрольной панели.
    /// </summary>
    /// <returns>Результат действия, возвращающий представление.</returns>
    [HttpGet("[Controller]")]
    public IActionResult Main()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);
        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (Confirmation)
        {

            return View();
        }

        return View("Block");
    }

    /// <summary>
    /// Домашняя страница контрольной панели.
    /// </summary>
    /// <returns>Результат действия, возвращающий частичное представление.</returns>
    public IActionResult Home()
    {
        return PartialView();
    }

    /// <summary>
    /// Выход из системы.
    /// </summary>
    /// <returns>Результат действия, перенаправляющий на главную страницу.</returns>
    public IActionResult LogOut()
    {
        var cookieNames = HttpContext.Request.Cookies.Keys.ToArray();
        foreach (var cookieName in cookieNames)
        {
            HttpContext.Response.Cookies.Delete(cookieName);
        }

        HttpContext.SignOutAsync();

        return RedirectToAction("Index", "Home");
    }

    /// <summary>
    /// Статистика пользователя.
    /// </summary>
    /// <returns>Результат действия, возвращающий частичное представление со статистикой.</returns>
    public IActionResult Statistics()
    {

        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);

        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        List<ApplicationsPerCourse> data = _database.GetCourseApplicationsStatisticsByCreatorId(id);

        return PartialView(data);
    }

    /// <summary>
    /// Заявки пользователя.
    /// </summary>
    /// <returns>Результат действия, возвращающий частичное представление со списком заявок.</returns>
    public IActionResult Applications()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);

        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        List<Course> CourseInfo = _database.GetCoursesByProfile(id);

        return PartialView(CourseInfo);
    }

    /// <summary>
    /// Получение заявок по курсу и статусу.
    /// </summary>
    /// <param name="courseId">Идентификатор курса.</param>
    /// <param name="statusId">Идентификатор статуса заявки (необязательный).</param>
    /// <returns>Результат действия, возвращающий список деталей заявок в формате JSON.</returns>
    [HttpGet]
    public IActionResult GetApplications(int courseId, int? statusId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);

        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }
        List<ApplicationDetails> applications = _database.GetApplications(courseId, statusId);
        return Json(applications);
    }

    /// <summary>
    /// Изменение статуса заявки.
    /// </summary>
    /// <param name="applicationId">Идентификатор заявки.</param>
    /// <param name="newStatus">Новый статус заявки.</param>
    /// <returns>Результат действия, возвращающий статус операции.</returns>
    [HttpPut("/СontrolPanel/ChangeApplicationStatus/{applicationId}/{newStatus}")]
    public async Task<IActionResult> ChangeApplicationStatus(int applicationId, int newStatus)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);

        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        try
        {
            bool isUpdate = _database.UpdateApplicationStatus(applicationId, newStatus);

            if (!isUpdate)
            {
                return BadRequest();
            }

            ApplicationDetailsView app = _database.GetApplicationDetails(applicationId);
            if (app == null)
            {
                return BadRequest();
            }

            string Message = "";
            if (app.ApplicationStatusName == "принято")
            {
                Message = $@"
                    Ваша заявка на курс {app.CourseName} принята!
                    С вами должен созвониться организатор курса
                    
                    Связь с организатором:
                    Почта: {app.CreatorEmail}
                    Телефон: {app.CreatorPhone}
                    """;
            }
            else if (app.ApplicationStatusName == "отклонено")
            {
                Message = $@"
                    Ваша заявка на курс {app.CourseName} отклонена!
                    """;
            }
            else if (app.ApplicationStatusName == "ожидание")
            {
                Message = $@"
                    Ваша заявка на курс {app.CourseName} в ожидаемом
                    Ждите ответа от организатора
                    """;
            }
            else
            {
                throw new Exception("Не правильный ApplicationStatus");
            }

            await _emailService.SendEmailAsync(app.ApplicantEmail, "Ваша Заявка", Message);

            return Ok();
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex.Message);
            return BadRequest();
        }
    }

    /// <summary>
    /// Профиль пользователя.
    /// </summary>
    /// <returns>Результат действия, возвращающий частичное представление с профилем пользователя.</returns>
    public IActionResult Profile()
    {

        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        ViewData["User"] = _database.GetUserProfileInfo(id);

        return PartialView();
    }

    /// <summary>
    /// Редактирование профиля пользователя (GET).
    /// </summary>
    /// <returns>Результат действия, возвращающий представление для редактирования профиля.</returns>
    public IActionResult EditProfile()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        UserProfileInfo user = _database.GetUserProfileInfo(id);

        UpdateUserProfileModel model = new()
        {
            name = user.Name,
            aboutMe = user.AboutMe,
            email = user.Email,
            phone = user.Phone
        };

        return View(model);
    }

    /// <summary>
    /// Редактирование профиля пользователя (POST).
    /// </summary>
    /// <param name="data">Модель данных для обновления профиля.</param>
    /// <returns>Результат действия, возвращающий JSON с результатом операции.</returns>
    [HttpPost]
    public IActionResult EditProfile(UpdateUserProfileModel data)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        bool isUpdate = _database.UpdateUserProfile(
            id,
            data.name,
            data.aboutMe,
            data.email,
            data.phone
        );

        if (!isUpdate)
        {
            var errors = ModelState.ToDictionary(
                kvp => kvp.Key,
                kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()
            );
            return Json(new { success = false, errors });
        }

        return Json(new { success = true });
    }

    /// <summary>
    /// Курсы пользователя.
    /// </summary>
    /// <returns>Результат действия, возвращающий частичное представление с информацией о курсах пользователя.</returns>
    public IActionResult Courses()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        List<Course> CourseInfo = _database.GetCoursesByProfile(id);

        return PartialView(CourseInfo);
    }

    /// <summary>
    /// Создание нового курса (POST).
    /// </summary>
    /// <returns>Результат действия, возвращающий созданный курс в формате JSON.</returns>
    [HttpPost]
    public IActionResult CreateCourses()
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        int insertedId = _database.CreateCourse(
            id,
            "Новый курс",
            1,
            "описание"
        );
        Course course = _database.GetCourseInfo(insertedId);

        return Ok(course);
    }

    /// <summary>
    /// Удаление курса (DELETE).
    /// </summary>
    /// <param name="courseId">Идентификатор курса для удаления.</param>
    /// <returns>Результат действия, возвращающий статус операции.</returns>
    [HttpDelete("/ControlPanel/DeleteCourse/{courseId}")]
    public IActionResult DeleteCourse(int courseId)
    {
        var ClaimIdentifier = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        var id = int.Parse(ClaimIdentifier.Value);


        bool Confirmation = _database.CheckAccountConfirmation(id);

        if (!Confirmation)
        { return PartialView("Block"); }

        _database.DeleteCourse(courseId);

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