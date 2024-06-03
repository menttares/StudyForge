using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using StudyForge.Services;

namespace StudyForge.Services
{
    public class AdminService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public AdminService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public bool IsAdmin()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            if (httpContext == null)
            {
                return false;
            }

            var user = httpContext.User;
            return user.Identity.IsAuthenticated && user.IsInRole("admin");
        }
    }
}


