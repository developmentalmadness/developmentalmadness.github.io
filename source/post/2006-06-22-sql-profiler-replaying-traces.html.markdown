---
layout: post
title: SQL Profiler - Replaying Traces
date: '2006-06-22 20:00:00'
tags:
- sql_tools
- sql_server
- sql_performance
- dba
---

SQL Profiler has been aptly referred to as the "poor man's load tester".

3 months ago I captured trace logs spanning 1 week. My intent was over the summer (our companies "off-season") to use the trace logs to stress test the database to determine the results of server and database configuration changes. Now I'm spending most of my morning trying to replay the trace logs I created using the system stored procedures 3 months ago.

Well, here's what I've discovered:

* The database ID in the trace log has to match the database id of the database on the server where you are replaying the trace.
* The login name has to match the login name you are using to connect to the server where you are replaying the trace.
* The login you are using must have their default database set to the database you are replaying the trace against.
* The login you are using to replay the trace must have permissions to replay the commands you've captured in your trace.
* The trace captured by the SQL 2000 stored procedures (by default) will not replay with SQL Profiler 2005.

I'm sure someone will tell me that I haven't captured all the correct events. And that may be so. But I'm still pretty new (relatively) to DBA responsibilities. I'm planning on using our SQL Server upgrade this summer as a chance to learn to do DBA stuff the right way and maybe get certified while I'm at it.

Wish me luck.