---
layout: post
title: 'BUG: ASP.NET 2.0 HttpApplication cannot find IHttpHandlerFactory when HttpContext.RewritePath(string)
  includes PathInfo'
date: '2006-06-24 19:45:00'
tags:
- net_framework_2_0
- bug
- fix
- asp_net
---

This week we've been testing our migration configuration for our upgrade from the .Net 1.1 Framework to 2.0. Last summer I wrote an HttpModule which masks our urls. Internally our url structure resembles "http://domain/path/page.aspx/pathinfo?querystring". Where Page.aspx is always the same and PathInfo is the path to a template file. But in order to optimize our urls for search engines the HttpModule I wrote changes that format to "http://domain/path/pathinfo.mxp/querystring. Where querystring was State=CA&SSID={GUID} it is now California/Boys_Varsity_Football_Fall_05-06. We use a series of RegEx objects to determine which url format was used. If a UserAgent requests a page using the first url we send back a 301 redirect. The purpose of this is to get search engines to update their indexes with the new path. If the second url format is used we reformat the url to match the first and use the HttpContext.RewritePath(string) method to forward the actual url to our web application. Like this:

    HttpContext.Current.RewritePath("/path/page.aspx/pathinfo?querystring");

When we installed the .NET 2.0 Framework and configured our development server with ASP.NET 2.0 the masking stopped working. Instead we were getting errors. We found that our pages were being caught in an infinate loop. The HttpApplication.OnBeginRequest event was being raised over and over, alternating between the urls. Our module would recieve the request, reformat it, call HttpContext.RewritePath. Then it would get called again, this time it would see the url in the internal format and send a redirect. Which would then trigger the entire process again. The Page classes would never get called.

I created a sample project which duplicates our process but is much simpler. I found that the problem was with the PathInfo when we reformatted the url to the internal format. In order to fix the problem we had to split the url into parts and use the HttpContext.RewritePath(string, string, string) method. So when this url comes in :

    http://domain/folder/template.mxp/california

We reformat it as:

    /folder/page.aspx/template.mxp?State=CA

Then we break it into 3 parts (path, pathinfo, querystring) and pass it as:

    HttpContext.Current.RewritePath("/folder/page.aspx", "template", "State=CA");

Once I figured this out and fixed it, I was curious to know where the problem was caused. So I opened up Lutz Roeder's .Net Reflector and dove into the HttpContext.RewritePath code. I couldn't anything that would cause what we were seeing. So then I decided to add a bunch of empty methods to a Global.asax class and put a break point in each to see where things went wrong. I added all the per request application events and added a break point in Page.Init() and Page.Load() as well to see if the request ever got to the page class.

When there was no PathInfo in the url it hit every break point. But when PathInfo was included it would hit every application request method, but the Page.Init() and Page.Load() methods were never called. So I created a class which inherited from System.Web.UI.PageHanderFactory, overrode the GetHandler method and put a breakpoint in it. This is called by the Application.OnResolveRequestCache event. But when PathInfo was included in the url, it was never called. This explains why the Page class was never called - because it couldn't find an IHttpHandler for the page, so it just redirected the user. (I didn't verify this by checking IIS logs, but I'm simply describing what seems to happen). This is what caused the infinate loop.

The code below is the sample project I created. Which does not excatly duplicate our process, but it does duplicate the bug. I hope this helps anyone out there with a similar problem and I will be submitting this to Microsoft along with the work around.

#IIS Configuration

Add *.mxp to application mappings:

1. Open IIS.mmc
* Right-click website - select properties
* Open Home Directory tab
* Click Configure
* On the Mappings tab click Add.. :

<pre>    
    Executable: C:\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll
    Extension: .mxp
    Verbs: All verbs
    Verify file exists: no
</pre>

6) Click "ok" on all open dialogs

Web.config

    <?xml version="1.0"?>
    <configuration>
     <system.web>
      <compilation debug="true"/>
      <httpHandlers>
       <add verb="*" path="*.aspx" type="UrlRewrite.myPageFactory"/>
       <add verb="*" path="*.mpx" type="UrlRewrite.myPageFactory"/>
      </httpHandlers>
     </system.web>
    </configuration>
    myPageFactory.cs
    

    using System;
    using System.Web;
    using System.Web.UI;
    
    namespace UrlRewrite
    {
        public class myPageFactory : PageHandlerFactory
        {
            public override IHttpHandler GetHandler(HttpContext context, string requestType, string virtualPath, string path)
            {
                return base.GetHandler(context, requestType, virtualPath, path);
            }
        }
    }

Global.asax (remove comments to fix bug)

    <%@ Application Language="C#" %>
    
    <script runat="server">
    
        void Application_OnBeginRequest(object sender, EventArgs e)
        {
            HttpApplication application = (HttpApplication)sender;
    
            string url = application.Request.Url.AbsolutePath;
            if (url.Contains(".mxp"))
            {
                url = url.Replace(".mxp", ".aspx");
                /*
                if (url.IndexOf(".aspx/") != -1)
                {
                    //if there is pathInfo in the url it can't be sent as a single url, it has to be separated or we endup in a endless loop
                    string info = string.Empty;
                    int i = url.IndexOf(".aspx/") + 6;
                    info = url.Substring(i);
                    url = url.Substring(0, i - 1);
                    HttpContext.Current.RewritePath(url, info, string.Empty);
                }
                else
                 */
                HttpContext.Current.RewritePath(url);
            }
            else if (url.Contains(".aspx"))
            {
                url = url.Replace(".aspx", ".mxp");
                application.Response.Redirect(url);
            }
        }
    
    </script>
    
