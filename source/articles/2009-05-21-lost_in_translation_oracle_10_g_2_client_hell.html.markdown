---
layout: post
title: 'Lost in Translation: Oracle 10g2 client hell'
date: '2009-05-21 20:19:00'
tags:
- lost_in_translation
- oracle
---

This is a post I’ve been meaning to write for a while. I had quite a bit of trouble getting the Oracle client working properly since I started with my current client. I’ve never used Oracle before and so it’s been pretty frustrating since I’ve wanted the opportunity to work with it for a long time. But it turns out that the solutions have been pretty simple. Here’s a list of some of the problems I’ve run into and their solutions:

1. Use Admin install – When it comes to software/services that open up ports to the outside world I’m a fan of installing only what I need. So I was disappointed when our DBA told me that my first problem was that I needed the Admin install and that Instant client didn’t have everything I needed. But I’m thinking I’ll try Instant Client again now that I’ve resolved my other problems which I think were the cause. If I ever get around to it, I’ll update this post.
2. Make sure you have Vista installer – I was given an installer for Oracle client that was stored on my client’s LAN, so that was the one I used. But it turns out that the installer wasn’t compatible with Vista. Oracle has a specific client for both the and [64-bit](http://www.oracle.com/technology/software/products/database/oracle10g/htdocs/10204_winx64_vista_win2k8.html)
3. Make sure ORACLE_HOME environment variable matches the **<u>_path_</u>** to your client installation (the parent folder of your bin directory). You need to make sure the correct values are in the following places:

* HKLM\Sofware\Oracle\ORACLE_HOME – this should be the path of your oracle home folder (the parent folder of your bin directory, but not including “\bin”). If you accepted the defaults during installation it should be something like: C:\oracle\product\10.2.0\client_1
* PATH environment variable – this should be the full path to the “bin” directory. Using the same setup as above this should be: C:\oracle\product\10.2.0\client_1\bin.
* Also, you may need an ORACLE_HOME environment variable. You can add this and assign it the same value as the registry key above.

## Errors

#### Can not load Oracle client library oci.dll from home

I had this problem trying to load TOAD and when I finally thought about it things made sense. TOAD couldn’t find the bin directory based on the paths in PATH and ORACLE home. Make sure you check #3 above to verify all this is correct.

I also had a variation on this error when I was running a 64-bit OS. You’d think you should install the x64 Oracle client if your OS is 64-bit. But since TOAD is a 32-bit client you’ll need to install the x86 Oracle client. (See #2 above)

#### Can not load Oracle client. Check your PATH environment variable and registry settings

This was the error I got from DevArt’s dotConnect client for .NET Entity Framework. Unfortunately, the problem here was still causing me headaches even after I got the paths right. I also had to make sure that I had the Vista client installed. Once I did this, I no longer had this problem.