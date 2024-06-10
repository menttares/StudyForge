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

    public AuthController(ILogger<AuthController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }

    [HttpGet]
    public IActionResult Authenticate()
    {
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Authenticate([FromForm] AuthenticateViewModel data, string? ReturnUrl)
    {

        var resutlData = _database.login_user(data.Email, data.Password);

        if (resutlData.Status == ResultPostgresStatus.Ok && ModelState.IsValid)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, resutlData.Result.ToString()),
                new Claim(ClaimTypes.Email, data.Email),
                new Claim(ClaimsIdentity.DefaultNameClaimType, data.Email),
                new Claim(ClaimsIdentity.DefaultRoleClaimType, "user"),
            };
            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            await HttpContext.SignInAsync(claimsPrincipal);

            return RedirectToAction("Index", "Home");
        }

        int result = resutlData.Result;
        switch (result)
        {
            case -1:
                ModelState.AddModelError("Email", "Пользователь с такой почтой не существует");
                break;
            case -2:
                ModelState.AddModelError("Password", "Неверный пароль");
                break;
            default:
                ModelState.AddModelError(string.Empty, "Извините, походу проблемы с сайтом, сообщете на почту studyforgeadm@gmail.com");
                break;
        }

        return View(data);
    }

    [HttpGet]
    public IActionResult Register()
    {
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Register([FromForm] RegisterViewModel data, string? ReturnUrl)
    {
        var resutlData = _database.register_profile(
            data.Name,
            data.LicenseNumber,
            data.Email,
            data.Password,
            data.IsOrganization,
            data.Phone
        );

        if (resutlData.Status == ResultPostgresStatus.Ok && ModelState.IsValid)
        {
            var claims = new List<Claim>
            {
            new Claim(ClaimTypes.NameIdentifier, resutlData.Result.ToString()),
            new Claim(ClaimTypes.Email, data.Email),
            new Claim(ClaimsIdentity.DefaultNameClaimType, data.Email),
            new Claim(ClaimsIdentity.DefaultRoleClaimType, "user"),
            };
            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            await HttpContext.SignInAsync(claimsPrincipal);
        }

        int result = resutlData.Result;
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
                ModelState.AddModelError(string.Empty, "Извините, походу проблемы с сайтом, сообщете на почту studyforgeadm@gmail.com");
                break;
        }

        return View(data);
    }


    [HttpGet]
    public IActionResult AdminLogin()
    {
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> AdminLogin([FromForm] AuthenticateViewModel data, string? ReturnUrl)
    {


        var resutlData = _database.LoginAdmin(data.Email, data.Password);

        if (resutlData.Status == ResultPostgresStatus.Ok && ModelState.IsValid)
        {
            var claims = new List<Claim>
            {
            new Claim(ClaimTypes.NameIdentifier, resutlData.Result.ToString()),
            new Claim(ClaimTypes.Email, data.Email),
            new Claim(ClaimsIdentity.DefaultNameClaimType, data.Email),
            new Claim(ClaimsIdentity.DefaultRoleClaimType, "admin"),
            };
            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            await HttpContext.SignInAsync(claimsPrincipal);

            return RedirectToAction("Index", "Home");
        }
        
        int result = resutlData.Result;
        switch (result)
        {
            case -1:
                ModelState.AddModelError("Email", "Пользователь с такой почтой не существует");
                break;
            case -2:
                ModelState.AddModelError("Password", "Неверный пароль");
                break;
            default:
                ModelState.AddModelError(string.Empty, "Извините, походу проблемы с сайтом, сообщете на почту studyforgeadm@gmail.com");
                break;
        }

        return View(data);

    }


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
