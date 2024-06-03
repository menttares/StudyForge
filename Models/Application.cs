using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class Application
{
    public int Id { get; set; }
    public int IdStudyGroup { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Surname { get; set; }
    public string Phone { get; set; }
    public DateTime Birthday { get; set; }
    public string Email { get; set; }
    public int IdStatusApplications { get; set; }
    public DateTime SubmissionDate { get; set; }
}