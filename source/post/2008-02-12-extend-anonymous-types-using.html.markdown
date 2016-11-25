---
layout: post
title: Extend Anonymous Types using Reflection.Emit
date: '2008-02-12 17:02:00'
tags:
- net_framework_3_5
- anonymous_types
- reflection_emit
- asp_net
- asp_net_mvc
---

**Update 2015 Dec 28:** It has been brought to my attention that this code has been enhanced by [Kyle Finley](http://kylefinley.net/). You can read about his enhancements [here](http://kylefinley.net/typemerger) and the [source code](https://github.com/kfinley/TypeMerger) is available on Github. Kyle has told me he plans to release a NuGet package which I will link to when it becomes available. 

I've been playing with the new ASP.NET MVC Framework CTP which uses anonymous types to build url paths which allow you to change the path format. I'm really enjoying the control and the separation of concerns you get.


As I've been writing my MVC application I needed to maintain a parameter in all urls for authenticated users but I didn't want to have to manually include the paramter in every url, form action and redirect. So I wrote some extension functions which wrap the Html and Url helper class methods used to build urls (ActionLink, Form and Url). Additionally, I wrote a controller class which inherits from Controller and overrides RedirectToAction. Then each of my contrllers inherit from my class like this Controller --> myBaseController --> [Instance]Controller. Each of these methods has a set of overloads with a similar signature. In particular each has an overload which accepts an object. This is used to pass in an anonymous type like this:


    Html.ActionLink("click here", new {Controller = "Home", Action = "Index", Id = 8 });
    RedirectToAction(new {Controller = "Home", Action = "Index", CustomParam = 123});


My wrapper methods needed to append an additional parameter. So initially I was able to do this by creating a new anonymous type composed of the passed in type and my new field like this:


    var newValues = new { values, myParam = "user value" };


I chose this method because the object passed in could have any number of properties of any type and so there was no way for me to discover then and create a new type composed of the type and my own type.


This worked great as long as I used my wrapper methods and my controller classes inherited from my custom class.


However, my wrapper methods and controller class were local to my web application in the App_Code directory. So I decided that I wanted to use these classes as part of an MVC library of classes for all my MVC applications. But when I moved these classes to a class library project and these classes were now in an assembly which was external to the web application everything broke down.


Stepping through the code I realized that the anonymous types I was composing was now creating not one type with a composite of the properties of both objects, but an object only two properties. One property was the parameter I was trying to add, the other was a single property of the type of anonymous object passed in as an argument to my method like this in the debugger:


    {{Controller = "Home", Action = "Index"}, myParam = "user value"}


As you can see the first type is made a "subtype" of the new type. So I tried converting the types to a dictionary (which is essentially what an anonymous type is). But that didn't work. Reading up on anonymous types I found that the types are created at compile time and types with matching interfaces are reused by creating a single type for all matches. But I needed to create a type at runtime.


I've worked on a project before where we had origionally planned on creating runtime types using Reflection.Emit, but we decided to save the result as an assembly so we could have it at compile time. I figured if I could dynamically discover the properties of the anonymous type and then create a new type which combined the existing properties plus my own then I could pass that as an argument to the url builder methods of the MVC framework. So I read up as a refresher and decided it sounded good in theory. I then proceeded to write up a proof of concept and it worked!


The process works like this: First use System.ComponentModel.GetProperties to get a PropertyDescriptorCollection from the anonymous type. Fire up Reflection.Emit to create a new dynamic assembly and use TypeBuilder to create a new type which is a composite of all the properties involved. Then cache the new type for reuse so you don't have to take the hit of building the new type every time you need it.


Below is the full class definition. I hope this helps someone out there or at least spurs some discussion about how effective this method is:

<script src="https://gist.github.com/developmentalmadness/4d2e202545c7d8e55166.js"></script>