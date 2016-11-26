---
layout: post
title: Installing Windows 7 On My New G.Skill SSD
date: '2009-05-25 13:57:00'
tags:
- windows_7
- g_skill_ssd_drive
---

I got a new Thursday and I’ve been repaving my laptop with [Windows 7 x64 RC](http://www.microsoft.com/windows/windows-7/)

The first thing was that Windows install time was about 30 min. This was my first confirmation that I was gonna love my new drive.

The first thing I installed was [Visual Studio Team System](http://msdn.microsoft.com/en-us/teamsystem/default.aspx)

#### Oracle 10gR2 Client

The first hiccup I ran into was installing Oracle client software. I ran the installer and after starting the installer I was immediately informed that the installer required Windows. 6.1\. Fortunately I found [this post](http://social.technet.microsoft.com/Forums/en-US/w7itproappcompat/thread/f7d8b471-54fb-44be-b9d8-263db8c18b1e)

setup.exe –ignoreSysPrereqs

#### MS LifeCam

I bought a new web cam about 2 weeks ago, so I was pretty sure I wouldn’t have a problem with this at all, but the 2.5 client install disk wouldn’t run. Instead I was prompted by Windows to get an update from Microsoft and it downloaded and installed the 3.0 client for me.

I was really impressed by the experience because after the install failed I was pretty bummed. I had purchased the web cam for my upcoming trip to Cancun so we could video chat with our kids while we were away. I only have one laptop and I immediately thought I was going to have to stick with Vista.

But Windows immediately detected the problem, checked the Microsoft site for an update and pointed me to the download link.

#### Dell nVidia Drivers

This was the only driver that had any problems out of the box. When I say problems I mean, it didn’t support the widescreen resolutions and I had to go to dell and download the Vista x64 drivers. But once I downloaded the drivers from Dell the installation was smooth and was done in about 30 seconds.

#### Toad 9.0.1.8 and Oracle 10gR2 Client

I had a little trouble here. I’m running the x64 version of Windows 7 and ran into the “can’t load oci.dll” error. There are two reasons for this problem. First, Toad is an x86 client and so it can’t load the x64 dlls. Second, Toad is looking for ORACLE_HOME under HKLM\Software\Wow6432Node\Oracle and the x64 client installs under HKLM\Software\Oracle. Turns out you need to load the of the Oracle client along with [Toad](http://www.toadsoft.com/)

## Where the heck is it?

There were a couple things that alluded me from the start. Where are the folder options? And, how do I map a network drive? The fact that these were missing really annoyed me, since they have been right in the same place for so long – in Windows Explorer, right where they belong. I haven’t looked yet, but I’m hoping there’s an option to put them back.

#### Folder Options

Control Panel > All Control Panel Items

I couldn’t find how to navigate to this window and I don’t know yet what category this is under, but the nice thing is if you just type in “Control Panel\All Control Panel Items” into your Windows Explorer address bar you’ll get there.

#### Map Network Drive…

To map a network drive I found the command under the “My Computer” context menu:

Start Menu –> Right-click “My Computer” –> Map Network Drive…

## First Blush

#### Windows 7

My overall first impressions of Windows 7 are good. Other than the video drivers, my experience hasn’t been any different than normal complications you’d experience when running a 64-bit Windows client. I tried running XP x64 when it was released and ended by giving up, so I’ve been pleasantly surprised. I’ll continue to update as I run into other problems in order to help those who run into the same problems.

#### G.Skill SSD

This is just awesome! Everything screams: boot/reboot, opening applications (including Visual Studio), installing applications, Windows Explorer, file deletions, extracting large ISO files (Visual Studio, Office 2007) and the list goes on and on. I can multitask I/O-intensive operations without batting an eye. Before I had to try and keep heavy I/O lifting to one item at a time. Now I can run multiple operations at the same time. I couldn’t be more pleased.