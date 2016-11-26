---
layout: post
title: Use SQL Parameters to Overcome Ad Hoc Performance Issues
date: '2007-01-12 20:30:00'
tags:
- sql_parameters
- dynamic_sql
- injection_attacks
- sql_performance
---

As I look around the net at different articles and tutorials I'm surprised at how many use Dynamic SQL for samples. Even after the many warnings about SQL injection attacks. But there are other issues besides security. One of which is performance - dynamic SQL performs very poorly when not used properly. So I decided to write an article pointing out how poorly dynamic SQL can be if improperly used. I hope it will convince some to change how they write their client SQL code. Here's the link:

http://www.codeproject.com/cs/database/ParameterizingAdHocSQL.asp

I might even write another article that expands on this idea to put down the misconception that as long as stored procedures are used that the database is free from SQL injection vulnerabilities.