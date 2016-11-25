---
layout: post
title: '"FIX" for Sys.WebForms.PageRequestManagerServerErrorException 12019 Problem
  with MultipleIEs'
date: '2008-04-24 18:57:00'
tags:
- asp_net_ajax
- ie_6
- multipleies
---

Before I started working with ASP.NET Ajax I found using MultipleIEs very valuable for testing pages for both IE6 and IE7. But then I started working on a project which had been developed using the ASP.NET UpdatePanel and IE6 became worthless. I got the error 
> **"Sys.WebForms.PageRequestManagerServerErrorException" with an error number of 12019.**

But recently a user had a problem which could only be duplicated in IE6, so I had to figure out a way to get it to work on my machine. Fortunately, I stumbled on a thread on [tredosoft.com](http://tredosoft.com/Multiple_IE?page=2#comment-2421) which mentioned that copying msxml3.dll from your system32 folder to the multipleIEs/IE6 folder.

After doing this the error stopped and I could use the page. However, the main problem is that the UpdatePanel still does not. So I can manipulate the form elements, but the UpdatePanel doesn't update the section of the page which is tied to the event.

So if anyone happens to know what else needs to be done, I would love to know.