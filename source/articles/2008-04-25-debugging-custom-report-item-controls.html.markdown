---
layout: post
title: Debugging Custom Report Item controls for Sql Server Reporting Services
date: '2008-04-25 18:46:00'
tags:
- customreportitem
- ssrs
- sql_server_reporting_services
- cri
- debugging
---

When you are developing a control which inherits from CustomReportItem for Sql Server Reporting Services (SSRS) you will certainly want to debug your code. The documentation is shoddy and at best incomplete, and the examples are poorly explained. So being able to debug your control is paramount to your success.

The way to setup debugging follow these steps:

1. Open the project properties for your custom report item (right click project - Properties...)
* Set debug properties (Click "Debug" tab on the left)
* Set start action (under start action click "Start External Program")
* Browse for DevEnv.exe (`C:Program Files\Microsoft Visual Studio 8\Common7\IDE\devenv.exe`)
* Set command line arguments (enter the path to your test solution - a reporting services project)
* Save your property changes