using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class UpdateGroup
{
    public int Id { get; set; }

    [Range(1, 299, ErrorMessage = "Набор должен быть от 1 до 299")]
    public int Enrollment { get; set; }

    [Required(ErrorMessage = "Дата начала набора обязательна")]
    public DateTime StartDate { get; set; }

    [DateEndValidation(ErrorMessage = "Дата окончания набора должна быть после даты начала")]
    public DateTime? EndDate { get; set; }

    [RegularExpression(@"\d+,\d{2}", ErrorMessage = "Цена должна быть в формате 00,00")]
    public string Price { get; set; }

    public int? FormsTrainingId { get; set; }
    public int? CityId { get; set; }

    [Range(1, 4999, ErrorMessage = "Длительность должна быть от 1 до 4999")]
    public int Duration { get; set; }

    public int CourseId { get; set; }

    public List<int>? ScheduleDays { get; set; }


    public class DateEndValidationAttribute : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            DateTime? endDate = value as DateTime?;
            if (endDate.HasValue)
            {
                // Получаем значение свойства StartDate
                var property = validationContext.ObjectType.GetProperty("StartDate");
                if (property != null)
                {
                    var startDate = (DateTime)property.GetValue(validationContext.ObjectInstance);
                    if (endDate.Value < startDate)
                    {
                        return new ValidationResult("Дата окончания набора должна быть после даты начала набора");
                    }
                }
            }

            return ValidationResult.Success;
        }
    }

}