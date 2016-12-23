﻿#pragma warning disable 1591
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace ASP
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Net;
    using System.Text;
    using System.Web;
    using System.Web.Helpers;
    using System.Web.Mvc;
    using System.Web.Mvc.Ajax;
    using System.Web.Mvc.Html;
    using System.Web.Routing;
    using System.Web.Security;
    using System.Web.UI;
    using System.Web.WebPages;
    using Frapid.Configuration;
    using Frapid.Dashboard;
    using Frapid.DataAccess;
    using Frapid.DbPolicy;
    using Frapid.Framework;
    using Frapid.i18n;
    using Frapid.Messaging;
    using Frapid.WebsiteBuilder;
    using MixERP.Finance;
    
    #line 1 "..\..\Views\Tasks\JournalVerification\Index.cshtml"
    using MixERP.Finance.Extensions;
    
    #line default
    #line hidden
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("RazorGenerator", "2.0.0.0")]
    [System.Web.WebPages.PageVirtualPathAttribute("~/Views/Tasks/JournalVerification/Index.cshtml")]
    public partial class _Views_Tasks_JournalVerification_Index_cshtml : System.Web.Mvc.WebViewPage<dynamic>
    {
        public _Views_Tasks_JournalVerification_Index_cshtml()
        {
        }
        public override void Execute()
        {
            
            #line 4 "..\..\Views\Tasks\JournalVerification\Index.cshtml"
  
    ViewBag.Title = "Journal Verification";
    Layout = ViewBag.FinanceLayoutPath;

            
            #line default
            #line hidden
WriteLiteral("\r\n\r\n\r\n");

            
            #line 10 "..\..\Views\Tasks\JournalVerification\Index.cshtml"
Write(Html.PartialView("Shared/Verification.cshtml", TenantConvention.GetTenant()));

            
            #line default
            #line hidden
WriteLiteral(@"

<script>
    window.prepareVerification({
        Title: ""Journal Entry Verification"",
        AddNewText: ""Add New"",
        AddNewUrl: ""/dashboard/finance/tasks/journal/entry/new"",
        Book: ""Journal Entry"",
        ChecklistUrl: ""/dashboard/finance/tasks/journal/checklist/{tranId}""
    });

    function showInvoice(tranId) {
        $("".advice.modal iframe"").attr(""src"", ""/dashboard/reports/source/Areas/MixERP.Finance/Reports/JournalEntry.xml?transaction_master_id="" + tranId);

        setTimeout(function () {
            $("".advice.modal"")
                .modal('setting', 'transition', 'horizontal flip')
                .modal(""show"");

        }, 300);
    };
</script>");

        }
    }
}
#pragma warning restore 1591
