using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class CourseViewModel
{
    public int CourseId { get; set; }
    public string CourseName { get; set; } = string.Empty;
    public int SectionId { get; set; }
    public string Description { get; set; } = string.Empty;
    public bool Closed { get; set; }

}