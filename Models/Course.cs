using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class Course
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; }
    public int SectionId { get; set; }
    public string SectionName { get; set; }
    public int CourseId { get; set; }
    public string CourseName { get; set; }
    public string CourseDescription { get; set; }
    public DateTime CourseCreatedAt { get; set; }
    public bool CourseClosed { get; set; }
    public int AccountId { get; set; }
}