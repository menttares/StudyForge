using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class CourseAndGroupView
{
    public int CourseId { get; set; }
    public string CourseName { get; set; }
    public string CourseDescription { get; set; }
    public int SectionId { get; set; }
    public string SectionName { get; set; }
    public string CreatorName { get; set; }
    public string CreatorEmail { get; set; }
    public string CreatorPhone { get; set; }
    public bool CreatorIsOrganization { get; set; }
    public int GroupId { get; set; }
    public int GroupEnrollment { get; set; }
    public DateTime GroupDateStart { get; set; }
    public decimal GroupPrice { get; set; }
    public int GroupDuration { get; set; }
    public int AcceptedApplicationsCount { get; set; }
    public string? ScheduleDays { get; set; }
    public bool CourseClosed { get; set; }
    public string? FormTrainingName { get; set; }
    public string? CityName { get; set; }
}


// public class CourseAndGroupView
// {
//     public int CourseId { get; set; }
//     public string CourseName { get; set; }
//     public string CourseDescription { get; set; }
//     public int SectionId { get; set; }
//     public string SectionName { get; set; }
//     public string CreatorName { get; set; }
//     public string CreatorEmail { get; set; }
//     public string CreatorPhone { get; set; }
//     public bool CreatorIsOrganization { get; set; }
//     public int GroupId { get; set; }
//     public int GroupEnrollment { get; set; }
//     public DateTime GroupDateStart { get; set; }
//     public DateTime? GroupDateEnd { get; set; }
//     public decimal GroupPrice { get; set; }
//     public int GroupDuration { get; set; }
//     public int AcceptedApplicationsCount { get; set; }
//     public string ScheduleDays { get; set; }
//     public bool CourseClosed { get; set; }
// }