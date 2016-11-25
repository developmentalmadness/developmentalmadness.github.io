---
layout: post
title: 'Visual Studio 2008: Missing XAML Display Items From Fonts and Colors'
date: '2009-03-03 18:32:00'
---

The members of my team and I have been playing around with our fonts and colors settings over the last few weeks. We’ve downloaded a couple published settings files from some well known bloggers such as Conery and Hanselman and tweaked them a little.

I was sent a copy of some settings from Rob Conery and the XAML settings were unreadable. I don’t know where the settings originated or how old they were but the background was black and the foreground colors where bright red and blue. I couldn’t read them. Other than that I really like the color scheme.

So I decided to go in and modify the color settings for XAML. But they were missing completely from my “Display Items” list. (Tools – Options… – Environment – Fonts and Colors – Display Items). I ran a search and a couple posts mentioned running "devenv /setup” from the command line. But when I did I got the following error from Visual Studio:

**<font color="#ff0000">The operation could not be completed. The requested operation requires elevation.</font>**

I am running Vista x32 with a non-admin account. Usually I just get a prompt for administrator credentials, but not this time. So I decided to try runas from the command line:

runas /user:administrator “devenv /setup”

This worked – for the admin account. I opened an instance of Visual Studio and was still missing the XAML display items, but if I opened Visual Studio as administrator they XAML items were all there.

So then I tried adding myself to the Administrators group in Windows. I figured, I’d temporarily elevate my privileges, run the command and then revert my access rights back to normal. Well, this didn’t work either, I still got the same error message.

So finally after digging around a while longer, I found an off-topic post when mentioned running

devenv /resetskippkgs

I had done this before for something else and hadn’t had a problem. So I decided to try it. This worked. It didn’t require admin privileges and I got my XAML settings back. Afterwards, I just mirrored the XML settings to the XAML settings and I’m now enjoying Rob’s theme.