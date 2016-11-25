---
layout: post
title: Search the source of SQL Server views and stored procedures
date: '2008-02-18 20:18:00'
tags:
- sql_tools
- ssms
- sql_server
---

Ever have to work on a database with a large number of views and you needed to search the content of the objects? Well, here's a query which will allow you to search inside your view objects:

    DECLARE @search VARCHAR(1000)
    SET @search = '[text]'
    
    SELECT c.[Text]
    FROM dbo.sysobjects AS v
    INNER JOIN dbo.syscomments c ON c.id = v.id
     AND CASE WHEN c.Number > 1 THEN c.Number
       ELSE 0 END = 0
    WHERE v.type = 'V' AND c.[Text] LIKE '%' + @search + '%'
    

Just set the value of @search to the value you'd like to find.

This was very useful to me as I was trying to muddle through an application which used a lot of nested views and I needed to determine which views referenced the view I was working on.

As a bonus (and of course for my own benefit) here's a method to search the source of stored procedures:

    DECLARE @find VARCHAR(1000)
    
    SET @find = '{search text here}'
    
    SELECT
    sp.name,
    ISNULL(smsp.definition, ssmsp.definition) AS [Definition]
    FROM
    sys.all_objects AS sp
    LEFT OUTER JOIN sys.sql_modules AS smsp ON smsp.object_id = sp.object_id
    LEFT OUTER JOIN sys.system_sql_modules AS ssmsp ON ssmsp.object_id = sp.object_id
    WHERE
    (sp.type = N'P' OR sp.type = N'RF' OR sp.type='PC')
    AND ISNULL(smsp.definition, ssmsp.definition) LIKE '%' + @find + '%'
    
