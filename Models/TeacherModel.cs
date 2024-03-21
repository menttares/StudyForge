using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class TeacherModel
{
    public int TeacherId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string AboutMe { get; set; } = string.Empty;
    public string Skills { get; set; } = string.Empty;
    public string Specialization { get; set; } = string.Empty;
}