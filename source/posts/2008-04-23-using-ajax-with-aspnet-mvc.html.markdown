---
layout: post
title: Using Ajax with ASP.NET MVC
date: '2008-04-23 18:59:00'
tags:
- extjs
- mvc
- scriptmanager
- system_web_extensions
- clientscriptmanager
- scriptcontrol
- asp_net
- asp_net_mvc
- ajax
---

One of the features I continue to wait for from the ASP.NET MVC team is a server control library to work with the MVC framework. So as I have been working on a project using ASP.NET MVC I have begun developing my own library of server controls.

Recently, I began looking at the ExtJs library as a client-side script library for my project. I love how extensible the library is and the documentation is very good. However, there seems to be quite a bit of boiler plate code to be written for any data driven controls. So I decided to look into developing a library of controls to wrap the creation and configuration of ExtJs controls.

The main problem is that the MVC framework doesn't currently provide built-in javascript/ajax support. Sure you can do it all by hand, but I am determined that the current project I am working on will be very designer friendly. Which is one of the reasons I really like MVC - the code is moved away from the view which means away from the designer.

When developing server controls with client capabilities for the ASP.NET web forms model the controls depend heavily on the ScriptManager and ClientScriptManager classes which in turn depend upon a form element with the runat attribute set to "server". But the MVC model doesn't use a server-side form element.

However, I determined that by creating an abstraction layer I could create server controls using the same model as web forms. The abstraction layer then allows the authoring of server controls which no longer depend on the web forms model. This allows the controls to then be used for both the web forms model as well as the MVC model.

Today, I created a project on CodePlex which consists of the abstraction layer I created as well as a server control library based on the abstraction layer which encapsulates the ExtJs library.

So far, the Panel control is the only control I have authored. But over the next few weeks and months I plan to continue developing additional server controls which will make it easy to create client controls which connect to web services and WCF services by simply dragging the control to the designer and setting a view properties.

Here's just an example of how easy it is to use these server controls in your MVC or web forms project.

At the top of your aspx file include the following declaration:

    <%@ Register Assembly="DevelopmentalMadness.Web.UI.ExtJsControlLibrary" Namespace="DevelopmentalMadness.Web.UI.ExtJsControlLibrary" TagPrefix="js" %>


Then anywhere in your page include the next two control declarations:

    <js:extjsscriptmanager id="ScriptManager1" runat="server"/>

    <js:extjspanel id="myPanel" title="control title" width="300px" runat="server" collapsible="true" html="control content"/>

And that's it. If you download the latest source code from my CodePlex project you'll see an example of using these controls in both an MVC application as well as a web forms project.

As I add new capabilities I'll write tutorials. My biggest hope is that others will use the abstraction library to write controls for other javascript libraries like JQuery or others.