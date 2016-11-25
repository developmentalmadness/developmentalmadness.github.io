---
layout: post
title: 'ASP.NET MVC Globalization/Localization: Referencing Resource Files in Your
  View'
date: '2009-05-20 21:03:00'
tags:
- localization
- asp_net_mvc
---

I’ve been using [ASP.NET MVC](http://www.asp.net/mvc/)

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> 1: <%=Resources.MyResourceFile.MyResourceKey%></pre>

Until today, I took that for granted. I received an email this morning referencing on [ASP.NET.](http://www.asp.net/)

## Create Your Resource (.resx) File

There are 3 ways to create a Resources file in an ASP.NET application (MVC or WebForms):

1. **Add New Item**: Right-click anyware –> Add –> New Item…
2. Add to App_GlobalResources:

1. Right-click your project –> Add –> Add ASP.NET Folder –> App_GlobalResources
2. Right-click App_GlobalResources –> Add –> New Item…

4. Add to App_LocalResources:

1. Right-click a folder –> Add –> Add ASP.NET Folder –> App_LocalResources

## Local Resource Files

1 and 3 are essentially the same, I’ll refer to the result as a local resource file.When you create a local resource file all you need to do after you’ve added a view string values to the file is change the “Access Modifier” setting to “Public”.

[![VSResourceFile](http://lh6.ggpht.com/_09jBj8qnWKM/ShRwKLcJwuI/AAAAAAAAACs/jq92gPbQOHQ/VSResourceFile_thumb%5B3%5D.gif?imgmax=800 "VSResourceFile")](http://lh3.ggpht.com/_09jBj8qnWKM/ShRwJ3ZDcbI/AAAAAAAAACo/tXGtWxhHZbE/s1600-h/VSResourceFile%5B7%5D.gif)

The only difference (as far as I can tell) between 1 and 3 is that the default value for Access Modifier for 1 is “Internal” and for 3 it’s “No code generation”. There may be some differences with regard to WebForms, but honestly I never noticed before.

## Global Resource Files

Number 2 is just as easy, but there is a little more to explain, and here’s why: you can’t change the Access Modifier for a Global Resource File. If you create a Global Resource File and open it you’ll notice the option is disabled.

[![VSGlobalResourceFile](http://lh6.ggpht.com/_09jBj8qnWKM/ShRwKtrHAKI/AAAAAAAAAC0/gJhRl_4hdlE/VSGlobalResourceFile_thumb%5B4%5D.gif?imgmax=800 "VSGlobalResourceFile")](http://lh6.ggpht.com/_09jBj8qnWKM/ShRwKd5UgBI/AAAAAAAAACw/OkP2uiO-SxI/s1600-h/VSGlobalResourceFile%5B6%5D.gif)

The only option for a Global Resource File is “Internal”. It reads public on the toolbar. But if you look at the designer.cs file you will see that the class and all its properties are marked as “internal”.

However, you can still easily use a Global Resource File, with just one caveat. Intellisense doesn’t quite work the way you would expect (or maybe you would). The namespace will show up on intellisense, the class name will not, but once you have correctly typed the namespace and class name you’ll get intellisense for all your keys.

Here you see the namespace in intellisense:

[![VSIntellisenseNamespace](http://lh3.ggpht.com/_09jBj8qnWKM/ShRwLBwqYqI/AAAAAAAAAC8/aynrBfxrda4/VSIntellisenseNamespace_thumb%5B5%5D.gif?imgmax=800 "VSIntellisenseNamespace")](http://lh3.ggpht.com/_09jBj8qnWKM/ShRwK3onKcI/AAAAAAAAAC4/bUVQPw6tEZc/s1600-h/VSIntellisenseNamespace%5B7%5D.gif)

Here you see nothing comes up for the class:

[![VSIntellisenseClass](http://lh5.ggpht.com/_09jBj8qnWKM/ShRwL4gtbfI/AAAAAAAAADE/VDHBs_dYodA/VSIntellisenseClass_thumb%5B6%5D.gif?imgmax=800 "VSIntellisenseClass")](http://lh4.ggpht.com/_09jBj8qnWKM/ShRwLjpdsrI/AAAAAAAAADA/FCHx8m53mig/s1600-h/VSIntellisenseClass%5B8%5D.gif)

But here you see the keys are picked up by intellisense once you enter the class name correctly:

[![VSIntellisenseProperties](http://lh6.ggpht.com/_09jBj8qnWKM/ShRwMb7A9bI/AAAAAAAAADM/gYqK3sfXeYM/VSIntellisenseProperties_thumb%5B3%5D.gif?imgmax=800 "VSIntellisenseProperties")](http://lh6.ggpht.com/_09jBj8qnWKM/ShRwMJIFtuI/AAAAAAAAADI/iTfqgsF4978/s1600-h/VSIntellisenseProperties%5B5%5D.gif)

The funny thing is that this is not always true. Sometimes you will get intellisense for the class name and sometimes you won’t. Either way you can either use Local Resource Files or as suggested by in his book [Pro ASP.NET MVC Framework](http://www.amazon.com/gp/product/1430210079?ie=UTF8&tag=stesansblo-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=1430210079)

I’ve seen [extension functions](http://blog.eworldui.net/post/2008/05/ASPNET-MVC---Localization.aspx)