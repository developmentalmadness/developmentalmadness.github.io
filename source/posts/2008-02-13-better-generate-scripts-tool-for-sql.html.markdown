---
layout: post
title: Better Generate Scripts Tool for SQL 2005
date: '2008-02-13 20:20:00'
tags:
- sql_tools
- sql_server
- dba
---

Frustrated by the inability to script SQL Server 2005 objects with BOTH a CREATE and DROP statement? Generally, I write all my scripts with both statements and then save them and include them in source control, so this hasn't really been a problem for me. But I recently started working on a new project where stored proceedures haven't been maintained in source control and the generate scripts tool is used to sync changes between environments and there are a lot of stored procedures.


So I decided to google for a way to get around this. Greatfully the SqlTeam has created an app named "Scriptio". It lets you generate both CREATE and DROP and has very flexible options similar to SQL 2000 options. You can find it here:


http://www.sqlteam.com/publish/scriptio/.


And for credit where it's due, here's where I heard about it:


http://weblogs.sqlteam.com/tarad/archive/2006/09/20/12374.aspx.


Thanks to Tara Kizer!