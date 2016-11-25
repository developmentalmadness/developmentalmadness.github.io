---
layout: post
title: 'PRB: ''That assembly does not allow partially trusted callers.'' When installing
  a CRI on a dedicated SSRS server'
date: '2008-05-05 18:42:00'
tags:
- customreportitem
- ssrs
- sql_server_reporting_services
- cri
---

I have been fighting a "permissions" issue with Sql Server Reporting Services (SSRS) for the last few days. When I run my Custom Report Item (CRI) on my local instance of SSRS it works fine. But when I try to install the CRI on a dedicated server running SSRS I was getting the following error:

> **That assembly does not allow partially trusted callers.**

When I compared my local rssrvpolicy.config file with the one on the server they were identical. So I shouldn't have been getting the permissions error. Things were complicated by the fact that I was trying to troubleshoot the issue on the server without any access to the server. I didn't install the CRI assembly and was trying to guess at the issue.

Well today I stumbled on the issue when I finally got access to the server and tried to locate the assembly in the path I had instructed it to be installed. That path was:

    C:\Program Files\Microsoft SQL Server\MSSQL.3\Reporting Services\ReportServer\bin

The same path used by all the CRI demos and the same path as on my machine. Well it turns out the path the assembly was installed on was :

    C:\Program Files\Microsoft SQL Server\MSSQL.1\Reporting Services\ReportServer\bin

So after looking around I found this MSDN article: http://msdn.microsoft.com/en-us/library/ms143547.aspx. It explains that some MS SQL services require their own instance path and that 3 and 1 are the instanceId in MSSQL.3 and MSSQL.1. So while every other machine had worked because they were all dev machines which were not dedicated to SSRS, the target server had not worked because there weren't any other MS SQL services installed.

This caused the problem because the path used in rssrvpolicy.config was pointing to the wrong path because of the difference in the instanceId. So when installing your CRI to a new environment, make sure that you check the instanceId for SSRS, otherwise you'll get a permissions error.