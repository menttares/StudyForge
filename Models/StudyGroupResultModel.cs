using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
using Newtonsoft.Json;
namespace StudyForge.Models;

[Serializable]
public class StudyGroupResultModel
{
    public int GroupId { get; set; }
    public int Enrollment { get; set; }
    public DateTime DateStart { get; set; }
    public DateTime DateEnd { get; set; }
    public decimal Price { get; set; }
    public int FormOfStudyId { get; set; }
    public string FormOfStudyName { get; set; } = string.Empty;
    public int CityId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public int Duration { get; set; }
    public int CourseId { get; set; }
    public string CourseName { get; set; } = string.Empty;
    public string CourseDescription { get; set; } = string.Empty;
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public int ProfileId { get; set; }
    public string ProfileName { get; set; } = string.Empty;
    public bool IsOrganization { get; set; }
    public int AcceptedApplicationsCount { get; set; }
    public string StudyDays { get; set; } = string.Empty;
}
