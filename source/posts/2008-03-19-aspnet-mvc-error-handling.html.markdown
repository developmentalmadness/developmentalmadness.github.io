---
layout: post
title: ASP.NET MVC Error Handling
date: '2008-03-19 19:08:00'
tags:
- error_handling
- asp_net_mvc
---

When working with the latest MVC release (Preview 2) I was having trouble working with the Application_Error event in global.asax. While this does work if you want to redirect to an html file, if you want to redirect to an aspx file you need to use the Controller.OnActionExecuted method. Here's an example:

        protected override void OnActionExecuted(FilterExecutedContext filterContext)
       {
           if (filterContext.Exception != null)
           {
               Exception ex = filterContext.Exception;
               if (ex.InnerException != null)
                   ex = ex.InnerException;

               filterContext.ExceptionHandled = true;

               RedirectToAction(new RouteValueDictionary(new
               {
                   Controller = "Error",
                   Action = "Error",
                   Message = ex.Message
               }));
           }
          
           base.OnActionExecuted(filterContext);
       }

**UPDATE 7/8/09:** as of the final RTM for MVC the signature for OnActionExecuted has changed, it now reads : void OnActionExecuted(ActionExecutedContext). Thanks to jobr31 for reminding me to update the information.

I imagine if you wanted to use Application_Error you could use a different extension, like ".err" and configure ASP.NET to map the extension to the Page HttpHandler. But it seems like too much work to me to even try it when this works perfectly fine.

A more extensible method would be to use Action Filters. I have seen an example demonstrated by Troy Goode, but I haven't tried it yet.

