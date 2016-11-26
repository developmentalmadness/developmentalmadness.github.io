---
layout: post
title: Fast RowCount for SQL 2005
date: '2008-04-01 19:02:00'
tags:
- sql_server_performance
- sql_server
- sql_performance
- dba
---

This is nothing new or revolutionary, but is important nonetheless for those maintaining large-scale SQL Server databases. For years I've used the sysindexes system table to find out how many rows are in a large table. The reason for this is to prevent table scans of large tables just to find out how many rows are in that table.

Sometimes you just gotta know and you don't need a custom filter, just the raw row count. If you use `SELECT COUNT(*) FROM myTable` you scan the whole table affecting the performance of your server.

For those who've never heard of this here's the sysindexes version for a single table:

    SELECT OBJECT_NAME(N'myTable') AS [Name], rows FROM sysindexes WHERE id = OBJECT_ID(N'myTable') AND indid < 2

Well, I've always used this version up to now but with the new catalog views in SQL Server 2005 and the looming obsolescence of the old system tables with newer upcoming versions of SQL Server (no I don't know if they will still be available for SQL 2008, but the existence of the System Catalogs indicates System Tables are going away) I decided I should figure out where this information is now stored.

As it turns out the information is stored in the sys.partitions catalog. And here's the syntax:

    SELECT OBJECT_NAME(P.object_id) AS [Name], P.* FROM sys.indexes I
    INNER JOIN sys.partitions P ON P.object_id = I.object_id AND P.index_id = I.index_id
    WHERE I.index_id < 2 AND P.object_id = OBJECT_ID(N'myTable')


So while many of you may already know about this, I figured the post could be at least helpful to myself for reference until I know it without having to look it up. But, as always, I also hope that I can help someone out there who is looking for exactly this.