using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class ApplicationsPerCourse
{
    public int CourseId { get; set; }
    public string CourseName { get; set; }
    public int ApplicationCount { get; set; }
    public int CreatorId { get; set; }
}