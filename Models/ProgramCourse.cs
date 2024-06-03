using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class ProgramCourse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int CourseId { get; set; }
}