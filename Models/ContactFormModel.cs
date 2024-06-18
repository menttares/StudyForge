using System.ComponentModel.DataAnnotations;

namespace StudyForge.Models;
 public class ContactFormModel
    {
        public int IdStudyGroup { get; set; }
        
        [Required(ErrorMessage = "Имя обязательно")]
        [RegularExpression(@"^[А-Яа-яЁёA-Za-z]+$", ErrorMessage = "Имя должно содержать только буквы")]
        [MaxLength(50, ErrorMessage = "Максимальная длина имени - 50 символов")]
        public string FirstName { get; set; }

        [Required(ErrorMessage = "Фамилия обязательна")]
        [RegularExpression(@"^[А-Яа-яЁёA-Za-z]+$", ErrorMessage = "Фамилия должна содержать только буквы")]
        [MaxLength(50, ErrorMessage = "Максимальная длина фамилии - 50 символов")]
        public string LastName { get; set; }

        [RegularExpression(@"^[А-Яа-яЁёA-Za-z]*$", ErrorMessage = "Отчество должно содержать только буквы")]
        [MaxLength(50, ErrorMessage = "Максимальная длина отчества - 50 символов")]
        public string MiddleName { get; set; }

        [Required(ErrorMessage = "Телефон обязателен")]
        [RegularExpression(@"\+375\d{2}\d{3}\d{2}\d{2}", ErrorMessage = "Неправильный формат телефона")]
        public string Phone { get; set; }

        [Required(ErrorMessage = "Дата рождения обязательна")]
        [DataType(DataType.Date)]
        [CustomValidation(typeof(ContactFormModel), "ValidateAge")]
        public DateTime Dob { get; set; }

        [Required(ErrorMessage = "Email обязателен")]
        [EmailAddress(ErrorMessage = "Неправильный формат email")]
        [MaxLength(100, ErrorMessage = "Максимальная длина email - 100 символов")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Необходимо согласие на обработку данных")]
        public bool Agreement { get; set; }

        public static ValidationResult ValidateAge(DateTime dob, ValidationContext context)
        {
            var age = DateTime.Today.Year - dob.Year;
            if (dob > DateTime.Today.AddYears(-age)) age--;

            return age >= 18 ? ValidationResult.Success : new ValidationResult("Возраст должен быть не менее 18 лет");
        }
    }