---
layout: post
title: 'ASP.NET: System.BadImageFormatException'
date: '2009-05-26 15:39:00'
tags:
- windows_7
- windows_vista
- iis_7_0
- asp_net
---

If you are running on [Vista x64](http://www.microsoft.com/windows/windows-vista/default.aspx)

[**<font color="#ff0000">_System.BadImageFormatException_</font>**](http://msdn.microsoft.com/en-us/library/system.badimageformatexception.aspx)

By default IIS 7 won’t load x86 (32 bit) assemblies, make sure you set your application pool’s “Enable 32-Bit Applications” setting to “True”.

<font face="Courier New">Internet Information Services (IIS) Manager > Application Pools > {Your App Pool} > Advanced Settings > Enable 32-Bit Applications</font>

If this still doesn’t work. Try changing your build configuration platform setting for each project in your solution from “Any CPU” to “x86” and then rebuilding your solution.

<font face="Courier New">Right-click Visual Studio Project File in Solution Explorer > Properties > Build > Platform</font>