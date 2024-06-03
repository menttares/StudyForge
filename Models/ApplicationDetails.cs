using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class ApplicationDetails
{
    // Поля заявки
    public int ApplicationId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Surname { get; set; }
    public string Phone { get; set; }
    public DateTime Birthday { get; set; }
    public string Email { get; set; }
    public int IdStatusApplications { get; set; }
    public DateTime SubmissionDate { get; set; }

    // Поля учебной группы
    public int StudyGroupId { get; set; }
    public int Enrollment { get; set; }
    public DateTime DateStart { get; set; }
    public DateTime? DateEnd { get; set; }
    public decimal? Price { get; set; }
    public int? Duration { get; set; }
    public string FormTrainingName { get; set; }
    public string CityName { get; set; }

    // Поле курса
    public int CourseId { get; set; }
}
