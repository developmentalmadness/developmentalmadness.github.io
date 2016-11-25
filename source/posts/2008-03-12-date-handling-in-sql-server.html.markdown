---
layout: post
title: SARGable DateTime Handling in SQL Server
date: '2008-03-12 19:12:00'
tags:
- sargable_datetime_handling
- sql_server
---

I can't believe I never thought of doing things this way before. It's so much better than concatenating strings and converting back and forth between varchar, int and datetime. I'd like to thank Marc for posting this jewel. Here's the link to the original content: [Marc's Musings: More on DATEs and SQL](http://musingmarc.blogspot.com/2006/07/more-on-dates-and-sql.html).

I'm including the actual functions below, just as a quick reference:

    SELECT DATEADD(dd, DATEDIFF(dd, 0, GetDate()), 0) As Today, 
        DATEADD(wk, DATEDIFF(wk, 0, GetDate()), 0) As ThisWeekStart, 
        DATEADD(mm, DATEDIFF(mm, 0, GetDate()), 0) As ThisMonthStart, 
        DATEADD(qq, DATEDIFF(qq, 0, GetDate()), 0) As ThisQuarterStart, 
        DATEADD(yy, DATEDIFF(yy, 0, GetDate()), 0) As ThisYearStart, 
        DATEADD(dd, DATEDIFF(dd, 0, GetDate()) + 1, 0) As Tomorrow, 
        DATEADD(wk, DATEDIFF(wk, 0, GetDate()) + 1, 0) As NextWeekStart, 
        DATEADD(mm, DATEDIFF(mm, 0, GetDate()) + 1, 0) As NextMonthStart, 
        DATEADD(qq, DATEDIFF(qq, 0, GetDate()) + 1, 0) As NextQuarterStart, 
        DATEADD(yy, DATEDIFF(yy, 0, GetDate()) + 1, 0) As NextYearStart, 
        DATEADD(ms, -3, DATEADD(dd, DATEDIFF(dd, 0, GetDate()) + 1, 0)) As TodayEnd, 
        DATEADD(ms, -3, DATEADD(wk, DATEDIFF(wk, 0, GetDate()) + 1, 0)) As ThisWeekEnd, 
        DATEADD(ms, -3, DATEADD(mm, DATEDIFF(mm, 0, GetDate()) + 1, 0)) As ThisMonthEnd, 
        DATEADD(ms, -3, DATEADD(qq, DATEDIFF(qq, 0, GetDate()) + 1, 0)) As ThisQuarterEnd, 
        DATEADD(ms, -3, DATEADD(yy, DATEDIFF(yy, 0, GetDate()) + 1, 0)) As ThisYearEnd
    
