using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;


public class TokenService
{

    public static string ISSUER = "StudyForge"; // издатель токена
    public static string AUDIENCE = "StudyForgeClient"; // потребитель токена

    /// <summary>
    /// Секретный ключ для генерации токена
    /// Рекомендуется сделать ключ большим по символам, так как длины может не хватить для шифрования по RSA256
    /// </summary>
    private static string KEY = "OmniaMeaMecumPortoOmniaMeaMecumPortoOmniaMeaMecumPortoOmniaMeaMecumPortoOmniaMeaMecumPorto";

    public static SymmetricSecurityKey GetSymmetricSecurityKey() =>
    new SymmetricSecurityKey(Encoding.UTF8.GetBytes(KEY));

    // Метод для создания JWT токена
    public string GenerateJwtToken(string userId, string role, DateTime expirationDate)
    {
        if (DateTime.Now <= expirationDate)
        {
            throw new ArgumentException("аргумент expirationDate обязан быть больше сегодняшней даты или времени");
        }

        // Секретный ключ для подписи токена
        var secretKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(KEY));


        // Определение параметров токена
        var claims = new List<Claim> { new Claim(ClaimTypes.NameIdentifier, userId) };
        // создаем JWT-токен
        var jwt = new JwtSecurityToken(
                issuer: TokenService.ISSUER,
                audience: TokenService.AUDIENCE,
                claims: claims,
                expires: DateTime.UtcNow.Add(TimeSpan.FromMinutes(2)),
                signingCredentials: new SigningCredentials(TokenService.GetSymmetricSecurityKey(), SecurityAlgorithms.HmacSha256));
        var encodedJwt = new JwtSecurityTokenHandler().WriteToken(jwt);

        // Возвращение строкового представления токена
        return encodedJwt;
    }
}
