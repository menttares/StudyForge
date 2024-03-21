using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

[Serializable]
public class CourseModel
{
    public int CourseId { get; set; }
    public string CourseName { get; set; } = string.Empty;
    public string CourseDescription { get; set; } = string.Empty;
    public DateTime CourseCreatedAt { get; set; }
    public bool CourseClosed { get; set; }
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public int ProfileId { get; set; }
    public string ProfileName { get; set; } = string.Empty;
    public bool ProfileIsOrganization { get; set; }
    public string ProfileAboutMe { get; set; } = string.Empty;
    public string ProfileSpecialization { get; set; } = string.Empty;
    public bool? ProfileConfirmation { get; set; }
}
