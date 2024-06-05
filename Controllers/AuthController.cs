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

        if (resutlData.Status == ResultPostgresStatus.Ok)
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
        else if (resutlData.Status == ResultPostgresStatus.PostgresError || resutlData.Status == ResultPostgresStatus.Exception)
        {
            return StatusCode(500, "Внутрення ошибка. Пожалуйста, войдите позже");
        }
        else if (resutlData.Status == ResultPostgresStatus.ValidDataError)
        {
            return StatusCode(200, $"Неверные данные формы: {resutlData.Message}");
        }

        return RedirectToAction("Index", "Home");
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

        if (resutlData.Status == ResultPostgresStatus.Ok)
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
        else if (resutlData.Status == ResultPostgresStatus.PostgresError || resutlData.Status == ResultPostgresStatus.Exception)
        {
            return StatusCode(500, "Внутрення ошибка. Пожалуйста, войдите позже");
        }
        else if (resutlData.Status == ResultPostgresStatus.ValidDataError)
        {
            return StatusCode(200, $"Неверные данные формы: {resutlData.Message}");
        }

        return RedirectToAction("Index", "Home");
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

        if (resutlData.Status == ResultPostgresStatus.Ok)
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
        }
        else
        {
            return StatusCode(200, resutlData.Message);
        }

        return RedirectToAction("Index", "Home");
    }

}
