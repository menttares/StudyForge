using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class CategoryWithSubsections
{
    public string CategoryName { get; set; } = string.Empty;
    public List<Subsection> Subsections { get; set; } = new();
}

public class Subsection
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}