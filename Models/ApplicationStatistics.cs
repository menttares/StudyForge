using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class ApplicationStatistics
{
    public int CourseId { get; set; }
    public string CourseName { get; set; }
    public int TotalAcceptedApplications { get; set; }
}