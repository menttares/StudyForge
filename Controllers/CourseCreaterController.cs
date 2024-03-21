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


public class CourseCreaterController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private PostgresDataService _database;

    public CourseCreaterController(ILogger<HomeController> logger, PostgresDataService database)
    {
        _logger = logger;
        _database = database;
    }

    [HttpPost]
    public IActionResult Create() {
        
        
        return Ok();
    }


    public IActionResult Course() {
        
        return Ok();
    }
}
