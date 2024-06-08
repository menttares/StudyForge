using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class CourseStatistics
{
    public string SectionName { get; set; }
    public int CourseCount { get; set; }
}
