---
layout: post
title: 'MVVM with Prism 101 – Part 4: Modules'
date: '2009-10-23 22:45:00'
tags:
- silverlight
- prism
- mvvm
- mvvm-with-prism-101
- modules
---

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Modules.zip)

* [Part 1: The Bootstrapper](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/)
* [Part 2: The Shell](/2009/10/12/mvvm-with-prism-101-ndash-part-2-the-shell/)
* [Part 3: Regions](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/)
 * [Part 3b: View Injection and The Controller Pattern](/2009/10/15/mvvm-with-prism-101-ndash-part-3b-view-injection-and/)
* [Part 4: Modules](/2009/10/23/mvvm-with-prism-101-ndash-part-4-modules/)
* [Part 5: The View-Model](2009/10/28/mvvm-with-prism-101-ndash-part-4-modules/)
 * [Part 5b: ServiceLocator vs Dependency Injection](/2009/11/02/mvvm-with-prism-101-ndash-part-5b-servicelocator-vs-depdency/)
* [Part 6: Commands](/2009/11/04/mvvm-with-prism-101-ndash-part-6-commands/)
 * [Part 6b: Wrapping IClientChannel](/2010/03/08/mvvm-with-prism-101-ndash-part-6b-wrapping-iclientchannel/)


Welcome back to my series on implementing the Model View View-Model pattern with Prism (aka Composite Application Library For WPF/Silverlight). I can by the response (votes and traffic) that many are really enjoying it so far. As I continue I hope not to disappoint!

This installment is about modules. Honestly, I've been putting this one off for a couple days because of a bit of writer's block around the concept of "Modules" as put forth by the Prism framework and modules as a general concept in programming. I was always taught in elementary school English that when you define a word you shouldn't use the word being defined in the definition. I generally try to follow that. Plus, it really seems a bit silly to define the concept of a Module when it is so common to programming. In Prism a Module is a module or modular block of code that can be registered at design time or discovered at runtime. (I can hear my elementary school teachers collectively screaming – or turning in their graves as the case may be).

But here's a better way to put it – Modules are classes which implement the IModule interface. That's it.

    using System;
     
    namespace Microsoft.Practices.Composite.Modularity
    {
        // Summary:
        //     Defines the contract for the modules deployed in the application.
        public interface IModule
        {
            // Summary:
            //     Notifies the module that it has be initialized.
            void Initialize();
        }
    }

You can bake 'em, fry 'em or grill 'em but it boils down to that. Your entire Silverlight solution could be contained in a single project which contained all the implementations of IModule you needed. Most often (or at least as it is prescribed) each module will have its own project. But you can also mix and match between the two strategies as needed. For example, if you have a large number of modules and you would like to reduce the size of your initial .xap file you can compile all the module projects required at startup together and then create a second silverlight application project which references the remaining projects to be packaged as a secondary .xap (rinse and repeat for as many separate .xap files as you like) and then when the initial .xap is loaded and runs it can download and import the remaining .xap files in the background or even on demand. I won't be demonstrating this more advanced scenario – for that you just need to look it up in the docs or someday I may write an additional post addressing it specifically.

As for this series I'll be addressing the prescribed method. Each module has its own project. Within that project you will have all the views, models and other supporting implementations. "Module" projects will not reference each other because you do not want to create circular references when things start getting complex and you want to keep dependencies to a minimum. If you need to reference something between projects the recommended practice is to create an "infrastructure" or "common" project, create an interface for the implementation which needs to be referenced and store the reference in your infrastructure project and reference that. Here's what the final solution looks like:

![](http://dvm-public-assets.s3.amazonaws.com/images/2009/10_23/SolutionScreenshot.jpg)

* Common: (Silverlight Class Library Project) - This is where interfaces, model classes, custom controls, value converters and utility classes are stored.
Shell: (Silverlight Application Project) - This is where the Shell, Bootstrapper and App.xaml classes are kept. This is your startup project.
* History/Editor: (Silverlight Class Library Project) – These are both "Module Projects" which contain a single IModule implementation as well as the Views, ViewModels and (where applicable) Controllers. Also, if I am using the ServiceLocator pattern (usually when I want design-time databinding) each of these projects will have a single ServiceLocator class.
* Services: (Silverlight Class Library Project) – This is where I keep *all* concrete service implementations. You can, if you so choose, keep service client implementations in the same project where they are used most. However, my own practice is to always have a single Services project with all concrete implementations contained in it. The reason is that your startup project can only have a single .ClientConfig file. If I need to create multiple startup projects (different versions using the same services) then I can link the .ClientConfig from the Services project to any other Silverlight Application Project I need to.
* Model: (Windows Class Library Project) – The server-side version of my model. This is where my domain/object model and service interfaces are stored. Then in the Common project I create a link to the files I need on the client-side.
* Web: (Web Application Project) – This is just what it sounds like. The web application which hosts the Silverlight application as well as the WCF/ASMX service host.

#Implementing IModule
"That's nice", you're saying. "But that doesn't tell me anything much about what I do or how I use IModule. Well, I did skip a few details I guess. Let's go back to Bootstrapper for a minute.

##Module Lifecycle

If you'll remember from my first post in this series Bootstrapper has a method called GetModuleCatalog. Bootstrapper is your startup class and is located in your startup project. This means that it knows about each project in your solution as well as the concrete implementations of IModule in each project. So when your Bootstrapper runs and your GetModuleCatalog method is called this is where you will register each instance of IModule. Like this:

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

These will be loaded and their IModule.Initialize() method will be called in the order you register them here. So if your dependency structure is simple (like we have here) you can just load them in dependency order (both Editor and History depend only upon Services). However, later on when we talk about Event Aggregation we'll be creating a dependency between Editor and History. We could either load them in order or explicitly define the dependency chain, like this:

    protected override IModuleCatalog GetModuleCatalog()
    {
        ModuleCatalog catalog = new ModuleCatalog();
     
        catalog.AddModule(typeof(ServicesModule));
        catalog.AddModule(typeof(EditorModule), "ServicesModule");
        catalog.AddModule(typeof(HistoryModule), "ServicesModule", "EditorModule");
     
        return catalog;
    }

This way you don't have to worry about the order, because just like the way Visual Studio will determine build order of projects based upon dependencies, Prism will load the modules in the order required by the dependency chain.

The responsibility of IModule is to load and register all the classes required for the application. This is where you will register your View-Models with your IoC container and your Views with the RegionManager. Basically any concrete implementations for which your Module project is responsible, they will be loaded/registered here. Here's an example of what your typical IModule implementation will look like:

    using CodeCamp.Common.ViewModel;
    using Microsoft.Practices.Composite.Modularity;
    using Microsoft.Practices.Composite.Regions;
    using Microsoft.Practices.Unity;
     
    namespace CodeCamp.History
    {
        public class HistoryModule : IModule
        {
            IUnityContainer m_Container;
            IRegionManager m_Manager;
     
            public HistoryModule(IUnityContainer container, IRegionManager manager)
            {
                m_Container = container;
                m_Manager = manager;
            }
     
            #region IModule Members
     
            public void Initialize()
            {
                m_Container.RegisterType<IHistoryViewModel, HistoryViewModel>();
                ServiceLocator.Container = m_Container;
                m_Manager.RegisterViewWithRegion("HistoryRegion", typeof(HistoryView));
            }
     
            #endregion
        }
    }

Here we have an example of several different tasks performed by the HistoryModule. First, the concrete type for our View-Model is registered with the IoC container. Second, we are wiring up the ServiceLocator (more on that in another post coming soon) with our IoC container. Last, we register our View with the RegionManager. Each is a task for which IModule is responsible. To demonstrate a second example, let's look at our ServicesModule class:

    using System.ServiceModel;
    using CodeCamp.Model;
    using Microsoft.Practices.Composite.Modularity;
    using Microsoft.Practices.Unity;
    using CodeCamp.Common.Services;
     
    namespace CodeCamp.Services
    {
        public class ServicesModule : IModule
        {
            private IUnityContainer m_Container;
     
            public ServicesModule(IUnityContainer container)
            {
                m_Container = container;
            }
     
            #region IModule Members
     
            public void Initialize()
            {
                IMessageServiceAsync service = new ChannelFactory<IMessageServiceAsync>("BasicHttpBinding_IMessageEndpoint").CreateChannel();
                m_Container.RegisterInstance<IMessageServiceAsync>(service);
            }
     
            #endregion
        }
    }

Here the only thing we are concerned with is initializing our service(s) and registering them with the IoC container. There are no Views or View-Models, so you see that a Module is more than just a way to load up Views.

Once the Initialize() method completes for all the Modules the Shell will be loaded and any Views which were registered will be loaded into their respective regions.

#Conclusion
So far we've discussed Bootstrapper, Shell, Regions and Modules. Each is a discrete piece in our application. Each has a well defined responsibility. What I like about this is I end up writing very modular code in small single-responsibility units naturally and without having to think about it too much. Sure I could create a monster method if I tried, but who's trying?

Next in my series I'm going to finally be addressing the View-Model. I'm excited about it because it is really my favorite part and it's what I like most about working with Silverlight and WPF.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Modules.zip)