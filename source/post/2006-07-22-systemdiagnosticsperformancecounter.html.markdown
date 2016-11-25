---
layout: post
title: System.Diagnostics.PerformanceCounter Privileges Required to Monitor Remote
  Machines
date: '2006-07-22 19:36:00'
tags:
- windows_security
---

I've been pretty busy and haven't had time to post in a while, but this week I ran into something I thought was worthy of posting. I'm working on writing a "poor man's" load balancer for our databases. I won't go into the background this time as I will likely post details on the load balancer once I've completed it. But when it came time to work on gathering data using the System.Diagnostics.PerformanceCounter I ran into the expected permissions issue. Most examples involved using ASP.Net to display performance data, and all the examples I was running into recommended using either a privileged account, or impersonating the authenticated user. The former was often discouraged and the latter was the recommended means. The application could use windows authentication to secure the page and then only privileged users could get access to sensitive processes.

Well, my load balancer is a windows service so I didn't have the choice of impersonating the user's credentials, plus I don't like the idea of using privileged accounts anywhere in the application. After digging I found the following post:

http://www.testingreflections.com/node/view/1032

which pointed me to the following MS article:

http://support.microsoft.com/default.aspx?scid=kb;en-us;Q300702

Based on the MS article here's how I implemented 'least privilege':

Create new domain group - I called it 'Performance Counter Monitors' - add it to the local group 'Performance Monitor Users'. The local group has already been granted some of the necessary privileges. Then grant read permissions to the local group on:


    HKLM\System\CurrentControlSet\Services\ControlSecurePipeServers\WinReg

    %SYSTEMROOT%\System32\Perfh.dat

    %SYSTEMROOT%\System32\Perfc.dat



According to the article, if you need access to performance counter data for specific services you'll need to grant additional access.


If you're going to be displaying data using PerformanceCounter in your application I would of course recommend securing the page and only granting access to privileged users, but there's no need to impersonate when your doesn't need the additional permissions. But if your application needs access to the PerformanceCounter data on a wide scale use the above method to enforce 'least privilege'.


For those who are using a large web farm I'm sure there's a way to script the above changes, but since I've only got 6 machines I need to monitor at the moment I won't be taking the time to figure it out anytime soon.