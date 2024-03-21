using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class ApplicationData
{
    public int ApplicationId { get; set; }
    public int StudyGroupId { get; set; }
    public int Enrollment { get; set; }
    public DateTime DateStart { get; set; }
    public DateTime? DateEnd { get; set; }
    public decimal? Price { get; set; }
    public int FormStudyId { get; set; }
    public int? CityId { get; set; }
    public int? Duration { get; set; }
    public int? CourseId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public DateTime Birthday { get; set; }
    public int StatusApplicationsId { get; set; }
}