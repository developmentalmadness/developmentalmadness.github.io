---
layout: post
title: Viewing XML Query Plans in SSMS
date: '2006-11-21 20:31:00'
tags:
- ssms
- sql_server_management_studio
- sql_query_plan
- sql_server
---

Well after a long absence due to a crazy workload, I'm baaaack!

Keepin' it simple at this point. I've resumed studying for MCTS exams and I've been reading about dynamic management views. I love them. What's more, I love the detail they provide and the capability for deeper analysis.

So today I was exploring sys.dm_exec_query_stats and I run across the ability to use CROSS APPLY to view the execution plan xml or the sql text using sys.dm_exec_query_plan and sys.dm_exec_sql_text. I'm really excited about this - I figure I can use all these together like I might use Profiler to find problem queries. For example:

    SELECT * FROM sys.dm_exec_query_stats
    CROSS APPLY sys.dm_exec_query_plan(plan_handle)
    ORDER BY max_elapsed_time DESC

The result is an additional column, query_plan. Which is the XML show plan. But when I tried to save the result and open it to view the graphical execution plan I got errors.

The first error was an "unexpected error" which can be reproduced by first, clicking the link in the results pane which is available when
a field contains XML. This opens a new query window to display the XML. When I used "Save As..." to save the file as a *.sqlplan file, then tried to open the file I get an "unexpected error" message from Visual Studio (SSMS). Fortunately, I found that if I close the file and then open it to view the graphical plan, it works. I'm assuming there must be some file handle problem.

The second error occurs if I right-click the xml in the results pane and select "Save Results As...". I'm sure some of you who will be
reading this have already realized what I did wrong. Yes, it's embarrassing, but I write this blog to publish those stupid mistakes in hopes
that someone else experiencing a brain-lapse (as I often do) might find help.


Anyway, back to the problem, when I try to open the results I get the following:


    TITLE: Microsoft SQL Server Management Studio
    ------------------------------
    
    Error loading execution plan XML file {path}\query_plan4.sqlplan. (SQLEditors)
    
    ------------------------------
    ADDITIONAL INFORMATION:
    
    There is an error in XML document (1, 1). (System.Xml)
    
    ------------------------------
    
    Data at the root level is invalid. Line 1, position 1. (System.Xml)
    
    ------------------------------
    BUTTONS:
    
    OK
    ------------------------------


For those who haven't figured the problem out already, the answer is that you can't open a CSV file (output of "Save Results As...") using the execution plan editor, no matter what extension you save it as. Just cause the extension is .sqlplan, doesn't mean that's the contents of the file.
