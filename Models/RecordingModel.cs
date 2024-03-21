using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;



public class RecordingModel
{
    public int Id { get; set; }
    public int StudyGroupId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public DateTime Birthday { get; set; }
    public int StatusId { get; set; }
}