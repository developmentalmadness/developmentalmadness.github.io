---
layout: post
title: Entity Framework POCO Adapter + System.Web.DynamicData == POCO Loco
date: '2009-01-20 18:10:00'
tags:
- ef_poco_adapter
- metamodel
- system_web_dynamicdata
- entity_framwork
---

This month I started with a new client. I'm excited because we'll be rewriting a legacy app using Entity Framework against an Oracle backend, and possibly ASP.NET MVC. The team is full of good, experinced developers, any of which could lead their own team. 

But as with all new technologies we're experiencing pains with early adoption. One of design goals is to be testible. We're not quite talking TDD here. None of us have been on a TDD project here so we're more just talking about trying to move in a direction we think will be beneficial. 

Additionally, the project specifications require us to store meta data about our data model and create a relationship between the meta data and the users' roles. The relationship will tell us which fields a user can view or edit based on their role. So we're looking into wither we can use System.Web.DynamicData.MetaModel to collect the meta data about our model by using the MetaModel.RegisterContext method. 

Because we'd like to make as much of this testible as possible we decided to try Jaroslaw Kowalski's POCO Adapter to allow our data layer to be more testible. So as an exercise I fired up a new project, added a new ADO.NET Entity Data Model (.edmx) file and created a data model using the AdventureWorks database. Then I used the EFPocoClassGen utility to create my POCO classes, container and adapter based on my edmx file. Here's the Pre-build event commands in my project:

    "$(SolutionDir)EFPocoClassGen.exe" /mode:PocoClasses /inedmx:"$(ProjectDir)Data\AdventureWorks.edmx" /outputDir:"$(ProjectDir)Data"

    "$(SolutionDir)EFPocoClassGen.exe" /mode:PocoContainer /inedmx:"$(ProjectDir)Data\AdventureWorks.edmx" /outputfile:"$(ProjectDir)Data\PocoContainer.cs"

    "$(SolutionDir)EFPocoClassGen.exe" /mode:PocoAdapter /inedmx:"$(ProjectDir)Data\AdventureWorks.edmx" /outputfile:"$(ProjectDir)Data\PocoAdapter.cs"

Then I added the RegisterContext code to my global.asax:

    var model = new MetaModel();
    model.RegisterContext(typeof(AdventureWorksEntitiesAdapter),
     new ContextConfiguration { ScaffoldAllTables = true });

I ran my project and was greeted by with yellow screen of death bearing this message:

    Error: An item with the same key has already been added.


    [ArgumentException: An item with the same key has already been added.]  
    System.ThrowHelper.ThrowArgumentException(ExceptionResource resource) +51  
    System.Collections.Generic.Dictionary`2.Insert(TKey key, TValue value, Boolean add) +7460188  
    System.Data.Metadata.Edm.AssemblyCacheEntry.LoadRelationshipTypes(LoadingContext context) +2061  
    System.Data.Metadata.Edm.AssemblyCacheEntry.LoadTypesFromAssembly(LoadingContext context) +17  
    System.Data.Metadata.Edm.AssemblyCacheEntry.InternalLoadAssemblyFromCache(LoadingContext context) +244  
    System.Data.Metadata.Edm.AssemblyCacheEntry.LoadAssemblyFromCache(Assembly assembly, Boolean loadReferencedAssemblies, Dictionary`2 knownAssemblies, Dictionary`2& typesInLoading, List`1& errors) +137  
    System.Data.Metadata.Edm.ObjectItemCollection.LoadAssemblyFromCache(ObjectItemCollection objectItemCollection, Assembly assembly, Boolean loadReferencedAssemblies) +278  
    System.Data.Metadata.Edm.ObjectItemCollection.LoadFromAssembly(Assembly assembly) +61  
    System.Data.Metadata.Edm.MetadataWorkspace.LoadFromAssembly(Assembly assembly) +77  
    System.Web.DynamicData.ModelProviders.EFDataModelProvider..ctor(Object contextInstance, Func`1 contextFactory) +327  
    System.Web.DynamicData.ModelProviders.SchemaCreator.CreateDataModel(Object contextInstance, Func`1 contextFactory) +110  
    System.Web.DynamicData.MetaModel.RegisterContext(Func`1 contextFactory, ContextConfiguration configuration) +347  
    System.Web.DynamicData.MetaModel.RegisterContext(Type contextType, ContextConfiguration configuration) +79  
    AdventureWorksDDMVC.MvcApplication.RegisterRoutes(RouteCollection routes) in C:\Dev\AdventureWorksDDMVC\AdventureWorksDDMVC\Global.asax.cs:30  
    AdventureWorksDDMVC.MvcApplication.Application_Start() in C:\Dev\AdventureWorksDDMVC\AdventureWorksDDMVC\Global.asax.cs:36
    

If I removed the adapter and container created by the EFPocoClassGen utility the problem goes away. I tried [debugging the DynamicData assembly](http://blogs.msdn.com/sburke/archive/2008/01/16/configuring-visual-studio-to-debug-net-framework-source-code.aspx) to see what the key was which was causing the exception, but it seems like the version of System.Web.DynamicData on my system (3.5 Sp 1) and the debug symbols on the server don't match because stepping through most of the code the current line didn't match what the debugger was seeing.

Finally a collegue who had been using the DynamicData sample application (and wasn't having problems) compared his project with mine and pointed out that the sample project didn't have an edmx file, but was using the csdl, ssdl and msl from a compiled edmx. So we re-added the adapter and container classes from the POCO generator and deleted the designer.cs file generated by Visual Studio for the edmx. This fixed the problem. So then we went into the properties for the edmx and removed the value for the "CustomTool" property setting to prevent the designer.cs class from being regenerated.

I'd like to dig further and figure out exactly what was causing the duplicate key issue, but for now I just wanted to describe the issue and point out the solution/workaround.
