---
layout: post
title: Open SQL 2008 Management Studio from Run... command
date: '2008-08-15 17:53:00'
---

Since SQL 2005 was first released I have always opened it from the run command in the start menu by typing "sqlwb" after hitting the Windows+R shortcut (Run... command). Why? Because no matter where I am it's the quickest way to open SSMS without using the mouse. Most of the time, because the run window uses autocomplete I only have to type "sq".

So after I installed SQL Server 2008 RTM yesterday (I haven't had any time to mess with the Beta and RC releases because I've been focused on learning ASP.NET MVC, WCF, ExtJs and developing my ExtJs control library as well as a web startup - all in my free time), I started up SSMS '08 and checked my running processes in task manager (CTRL+SHIFT+Esc). What I found is that SSMS '08 is SSMS.exe. So now you can startup SSMS '08 with the following sequence: Windows+R then type ssms, hit enter and it's up and running.

For most of you I'm sure you could have figured this out on your own, but I felt like putting it out there for those who don't. Enjoy!