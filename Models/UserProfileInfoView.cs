using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;


public class UserProfileInfo
{
    public int AccountId { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string AboutMe { get; set; } = string.Empty;
    public string LicenseNumber { get; set; } = string.Empty;
    public bool Confirmation { get; set; }
    public DateTime AccountCreatedAt { get; set; }
}