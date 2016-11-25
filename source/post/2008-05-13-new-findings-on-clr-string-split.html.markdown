---
layout: post
title: New findings on CLR string split performance
date: '2008-05-13 18:32:00'
---

Today I was envolved in a discussion thread which revolved around the SQL CLR. Naturally I jumped in in defense of the CLR based on my own experience. But one of the other participants pointed me to a blog post by Paul Nielsen about lessons learned while building a system with a SLA of 35k tps (transactions per second).

According to Paul, due to the marshalling requirements of the CLR the string split method eventually becomes much slower than the regular T-SQL solution. Apparenly, it doesn't hold up under a large number of concurrent transactions.

Before I go all chicken little and dump the CLR, splitting strings is not the only use for it in SQL Server. So don't throw the baby out with the bath water. But what this tells me is how important it is to do proper testing under realistic conditions.

http://sqlblog.com/blogs/paul_nielsen/archive/2007/12/12/10-lessons-from-35k-tps.aspx

On a side note, another user pointed out a more efficient method for doing T-SQL splits - the tally table. Here's a link to a very good article on that topic. A must read: http://www.sqlservercentral.com/articles/TSQL/62867/