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

public class AuthController : Controller
{
    private readonly ILogger<AuthController> _logger;
    private PostgresDataService _database;

    /// <summary>
    /// Конструктор контроллера AuthController.
    /// </summary>
    /// <param name="logger">Интерфейс логгера.</param>
    /// <param name="database">Сервис работы с базой данных PostgreSQL.</param>
    public AuthController(ILogger<AuthController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }

    /// <summary>
    /// Аутентификация пользователя (GET).
    /// </summary>
    /// <returns>Результат действия, возвращающий представление для аутентификации.</returns>
    [HttpGet]
    public IActionResult Authenticate()
    {
        return View();
    }

    /// <summary>
    /// Аутентификация пользователя (POST).
    /// </summary>
    /// <param name="data">Модель данных для аутентификации.</param>
    /// <param name="ReturnUrl">URL для возврата после успешной аутентификации.</param>
    /// <returns>Результат действия, перенаправляющий на главную страницу контрольной панели в случае успеха.</returns>
    [HttpPost]
    public async Task<IActionResult> Authenticate([FromForm] AuthenticateViewModel data, string? ReturnUrl)
    {
        var resultData = _database.login_user(data.Email, data.Password);

        if (resultData.Status == ResultPostgresStatus.Ok && ModelState.IsValid)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, resultData.Result.ToString()),
                new Claim(ClaimTypes.Email, data.Email),
                new Claim(ClaimsIdentity.DefaultNameClaimType, data.Email),
                new Claim(ClaimsIdentity.DefaultRoleClaimType, "user"),
            };
            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            await HttpContext.SignInAsync(claimsPrincipal);

            return RedirectToAction("Main", "СontrolPanel");
        }

        int result = resultData.Result;
        switch (result)
        {
            case -1:
                ModelState.AddModelError("Email", "Пользователь с такой почтой не существует");
                break;
            case -2:
                ModelState.AddModelError("Password", "Неверный пароль");
                break;
            default:
                ModelState.AddModelError(string.Empty, "Извините, похоже, проблемы с сайтом, сообщите на почту studyforgeadm@gmail.com");
                break;
        }

        return View(data);
    }

    /// <summary>
    /// Регистрация нового пользователя (GET).
    /// </summary>
    /// <returns>Результат действия, возвращающий представление для регистрации.</returns>
    [HttpGet]
    public IActionResult Register()
    {
        return View();
    }

    /// <summary>
    /// Регистрация нового пользователя (POST).
    /// </summary>
    /// <param name="data">Модель данных для регистрации.</param>
    /// <param name="ReturnUrl">URL для возврата после успешной регистрации.</param>
    /// <returns>Результат действия, перенаправляющий на главную страницу контрольной панели в случае успеха.</returns>
    [HttpPost]
    public async Task<IActionResult> Register([FromForm] RegisterViewModel data, string? ReturnUrl)
    {
        var resultData = _database.register_profile(
            data.Name,
            data.LicenseNumber,
            data.Email,
            data.Password,
            data.IsOrganization,
            data.Phone
        );

        if (resultData.Status == ResultPostgresStatus.Ok && ModelState.IsValid)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, resultData.Result.ToString()),
                new Claim(ClaimTypes.Email, data.Email),
                new Claim(ClaimsIdentity.DefaultNameClaimType, data.Email),
                new Claim(ClaimsIdentity.DefaultRoleClaimType, "user"),
            };
            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            await HttpContext.SignInAsync(claimsPrincipal);

            return RedirectToAction("Main", "СontrolPanel");
        }

        int result = resultData.Result;
        switch (result)
        {
            case -1:
                ModelState.AddModelError("Email", "Пользователь с таким email уже существует");
                break;
            case -2:
                ModelState.AddModelError("LicenseNumber", "Пользователь с таким лицензией уже существует");
                break;
            case -3:
                ModelState.AddModelError("Phone", "Пользователь с таким телефоном уже существует");
                break;
            default:
                ModelState.AddModelError(string.Empty, "Извините, похоже, проблемы с сайтом, сообщите на почту studyforgeadm@gmail.com");
                break;
        }

        return View(data);
    }

    /// <summary>
    /// Аутентификация администратора (GET).
    /// </summary>
    /// <returns>Результат действия, возвращающий представление для аутентификации администратора.</returns>
    [HttpGet]
    public IActionResult AdminLogin()
    {
        return View();
    }

    /// <summary>
    /// Аутентификация администратора (POST).
    /// </summary>
    /// <param name="data">Модель данных для аутентификации администратора.</param>
    /// <param name="ReturnUrl">URL для возврата после успешной аутентификации.</param>
    /// <returns>Результат действия, перенаправляющий на главную страницу администратора в случае успеха.</returns>
    [HttpPost]
    public async Task<IActionResult> AdminLogin([FromForm] AuthenticateViewModel data, string? ReturnUrl)
    {
        var resultData = _database.LoginAdmin(data.Email, data.Password);

        if (resultData.Status == ResultPostgresStatus.Ok && ModelState.IsValid)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, resultData.Result.ToString()),
                new Claim(ClaimTypes.Email, data.Email),
                new Claim(ClaimsIdentity.DefaultNameClaimType, data.Email),
                new Claim(ClaimsIdentity.DefaultRoleClaimType, "admin"),
            };
            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            await HttpContext.SignInAsync(claimsPrincipal);

            return RedirectToAction("Main", "Admin");
        }
        
        int result = resultData.Result;
        switch (result)
        {
            case -1:
                ModelState.AddModelError("Email", "Пользователь с такой почтой не существует");
                break;
            case -2:
                ModelState.AddModelError("Password", "Неверный пароль");
                break;
            default:
                ModelState.AddModelError(string.Empty, "Извините, похоже, проблемы с сайтом, сообщите на почту studyforgeadm@gmail.com");
                break;
        }

        return View(data);
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
}