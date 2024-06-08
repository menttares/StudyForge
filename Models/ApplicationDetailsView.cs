using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class ApplicationDetailsView
{
    public int ApplicationId { get; set; }
    public int GroupId { get; set; }
    public int CourseId { get; set; }
    public string CourseName { get; set; }
    public int TrainingFormId { get; set; }
    public string TrainingFormName { get; set; }
    public int CityId { get; set; }
    public string CityName { get; set; }
    public int ApplicationStatusId { get; set; }
    public string ApplicationStatusName { get; set; }
    public string ApplicantEmail { get; set; }
    public int CreatorProfileId { get; set; }
    public string CreatorEmail { get; set; }
    public string CreatorPhone { get; set; }
}