---
layout: post
title: 'ASP.NET MVC: Compile Your Views for Release Build Only'
date: '2009-01-27 18:07:00'
tags:
- compile_checking
- msbuild
- views
- asp_net_mvc
---

First of all I have to say I'm excited. Today [Scott Guthrie announced](http://weblogs.asp.net/scottgu/archive/2009/01/27/asp-net-mvc-1-0-release-candidate-now-available.aspx) the Release Candidate (RC) for ASP.NET MVC is now available. And just yesterday my client signed off on the use of ASP.NET MVC for the project I'm currently ramping up. 

As I'm reading through the Release Notes and Scott's post, the first thing I wanted to setup was compile checking of my views. The recommendation is to only use this project setting when releasing your build to staging or production because of the time required. I gave it a shot with a brand-new MVC application and the difference was several seconds when the setting is enabled, compared to instant when the setting is disabled. 

Visual Studio doesn't support this setting yet, but if you open your project `(*.csproj | *.vbproj)` up in notepad you'll see the following somewhere in the topmost PropertyGroup element:

    false

If you're updating an existing MVC project created with a pre-RC version of the MVC Framework the Release Notes tell you to add this "under the top-most element".  To turn on the setting, just change "false" to "true".

But as I mentioned before, both Scott and the Release Notes recommend against turning this on in the development environment. But if you're like me I will forget to turn this on when I'm ready for a release build. So I decided to try and move the MvcBuildViews element to both the debug and release PropertyGroups like this:



    <PropertyGroup>
      <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
      <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
          .... other settings ...
    </PropertyGroup>
    <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
      <MvcBuildViews>false</MvcBuildViews>
          .... other settings ...
    </PropertyGroup>
    <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
      <MvcBuildViews>true</MvcBuildViews>
          .... other settings ...
    </PropertyGroup>
    

Now you have your compile-time checking for your release build and you won't get the extended build time during development.  To check it out add the following somewhere in your Views/Home/Index.aspx view file:

    <p><%= (Int32) "String" %></p>

If your build is "debug" and you build your project you'll get a successful build. Now change your build to "release". This time you'll get a build error.

If you want this setting in all your MVC projects, just unzip the MVC project template (
`C:\Program Files\Microsoft Visual Studio 9.0\Common7\IDE\ProjectTemplates\CSharp\Web\1033\MvcWebApplicationProjectTemplateRC.cs.zip)`, modify the project file, then zip the project back up and replace it. 

I'm looking forward to finally be working on a production application using MVC, I'll try and provide updates as often as possible. 
