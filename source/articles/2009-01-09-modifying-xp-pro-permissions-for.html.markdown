---
layout: post
title: Modifying XP Pro Permissions For Workgroup Computers
date: '2009-01-09 18:25:00'
tags:
- workgroup_permissions
- xp_professional
- cacls
---

Sql Server best practices recommend using a local, low-permissions account as the service account. But if your machine isn't a member of a domain then you don't get a security tab in the folder properties window. There's many reasons to want to control permissions when you're not on a domain, but how can you do it?

I had to do this today and I realized this wasn't something that was obvious to everyone, so I thought I'd make a quick post about it.

<h2><font color="#00ff00"><strong>UPDATE - 1/28/2009</strong></font></h2>

I have found there is a much better (read: safer) way to accomplish what is described below. I'm going to leave the instructions as I originally wrote them because they are still useful for using cacls, but here's a much safer way to do it.

Open Windows Explorer, then from the "Tools" menu select "Folder Options...". Select the "View" tab and uncheck the option "Use simple file sharing (Recommended)".

Changing setting now gives you the "Security" tab the next time you open the property window for any folder. The "Sharing" tab also has more options for advanced users. The reason this option is "recommended" is because it is for advanced users. If you're like me and you know what you're doing I prefer this setting turned off. 

<h2><font color="#00ff00"><strong>END UPDATE</strong></font></h2>

The command console has a command named "cacls" which allows you to manage NTFS permissions and this is built-in to XP and you can use it even if the UI doesn't give you a tool to manage these. Does this mean you can use this for XP Home as well? I don't know. I don't own Home Edition. I never have so I haven't been able to test this, but it would be easy for someone to confirm. If you do, please post a comment.

Anyway here's an example of the command. I created a folder with the path C:\Data for my Sql server account named (what else?) "sqlserver". I want to grant "change" (aka modify) permissions. You could use "Full Control", but Sql Server doesn't require Full Control, so why grant unnecessary rights?

WARNING: Incorrect use of cacls can cause you to loose access to the folder, even for administrators. Always use the /E switch as an argument unless you know what you're doing and intent to completely replace permissions on the folder.


1. From the Windows "Start" menu, select "Run..."
* Type "cmd", then hit "Ok"
* Type the following in your command window:

    cacls /E /T /G sqlserver:C C:\Data

The /E switch (mentioned in the warning above) tells cacls to Edit the permissions. If you omit /E then the permissions will be completely replaced.

/T will include the change for all subfolders.

/G is the "Grant" switch. Following /G should be the account name, then a colon followed by the permissions to grant. In this case "C" represents "Change". Then add the path of the file/folder which you're updating.

If you want to see additional options/parameters for cacls, just type "cacls /?" and you'll get the help printed to the window.
