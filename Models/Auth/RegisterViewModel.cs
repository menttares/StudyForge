using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
namespace StudyForge.Models;

public class RegisterViewModel
{

    
    [Required(ErrorMessage = "Поле 'Имя' обязательно для заполнения")]
    [RegularExpression(@"^[А-Яа-яA-Za-z ]{3,100}$", ErrorMessage = "Имя должен быть от 3 до 100 символов, только английские и русские буквы")]
    public string Name {get; set;} = string.Empty;

    [Required(ErrorMessage = "Поле 'Email' обязательно для заполнения")]
    [EmailAddress(ErrorMessage = "Некорректный формат адреса электронной почты")]
    [StringLength(100, ErrorMessage = "Email должен быть не длиннее 100 символов")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Поле пароля обязательно для заполнения")]
    [DataType(DataType.Password)]
    [RegularExpression(@"^[a-zA-z\d\@\+\\#!-]{5,20}$", ErrorMessage = "Пароль должен быть от 5 до 20 символов и содержать буквы, цифры и символы @, +, \\, #, !, -")]
    public string Password { get; set; } = string.Empty;
    
    [Required(ErrorMessage = "Поле телефона обязательно для заполнения")]
    [RegularExpression(@"^(\+375)(29|33|44|25|17)(\d{3})(\d{2})(\d{2})$", ErrorMessage = "Телефон должен быть в форме +375(код абанента)XXX-XX-XX")]
    public string Phone {get; set;} = string.Empty;

    // Юридическое лицо?
    public bool IsOrganization {get; set;}  = false;

    // Номер лицензии
    [Required(ErrorMessage = "Поле номера лицензии обязательно для заполнения")]
    [RegularExpression(@"^(01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20)\d{2}\d{6}\d{2}$", ErrorMessage = "Некорректный формат номера лицензии")]
    public string LicenseNumber {get; set;} = string.Empty;

}