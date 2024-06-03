using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;

public class SearchModel {
    public int? SectionId { get; set; }

    public DateTime? StartDate { get; set; } = null;

    public DateTime? EndDate { get; set; } = null;

    public decimal? MinPrice { get; set; }

    public decimal? MaxPrice { get; set; }

    public int? DurationHours { get; set; }

    public bool Organization { get; set; } = false;

    public bool FreeStudyGroup { get; set; } = false;

    public string SearchQuery { get; set; } = string.Empty;

}