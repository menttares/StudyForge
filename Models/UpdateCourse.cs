using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class UpdateCourse
{
    
    [Required(ErrorMessage = "Поле обязательно для заполнения")]
    public int CourseId { get; set; }

    [Required(ErrorMessage = "Поле обязательно для заполнения")]
    public int SectionId { get; set; }

    [Required(ErrorMessage = "Поле названия курса обязательно для заполнения")]
    [RegularExpression(@"^(?=.*[A-Za-zА-Яа-я])(?=.*[A-Za-zА-Яа-я]).{3,100}$", ErrorMessage = "Имя должен быть от 3 до 100 символов и содержать минимум 2 буквенных символа")]
    public string CourseName { get; set; }

    
    [StringLength(1000, ErrorMessage = "Описание должен быть не длиннее 1000 символов")]
    [AllowNull]
    public string? CourseDescription { get; set; }

    public bool CourseClosed { get; set; }
}