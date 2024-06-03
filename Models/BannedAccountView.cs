using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class BannedCourseView
{
    public int BanId { get; set; }
    public string Cause { get; set; }
    public int CourseId { get; set; }
    public string CourseName { get; set; }
    public int AdminId { get; set; }
    public string AdminName { get; set; }
    public DateTime BannedAt { get; set; }
}

