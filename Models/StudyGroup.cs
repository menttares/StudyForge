using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class StudyGroup
{
    public int Id { get; set; }
    public int Enrollment { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public decimal Price { get; set; }
    public int FormsTrainingId { get; set; }
    public int CityId { get; set; }
    public int Duration { get; set; }
    public int CourseId { get; set; }
    public int AcceptedApplicationsCount { get; set; }
    public List<ScheduleDay> ScheduleDays { get; set; }
}