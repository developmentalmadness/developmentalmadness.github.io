---
layout: post
title: Use Table-Valued Functions as Arrays in SQL Server
date: '2007-02-27 20:26:00'
tags:
- sql_clr
- sql_parameters
- sql_arrays
- sql_in
- table_valued_functions
- sql_performance
---

I've started investigating the SQL CLR and decided as my first article to tie in a bit to my article on using SQL parameters in ad hoc queries. This time I'm touching on an advanced topic of sql parameters - how to pass an array as a parameter. This takes advantage of the performance benefit you get from parameters because the plan can be cached for queries that use dynamic IN statements.

http://www.codeproject.com/cs/database/TableValuedFnsAsArrays.asp

Next, I plan on writing a series of articles on the SQL CLR discussing the following topics:

1. CLR Security
* CLR Performance/Stability
* CLR vs T-SQL
* CLR Best Practices

I've almost finished the first article on security, it's been very enlightening. Code Access Security is really a big part of how SQL Server is able to host the CLR in a secure and stable environment. I'm really amazed at how the CLR was designed in such a way that allows it not only to be hosted that any application that wants to take advantage of the CLR, but also at the way it allows the host to restrict unwanted functionality.