using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;
public class AuthenticateViewModel
{
    [Required(ErrorMessage = "Поле 'Email' обязательно для заполнения")]
    [EmailAddress(ErrorMessage = "Некорректный формат адреса электронной почты")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Поле Password обязательно для заполнения")]
    [DataType(DataType.Password)]
    [RegularExpression(@"^[a-zA-z\d\@\+\\#!-]{5,20}$", ErrorMessage = "Пароль должен быть от 5 до 20 символов и содержать буквы, цифры и символы @, +, \\, #, !, -")]
    public string Password { get; set; } = string.Empty;
    
}