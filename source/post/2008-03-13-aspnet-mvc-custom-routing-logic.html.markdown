---
layout: post
title: ASP.NET MVC Custom Routing Logic
date: '2008-03-13 19:10:00'
tags:
- asp_net_mvc
---

I've been working with the new ASP.NET MVC framework since the first CTP back in December. I love it and it keeps getting better.

The application I'm working on uses custom Session management and so I have to manage the SessionId in the url myself. So I wanted to be able to make sure that all Redirects, Links and Urls had the SessionId. But I didn't want to have to add it myself (maintenance nightmare) and end up with having to track down errors from missing it.

Because the routing framework builds the urls for you I wanted to interject my logic into one place where I could intercept each request to build a url and add the SessionId.

Before the March CTP (aka the MIX '08 CTP) I had to add extensions to all the classes which constructed urls. Here's a link to a post of mine at the time: http://forums.asp.net/p/1216840/2159920.aspx#2159920

But now with the recent CTP refresh it has become very easy to manage the session id from one place. I just create a class which inherits from System.Web.Routing.Route (or you can implement it from scratch by inheriting from System.Web.Routing.RouteBase). Here's how I did it.



    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Web.Routing;
    using System.Web;
    using System.Web.Mvc;
    
    using DevelopmentalMadness.Web.Mvc;
    
    namespace DevelopmentalMadness.Web.MvcExtensions
    {
        public class SessionRoute : Route
        {
            public SessionRoute(String url, IRouteHandler routeHandler) : base(url, routeHandler)
            {
    
            }
    
            public SessionRoute(String url, RouteValueDictionary defaults, IRouteHandler routeHandler)
                : base(url, defaults, routeHandler)
            {
           
            }
    
            public SessionRoute(String url, RouteValueDictionary defaults, RouteValueDictionary constraints, IRouteHandler routeHandler)
                : base(url, defaults, constraints, routeHandler)
            {
    
            }
    
            public SessionRoute(String url, RouteValueDictionary defaults, RouteValueDictionary constraints, RouteValueDictionary dataTokens, IRouteHandler routeHandler)
                : base(url, defaults, constraints, dataTokens, routeHandler)
            {
    
            }
    
            public override VirtualPathData GetVirtualPath(RequestContext requestContext, RouteValueDictionary values)
            {
                //how can I get the view context or controller context ?????
                if (requestContext is ControllerContext)
                {
                    ControllerContext cCtx = (ControllerContext)requestContext;
    
                    if (cCtx.Controller is SessionBaseController)
                    {
                        SessionBaseController sCtl = (SessionBaseController)cCtx.Controller;
                        if (values.ContainsKey("sid") == false && sCtl.ServerCookie != null)
                            values.Add("sid", sCtl.ServerCookie.Ticket);
                    }
                }
    
                VirtualPathData virtualPath = base.GetVirtualPath(requestContext, values);
    
                return virtualPath;
            }
        }
    }
    

SessionBaseController and ServerCookie are two custom classes of mine. ServerCookie is my session state management class and SessionBaseController is the class which exposes and maintains it. So I am able to access it through the RequestContext.

I haven't fully tested this yet, so I'm not sure if RequestContext will ever be something other than ControllerContext. I'm assuming that it can be, especially in the context of a unit test. Because they didn't explicitly declare ControllerContext it would be correct to assume that it won't always be ControllerContext, I just haven't discovered yet what the other possible values could be. Maybe for my next post.


The only other requirement is to design your routes so that they have a parameter for the values you are adding to the url, like this:




    namespace MvcApplication
    {
        public class Global : System.Web.HttpApplication
        {
            public static void RegisterRoutes(RouteCollection routes)
            {
                // Note: Change Url= to Url="[controller].mvc/[action]/[id]" to enable
                //       automatic support on IIS6
    
                routes.Add(new Route(
                    "Login.mvc/Index/{result}",
                    new RouteValueDictionary(new
                    {
                        controller = "Login",
                        action = "Index",
                        result = (String)null
                    }),
                    new MvcRouteHandler()
                    )
                );
    
                routes.Add(new SessionRoute(
                    "Login.mvc/{action}/{sid}",
                    new RouteValueDictionary(new
                    {
                        controller = "Login",
                        action = "Index",
                        sid = (String)null
                    }),
                    new MvcRouteHandler()
                    )
                );
    
                routes.Add(new SessionRoute(
                    "{controller}.mvc/{action}/{sid}",
                    new RouteValueDictionary(new
                    {
                        action = "Index",
                        sid = (String)null
                    }),
                    new MvcRouteHandler()
                    )
                );
    
                routes.Add(new Route(
                    "Default.aspx",
                    new RouteValueDictionary(new
                    {
                        controller = "Home",
                        action = "Index"
                    }),
                    new MvcRouteHandler()
                    )
                );
            }
    
            protected void Application_Start(object sender, EventArgs e)
            {
                RegisterRoutes(RouteTable.Routes);
            }
        }
    }
    

Each route which requires my custom session management uses SessionRoute instead of Route. Also, the route will include the "sid" argument in the route definition.

Now I can manage the routes I need to by simply updating my Routes defined in global.asax instead of worring wither or not every url in my application was written correctly.
