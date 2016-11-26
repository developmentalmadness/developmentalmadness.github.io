---
layout: post
title: Abstracting System.Web.UI.ScriptManager away from the Web Forms model
date: '2008-04-25 18:48:00'
tags:
- design_patterns
- scriptmanager
- system_web_extensions
---

As I continue to work with the ASP.NET MVC framework I continue to be inspired to dig deeper into things, to find out how they work and how I can make them work with this awesome new framework.

The case in point here is using ASP.NET Ajax controls with MVC. Currently this doesn't work because it is closely tied to the web forms model. More specifically, ASP.NET Ajax requires an html form element with the runat attribute set to “server”. Without it, client enabled controls written to use the ScriptManager server control won't work.

Here's the error message if you include ScriptManager without <form runat="server">

> **Control 'ScriptManager1' of type 'ScriptManager' must be placed inside a form tag with runat=server.**

The result is then that two versions of the control must be written. One using ScriptManager, and another which has its own plumbing written to register client scripts and script blocks with the target page.

What I like about using ScriptManager (which uses ClientScriptManager under the hood) is the ability to easily register scripts with the target page. The reason I find this important is because it means I can embed all my resources with my control and the consumer of my control doesn't have to worry at all about making sure the correct version of the scripts and all their dependencies are included both on the page and in the project files. While this certainly doesn't require the use of web forms, it makes it compatible with both frameworks.

#The ScriptManager abstraction

The first abstraction is the ScriptManager. We want our server controls to work with or without the ScriptManager, so we need to provide a layer which allows us to author controls which work with a script manager, but it doesn't have to always be ScriptManager. Here's a diagram of how this can be done.

![](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2008/04_25/ScriptManager.png)

What we have is an abstract base class aptly named, ScriptManagerBase. It implements two interfaces IPostBackDataHandler and IScriptManager. The first is part of the .NET Framework, while the second was just a way to easily generate method stubs, but could be used to further abstract away details in the future.

The second class, ScriptManagerWrapper, is exactly what the name implies. It is a wrapper class for System.Web.UI.ScriptManager which inherits from ScriptManagerBase. We never interact directly with ScriptManagerWrapper, but when a control which is aware of ScriptMangerBase calls its static GetCurrent method and the page contains an instanct of System.Web.UI.ScriptManager it is returned to the caller after wrapping it within ScriptManagerWrapper, like this:

**Server Control**

    protected override void OnPreRender(EventArgs e)
    {
      if (!this.DesignMode)
      {
        //Get the script manager here
        _manager = ScriptManagerBase.GetCurrent(Page);
      
        if (_manager == null)
          throw new System.Web.HttpException("A ScriptManagerBase control must exist on this page");
      
        _manager.RegisterScriptControl(this);
        _manager.RegisterScriptDescriptors(this);
      }
    
      base.OnPreRender(e);
    }
    

**ScriptManagerBase.GetCurrent method**

    public static ScriptManagerBase GetCurrent(Page page)
    {
      if (page == null)
      {
        throw new ArgumentNullException("page");
      }
    
      ScriptManagerBase scriptManager = (page.Items[typeof(ScriptManagerBase)] as ScriptManagerBase);
      if (scriptManager == null)
      {
        ScriptManager sm = page.Items[typeof(ScriptManager)] as ScriptManager;
        if(sm != null)
          scriptManager = new ScriptManagerWrapper(sm);
      }
    
      return scriptManager;
    }
    
This follows the model employed by the .NET Framework, the ScriptManager adds itself to the Items collection of System.Web.UI.Page during the OnInit event (not shown). Then when a control calls the static GetCurrent event the instance which is used for the page is returned. In our case, we first look for an instance of ScriptManagerBase in the Items collection. If it doesn't exist, then there might be an instance of System.Web.UI.ScriptManager. If there is, then we wrap it and return that instance. This way the control doesn't care which class is being used, it will function exactly the same.

#ScriptManager implementation

ScriptManagerWrapper, as you might assume simply delegates calls to its methods directly to System.Web.UI.ScriptManager. No surprises there. But for ScriptManagerBase I had to decide how I would implement its behaviors. Because of time and budget constraints (I really don't have much of either) I really didn't want to have to provide a full implementation of all its behaviors.

While digging through ScriptManager's implementation using Reflector, I noticed that ScriptManager was actually using ClientScriptManager for much of its functionality. So I decided to figure out where the dependency on web forms really was. Was it with ScriptManager or ClientScriptManager.

The answer is actually both. For script manager, you'll get an error without web forms. For ClientScriptManager, you can compile and you can even run your page and you won't get any complaints. But if you try and use any functionality that depends on ClientScriptManager and nothing happens, why? If you view the source of the page you'll see none of your scripts registered with ClientScriptManager are in the page's source.

The reason for this is that when you have an HtmlForm control (form with runat=”server”), the control's RenderChildren method calls the internal page.BeginFormRender() method. This method calls the internal ClientScriptManger.RenderClientScriptBlocks method. So if your form element is just a standard html form element (no server-side registration) then these methods don't get called and your script is omitted from the page's output.

##Bad, Bad, Bad – But it works!

Here's where things get a little sketchy. What I am about to do is not a good idea if you are planning on developing a commercial script library or need to deploy your library to a hosted environment. Because it won't work in a hosted environment, so if you want to, you can't. And if the client's of your commercial library want to (and they will) they can't. So why do it? Two reasons: first, my solution is not currently a commercial solution and second, because of #1 I can afford a short cut that gets me what I want in the short term and I can change it later when I need to.

So what is it I'm going to do that so bad? Well, here's my solution for using ClientScriptManager without an HtmlForm server control:

**ScriptManagerBase**

    private void OnPageInitComplete(object sender, EventArgs e)
    {
      if (base.DesignMode)
       return;
    
      if (Page.Form == null)
      {
        //need formless script manager
        _clientScript = new FormlessClientScriptManager(Page);
      }
      else
      {
        //load standard script manager (ClientScriptManager)
        _clientScript = new ClientScriptManagerWrapper(Page);
      }
    }
    

**FormlessScriptManager**

    internal class FormlessClientScriptManager : ClientScriptManagerWrapper
    {
      public FormlessClientScriptManager(Page page) : base(page)
      {
        // because there's no <form runat="server">we have to manually render
        // all registered scripts in the header
        page.Header.SetRenderMethodDelegate(RenderHtmlHead);
      }
    
      private void RenderHtmlHead(HtmlTextWriter output, Control container)
      {
        //manually render the begin tag
        output.RenderBeginTag(HtmlTextWriterTag.Head);
    
        //manually render children
        foreach (Control control in container.Controls)
        {
          control.RenderControl(output);
        }
    
        //render script stuff
        ClientScriptManager script = container.Page.ClientScript;
        Type scriptType = script.GetType();
        Type[] argTypes = new Type[] { typeof(HtmlTextWriter) };
    
        // we could write our own register and render methods, which would work better in hosted environments
        // but for now this will save some time until that is needed
        MethodInfo renderBlocks = scriptType.GetMethod("RenderClientScriptBlocks",
          BindingFlags.NonPublic BindingFlags.Instance, null, argTypes, null);
        MethodInfo renderStartUp = scriptType.GetMethod("RenderClientStartupScripts",
          BindingFlags.NonPublic BindingFlags.Instance, null, argTypes, null);
        MethodInfo renderArrays = scriptType.GetMethod("RenderArrayDeclares",
          BindingFlags.NonPublic BindingFlags.Instance, null, argTypes, null);
    
        Object[] args = new Object[]{output};
    
        renderBlocks.Invoke(script, args);
        renderArrays.Invoke(script, args);
        renderStartUp.Invoke(script, args);
    
        //render CssIncludes
        ListDictionary cssIncludes = base.GetClientCssIncludes();
        foreach (String url in cssIncludes.Values)
        {
          output.AddAttribute(HtmlTextWriterAttribute.Rel, "stylesheet");
          output.AddAttribute(HtmlTextWriterAttribute.Type, "text/css");
          output.AddAttribute(HtmlTextWriterAttribute.Href, url);
          output.RenderBeginTag(HtmlTextWriterTag.Link);
          output.RenderEndTag();
        }
    
        //close the head element
        output.RenderEndTag();
      }
    }
    
So what's the problem here? There's two problems: first, look at the constructor. The call to SetRenderMethodDelegate() is calling a method that “supports the .NET Framework infrastructure and is not intended to be used directly from your code”. This isn't really the problem I was referring to, but certainly raises red flags about the compatibility of your solution with future releases of the framework.

The second problem is that I'm using reflection here to call the private methods RenderClientScriptBlocks, RenderClientStartupScripts and RenderArrayDeclares. This won't fly in a hosted environment which is properly enforcing security (ie. if they have enforced ReflectionPermission). So don't do it if your code may need to run in an hosted environment.

However, if you have complete control over your environment then you can certainly sign your own controls and grant FullTrust to that signature while still maintaining a secure environment for your code.

Besides, to quote Scott Hanselman “If you're going to ‘sin' do it with style – do it with reflection”.

Returning to ScriptManager, the ScriptMangerBase implementation also uses ClientScriptManger which is abstracted like ScriptManager so we can eventually do this in a “non evil” way without affecting the rest of our solution. The only caveat is that we need to call the abstracted ClientScriptManagerBase which is a property of our ScriptManagerBase. If we use Page.ClientScriptManager from our controls, they will break once we replace our cheat with a full implementation. Not to mention that referencing ClientScriptManager directly breaks the whole abstraction chain, you can do it but you will loose the benefits of all your hard work.

#Conclusion

There are other ways to do this, but I found this very valuable because it maintains compatibility with both ASP.NET models (web forms and MVC) and because there was surprisingly very little work involved in getting this done. Not to mention it was a great exercise in OOP – by using abstraction when we develop we can create cross-platform solutions and reduce the amount of work required to get it done.

#Source Code

To get the source code visit http://www.codeplex.com/ajaxmvc where I have hosted the source for this solution as well as a “proof of concept” that I have started (not done, I'm just getting started at this point) an implementation of a server control library for ExtJs. The source code also includes two demo apps, one MVC and one Web Forms. The demos simply show a very simple server control which uses the abstractions we've discussed here that works in both environments without any changes or workarounds.
