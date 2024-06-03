using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class UpdateUserProfileModel
{
    public string name {get; set;}
    public string aboutMe {get; set;}
    public int specializationId {get;set;}
}