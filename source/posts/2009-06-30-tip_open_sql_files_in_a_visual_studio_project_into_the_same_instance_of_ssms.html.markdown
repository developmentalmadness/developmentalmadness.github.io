---
layout: post
title: 'TIP: Open SQL Files in a Visual Studio Project Into the Same Instance of SSMS'
date: '2009-06-30 16:05:00'
tags:
- ssms
- sql_server_management_studio
- sql
- visual_studio
---

Considering how integrated Microsoft tools usually are the result is frustrating when you tell to open SQL files using [Sql Server Management Studio](http://msdn.microsoft.com/en-us/library/ms174173.aspx)

1. Open a solution which contains SQL files
2. Right-click any SQL file and select “Open With…”
3. Click “Add”
4. Browse to "C:\Program Files\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\Ssms.exe" or if you’re running x64 Windows "C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\Ssms.exe", then click “OK”
5. Click “Set as Default” and then “OK”

Now open multiple SQL files. Each time you’ll get a different instance of SSMS opened. What a pain!

**<u>NOTE</u>**: This entire article applies to SQL 2005, just replace SSMS with SQLWB.

How do you resolve this? Repeat steps 1-3 above, but at step #4 enter the following values:

* Program Name: “explorer.exe”
* Friendly Name: “Windows Explorer”

Repeat step #5 (set as default) above and then click OK. Now, open additional files. They should all open in the same instance of SSMS.

It would seem that Visual Studio issues a command to SSMS.exe which includes the path of the file selected in the solution explorer. It is up to SSMS to check for a new instance, which it doesn’t. But when you pass the file name to explorer it gets opened up in the same instance.

**<font color="#ff0000">QUIRK WARNING!</font>**

If SSMS is not already open, the first file you attempt to open (not first time ever, but every time you open an SQL file from Visual Studio and SSMS isn’t open yet) SSMS will open, but your file will not. Click the file a 2nd time and it will open the file this time. Don’t ask me to explain it it just is (and I have no idea why).

## Conclusion

The result when you tell Visual Studio that SSMS is the default editor makes sense, but I don’t get why it would be different when you tell explorer to open it. Maybe if I were a Windows developer instead of a web developer I would know the answer. But either way, now you know. Enjoy.