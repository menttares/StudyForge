using StudyForge.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Authentication.Cookies;
using StudyForge.Models;
using Microsoft.AspNetCore.Authentication;

var builder = WebApplication.CreateBuilder(args);

// Указывает логгеру по какому пути и в какой файл записывать все логги сообщений
builder.Logging.AddFile(Path.Combine(Directory.GetCurrentDirectory(), "logger.log"));
builder.Services.AddControllersWithViews();

// подключение авторизации и регистрации
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Auth/Authenticate";
        options.AccessDeniedPath = "/Home/Noaccess";
    });
    
builder.Services.AddAuthorization();
builder.Services.AddHttpContextAccessor();
// Сервис для отравки почты
builder.Services.Configure<SmtpSettings>(builder.Configuration.GetSection("SmtpSettings"));
builder.Services.AddTransient<IEmailService, EmailService>();


// Получает строку подключения к базе данных
string? connectionString = builder.Configuration.GetConnectionString("ADO.NET");
// Подключение сервиса для взаимодействия с БД postgres
builder.Services.AddTransient<PostgresDataService>(_ => new PostgresDataService(connectionString));


if (builder.Environment.IsDevelopment())
{
    // Подключаем динамическую подгрузку, если зафиксированы изменения razor
    builder.Services.AddControllersWithViews().AddRazorRuntimeCompilation();
}


var app = builder.Build();
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}
app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();   

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();