using Microsoft.AspNetCore.Html;        // для HtmlString
using Microsoft.AspNetCore.Mvc.Rendering; 

namespace StudyForge.Helpers
{
    public static class AdminHelper
    {
        public static HtmlString CreateList(this IHtmlHelper html, string[] items)
        {
            string result = "<ul>";
            return new HtmlString(result);
        }
    }
}