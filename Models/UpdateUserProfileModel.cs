using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class UpdateUserProfileModel
{

    [Required(ErrorMessage = "Поле 'Имя' обязательно для заполнения")]
    [RegularExpression(@"^[А-Яа-яA-Za-z ]{3,100}$", ErrorMessage = "Имя должен быть от 3 до 100")]
    
    public string name { get; set; }

    [StringLength(1000, ErrorMessage = "Описание должен быть не длиннее 1000 символов")]
    [AllowNull]
    public string aboutMe { get; set; } = "";

    public int? specializationId { get; set; }

    [Required(ErrorMessage = "Поле 'Email' обязательно для заполнения")]
    [EmailAddress(ErrorMessage = "Некорректный формат адреса электронной почты")]
    [StringLength(100, ErrorMessage = "Email должен быть не длиннее 100 символов")]
    public string email { get; set; }

    [Required(ErrorMessage = "Поле телефона обязательно для заполнения")]
    [RegularExpression(@"^(\+375)(29|33|44|25|17)(\d{3})(\d{2})(\d{2})$", ErrorMessage = "Телефон должен быть в формате +375(код абанента)XXX-XX-XX")]
    public string phone { get; set; }


}