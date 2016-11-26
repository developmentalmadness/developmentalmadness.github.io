---
layout: post
title: 'Lost In Translation - Episode 1: Database Instances'
date: '2009-01-29 16:04:00'
tags:
- lost_in_translation
- oracle
- database_instance
- sql_server
---

I have been using SQL Server for about 8 years now. When compared to my peers (read: coworkers) I would classify myself as a SQL Server guru. When compared to many I meet on sites like [SQLServerCentral.com](http://www.sqlservercentral.com) where there seem to be those I would classify as SQL Server gods I feel small. When working for [MaxPreps.com](http://www.maxpreps.com) I was forced to sink or swim and had to learn in depth details about things like replication, mirroring, partitioning and the intricacy of the proceedure cache, execution plans and the query optimizer. So I have had the opportunity to really learn a lot of things most developers don't even want to understand about database engine internals. 

Now for the first time I am working for a client who uses Oracle and I have to admit I feel a bit helpless. The terminology is all different and it messes with my mind. Where in the past I've been confident, I feel lost. So as I take the opportunity to understand Oracle I hope to document the "translation" from SQL Server to Oracle. In large part this effort is for my own benefit, but I hope this will also benefit others who feel as overwhelmed as I do. 

In the spirit of a disclaimer, I understand that not everything will have a translation. But RDBMS is RDBMS and I believe (read: hope?) there will be much overlap between the two systems and this transition between the two will be like learning a new language. When I learned French in junior high and high school I learned that there are different ways of expressing things and not everything has a direct translation (ex. idiomatic expressions) and there are gotchas (ex. false friends) . But there is still a way of conveying the same ideas. My analogy may not work entirely in the world of RDBMS, but I will hold to it as my general hypothesis.  

#Database Instances

The first translation I will attempt is that of Database Instance. This tripped me up and has been my first barrier to adoption. The reason for this is that is seems to be a bit of a "false friend". In language, a false friend is a word in another language that sounds similar a word in your own language, but isn't. For example, in French the word "blesser" sounds like "bless" in English. However, it means "to hurt". 

So to compare database systems, in SQL Server a database instance, is a file or grouping of files (aka. filegroup) which represent data which is locially stored together. But in Oracle a database instance is the collection of services which comprise the Oracle database system on the host machine. Which makes the Oracle database instance analogous to a SQL Server instance. Oracle doesn't have a default instance (at least not that I know of) like SQL Server, all instances are named. 

The mistake I made here was when I wanted to setup a database for a sample application. I opened up the Database Configuration Assistant (aka DBCA) to create a new database and installed a new instance. As I did this I found it strange that I was setting up duplicate accounts with different passwords for the "sys" account and other similar accounts. But what really tipped me off was when I finished the installation and my machine crawled to a painfully slow pace. When task manager finally opened up I noticed two instances of the "oracle.exe" process running alongside two instances of "java.exe". 

When I opened up the services mmc snap in (Start - Run... - "services.msc" - Ok), I saw that there were a set of services running for each "instance" I had setup. Stopping the services of the second instance brought my laptop back to a normal level of performance. 

#Conclusion

So my next step will be to uninstall my second instance. As long as that goes smoothly, my next episode will address the translation for a SQL Server database. I think I know what that is, but until I'm sure I'll refrain from stating it so I can avoid having to make too many edits in this post after I get corrections from those who actually know Oracle.