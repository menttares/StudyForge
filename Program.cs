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
        options.AccessDeniedPath = "/accessdenied";
    });
    
builder.Services.AddAuthorization();
builder.Services.AddHttpContextAccessor();
builder.Services.Configure<SmtpSettings>(builder.Configuration.GetSection("SmtpSettings"));
builder.Services.AddTransient<IEmailService, EmailService>();

// builder.Services.AddAuthorization();

// //builder.Services.AddSingleton<TokenService>();
// builder.Services.AddAuthentication(options =>
// {
//     options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
//     options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
// }).AddJwtBearer(options =>
//     {

//         options.TokenValidationParameters = new TokenValidationParameters
//         {
//             // указывает, будет ли валидироваться издатель при валидации токена
//             ValidateIssuer = true,
//             // строка, представляющая издателя
//             ValidIssuer = TokenService.ISSUER,
//             // будет ли валидироваться потребитель токена
//             ValidateAudience = true,
//             // установка потребителя токена
//             ValidAudience = TokenService.AUDIENCE,
//             // будет ли валидироваться время существования
//             ValidateLifetime = true,
//             // установка ключа безопасности
//             IssuerSigningKey = TokenService.GetSymmetricSecurityKey(),
//             // валидация ключа безопасности
//             ValidateIssuerSigningKey = true,


//         };
//         options.Events = new JwtBearerEvents
//         {
//             OnMessageReceived = context =>
//             {
//                 context.Token = context.Request.Cookies["jwtToken"];
//                 return Task.CompletedTask;
//             }
//         };
//     });



// Получает строку подключения к базе данных
string? connectionString = builder.Configuration.GetConnectionString("ADO.NET");
// Подключение сервиса для взаимодействия с БД postgres
builder.Services.AddTransient<PostgresDataService>(_ => new PostgresDataService(connectionString));


if (builder.Environment.IsDevelopment())
{
    // Подключаем динамическую подгрузку, если зафиксированы изменения razor
    builder.Services.AddControllersWithViews().AddRazorRuntimeCompilation();


    //Избыточно
    // var viewsPath = Path.Combine(builder.Environment.ContentRootPath, "Views");
    // var wwwrootPath = Path.Combine(builder.Environment.ContentRootPath, "wwwroot");
    // // Добавляем FileProviders для Views и wwwroot
    // builder.Services.Configure<MvcRazorRuntimeCompilationOptions>(options =>
    // {
    //     options.FileProviders.Add(new PhysicalFileProvider(viewsPath));
    //     options.FileProviders.Add(new PhysicalFileProvider(wwwrootPath));
    // });
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

// app.Use(async (context, next) =>
//     {
//         string userIpAddress = context.Connection.RemoteIpAddress.ToString();
//         string userAgent = context.Request.Headers["User-Agent"];

//         var loggerFactory = context.RequestServices.GetRequiredService<ILoggerFactory>();
//         var logger = loggerFactory.CreateLogger<Program>();
//         logger.LogInformation($@"
        
//             Request: {context.Request.Path}
//             Method: {context.Request.Method}
//             Scheme: {context.Request.Scheme}
//             User IP: {userIpAddress}
//             User Agent: {userAgent}
//             ");

//         await next.Invoke();
//     });

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();