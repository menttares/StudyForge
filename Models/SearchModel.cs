using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;

namespace StudyForge.Models;



public class SearchModel
{
    public int? idCategory {get; set;}
    public string? searchStr {get; set;}
    public decimal? startPrice {get; set;}

    public decimal? endPrice {get; set;}

    public DateTime? startDate {get; set;}

    public int? idFormStudy {get; set;}

}