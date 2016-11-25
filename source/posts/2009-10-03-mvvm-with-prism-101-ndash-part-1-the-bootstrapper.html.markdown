---
layout: post
title: 'MVVM with Prism 101 – Part 1: The Bootstrapper'
date: '2009-10-03 11:50:00'
tags:
- silverlight
- prism
- mvvm
- bootstrapper
---

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Bootstrapper.zip)

* [Part 1: The Bootstrapper](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/)
* [Part 2: The Shell](/2009/10/12/mvvm-with-prism-101-ndash-part-2-the-shell/)
* [Part 3: Regions](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/)
 * [Part 3b: View Injection and The Controller Pattern](/2009/10/15/mvvm-with-prism-101-ndash-part-3b-view-injection-and/)
* [Part 4: Modules](/2009/10/23/mvvm-with-prism-101-ndash-part-4-modules/)
* [Part 5: The View-Model](2009/10/28/mvvm-with-prism-101-ndash-part-4-modules/)
 * [Part 5b: ServiceLocator vs Dependency Injection](/2009/11/02/mvvm-with-prism-101-ndash-part-5b-servicelocator-vs-depdency/)
* [Part 6: Commands](/2009/11/04/mvvm-with-prism-101-ndash-part-6-commands/)
 * [Part 6b: Wrapping IClientChannel](/2010/03/08/mvvm-with-prism-101-ndash-part-6b-wrapping-iclientchannel/)


I recently spoke at a CodeCamp put on by the Northern Utah .NET User Group (NUNUG) on implementing MVVM using Prism. I hadn’t spoken in a long time and so I was over prepared – way over prepared. Then to top in off in my nervousness, I blew the whole presentation by starting 15 minutes late. I was the session after lunch and I assumed lunch was an hour, so I mistakenly assumed my session started at 1:00 PM. :p

Embarrassing stories aside, I really learned a lot more about Prism and Silverlight and what an enterprise-class implementation of Prism looks like. So I am writing a redux of [my previous post on Prism and Silverlight](/2009/06/08/prism_for_silverlight_2_taking_hello_world_to_a_whole_new_level/). If you want a shorter overview of things, read that one first. However, I intend to introduce new concepts and go deeper than I did in my previous article. This is the first of this series.

#MVVM
Before I get started I would like to just make a short comment about MVVM. The pattern known as Model View View-Model is in it’s pure form very simple. You have a Model (your business/domain model), a View (in the case of WPF/Silverlight is your Xaml file) and the distinguishing piece of the pattern: the View Model.

The View-Model is a composite of the abstraction of you view’s state and behavior. The idea behind the View-Model is to create an abstraction of your view which has little to no dependencies on your view. There should be no references to UI controls or classes specific to the UI (like the Visibility enum). There should be no event handlers like what is common in a code-behind class. Your View-Model should know nothing of your UI.

The reason for this and why it is possible has a strong tie to the way data biding works in WPF/Silverlight. I won’t directly get into the specifics of data binding, except to say that because of the specific way you can bind UI elements to objects in a strongly-typed manner MVVM has become the de facto standard pattern for developing applications for WPF/Silverlight.

Once you get MVVM it will become second nature to you. Its power lies in its simplicity. The complexity of implementing MVVM is more about the framework you are using than actually using the pattern. I will explain more about that last statement in a future post. I when I actually get to discussing MVVM specifically I plan on demonstrating what I’d like to term “poor man’s MVVM” so I can demonstrate the MVVM in a more pure form. The rest of the series is either specific to Prism or specific features you’ll want to implement as you’re developing your application.

#Bootstrapper
The `Bootstrapper` is your starting point when developing any application for Prism (aka Composite Application Library for WPF/Silverlight). The `Bootstrapper` is basically class representing your App_Startup method. Once you’ve completed your `Bootstrapper` you just initialize it and call `Run()` inside of `App_Startup`, like this:

     private void Application_Startup(object sender, StartupEventArgs e)
     {
         //replaces the call to "this.RootVisual = new Shell();"
         My`Bootstrapper` bootstrapper = new My`Bootstrapper`();
         bootstrapper.Run();
     }

Just remove the call (in Silverlight) to `this.RootVisual` and replace it by instantiating your `Bootstrapper` and calling `Run()`.

The basic purpose of your `Bootstrapper` is to initialize your Inversion of Control (IoC) container and register all the types you’ll need for Dependency Injection (DI). Because of this your `Bootstrapper` will inherit from an abstract class named after your specific IoC implementation. You can use any library you choose: Ninject, StructureMap, Unity, etc. However, Prism actually only provides a single implementation of `Bootstrapper` – Unity`Bootstrapper`. If you want to use another container library, you’ll either have to write your own or find an implementation out on the web. This isn’t hard to do as there are a number of implementations out there for each of the widely used libraries.

There are 3 common tasks that you’ll do every time your create a new `Bootstrapper`:

1. Setup `ModuleCatalog`
* Configure the Container (IoC)
* Create Shell

I’ll go over each of these in detail:

#Setup ModuleCatalog

A module (in terms of Prism) is a class which implements the `Microsoft.Practices.Composite.Modularity.IModule` interface. A module represents a pluggable piece of the composite whole. When planning your application you will isolate it into logical parts. If your application were an rss reader you might have modules for Content, Tags, PopularItems, RecentItems, Favorites, etc. They may or may not need to communicate, but you can certainly add , remove and rearrange each one without affecting the others. This is an example of a module.

Think of `ModuleCatalog` as a registry of all the modules you plan to load in your application. Once you register them when your application loads they will be loaded in the order you registered them and then each module in turn will inject your views into the main window of your application.

Setting up `ModuleCatalog` is simple:

    public class Bootstrapper : UnityBootstrapper
    {
      protected override IModuleCatalog GetModuleCatalog()
      {
        ModuleCatalog catalog = new ModuleCatalog();
 
        catalog.AddModule(typeof(ServicesModule));
        catalog.AddModule(typeof(EditorModule));
        catalog.AddModule(typeof(HistoryModule));
 
        return catalog;
      }
    }

For the most part, that’s all that’s required. At the very minimum you must return an instance of `ModuleCatalog` – whether or not you register anything with it. But if you don’t you aren’t likely to see much more than just your shell when the application loads. So you’ll register each module you’ve defined and possibly declare any dependencies (more on that when we discuss modules) and finally you’ll return the catalog to the `Bootstrapper`.

It is important to note that the order you register your modules is the order they will load in, so pay attention or you’ll have some troubles when your application starts up. I’ll address managing dependencies between modules later in the series when I talk about implementing modules.

As a note I will mention that there are other ways to configure the module catalog and to load modules. Some are dependent upon whether you’re using WPF or Silverlight, but both technologies provide some way or another for you to load modules dynamically or on demand or to use configuration of some sort (WPF – config file / Silverlight app.xaml). But I won’t be going into any of these methods in this series.

#Create Shell

The shell is comparable to an ASP.NET MasterPage. The shell is usually a UserControl or Page.  Whereas a MasterPage uses ContentPlaceHolder objects, Prism uses Regions (more on that in my next post). For now, a region is an attached property for specific xaml objects which designates where you can inject your views to display them.

When it comes to Silverlight applications, an important thing to note about the shell is that it will become the RootVisual object. If you aren’t familiar with RootVisual, it is important to note that it can only be set once - you can’t change it once it has been set. But here’s the nice thing about using Prism, the regions you define later on allow you to dynamically replace or load additional content as you need. So your shell will provide the placeholders for you.

Other than that all you really need to remember is to initialize the class which represents your UserControl or Page (the code behind), set it as the RootVisual (call Show() if you’re developing for WPF) and return the instance from your method. The `Bootstrapper` implementation you inherit from will then register any regions you’ve defined in your xaml with the RegionManager service. Here’s what your CreateShell method should look like:

    protected override DependencyObject CreateShell()
    {
      Shell shell = Container.Resolve<Shell>();
 
      Application.Current.RootVisual = shell;
 
      return shell;
    }

#Conclusion
I will continue this series next time by talking about the Shell and Regions. For now, here is a sample project which demonstrates what we’ve just discussed.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Bootstrapper.zip)