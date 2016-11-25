---
layout: post
title: 'Data Access: Stored Procedures vs. ORM (ad hoc) Queries'
date: '2009-06-23 20:48:00'
tags:
- sql_server_security
- orm
- sql_server_performance
- stored_procedures
- sql_server
---

I’ve had many spirited discussions over time with my colleagues on this issue. And I will most likely invite a flame war from the developer community for this post, but after reading [this post](http://mattias-jakobsson.net/Item/39/Why%20I%20would%20not%20use%20Stored%20Procedures)

As a disclaimer I don’t take issue with the decision to use /ad hoc SQL over . I use both in my applications and I have always maintained that this is a decision to made by you and your team (if applicable) after weighing the pros/cons against the requirements of your application. But I do take issue with those who [make blanket statements](http://weblogs.asp.net/fbouma/archive/2003/11/18/38178.aspx)

Not only have I used and tested a number of ORM components, but I have had the experience of writing my own to support a large, high-traffic application. I am no stranger to ORM.

## Manageability

Everybody talks about all the work involved in maintaining stored procedures. Heck, I worked on an application which contained almost 4,000 stored procedures so I agree it can get unwieldy. When we re-wrote the application we went ad hoc with an ORM component. But the ORM couldn’t meet the needs of all our queries so we hand crafted many queries, but now our SQL code was littered across the entire application. Plus, I had to constantly battle improper use of parameters which caused a bloated SQL procedure cache. I was constantly on my soap box pleading with my team to be explicit when declaring their SqlClient parameters.

So you can have an unmanageable mess even without the help of stored procedures. However, the argument that an ORM allows you to just regenerate and go can be applied to stored procedures as well. I have a project I’m working on where I do just that. My stored procedures are largely generated, so they are just as easy to update as an ORM component.

#### Troubleshooting

I have spent many hours analyzing [SQL Profiler](http://msdn.microsoft.com/en-us/library/ms181091.aspx)

## Performance

#### <font color="#333333">The Procedure Cache</font>

<font color="#333333">There are 3 types of plans in the procedure cache: SQL, Prepared and Compiled. Compiled plans have the highest priority and in the event SQL Server experiences memory pressure compiled plans are the most likely to stick around when the procedure cache gets flushed. (<font color="#333333">[http://technet.microsoft.com/en-us/library/cc293624.aspx](http://technet.microsoft.com/en-us/library/cc293624.aspx)</font>)</font>

<font color="#333333">Many think of the Procedure Cache as a memory issue, but the procedure cache is a huge CPU saver on your database. [Compiling a SQL query is a very expensive CPU operation](http://www.codeproject.com/KB/database/ParameterizingAdHocSQL.aspx)</font>

Additionally, many ORM implementations don’t properly implement parameters for variable-length data types (ex: VARCHAR, DECIMAL). LINQ to SQL is a prime example: [The length for string parameters is set to the size of the string](https://connect.microsoft.com/VisualStudio/feedback/ViewFeedback.aspx?FeedbackID=363290)

#### <font color="#333333">Many Databases == High Traffic Database</font>

<font color="#333333">If your web application is being hosted by some sort of hosting provider or if you work for a corporation with a multiple LOB applications your database is hosted on the same SQL server as any number of other databases all of which are competing for the same resources. The result is the same as running a single high traffic web application – your database server is dealing with high traffic.</font>

If you don’t control all the applications on the database server it is in your best interest to consider the use of stored procedures since your execution plans will be less likely to be flushed from cache than those of the other applications running on the same database instance.

#### <font color="#333333">RBAR</font>

<font color="#333333">“Keep business logic out of my database” is a good practice, but I also say, “keep database logic out of my business logic”. I’ve yet to meet an ORM framework which properly supports batch updates. I’m not talking about submitting a string of INSERT or UPDATE statements in the same batch, that’s still RBAR, just without the network latency (not to mention can’t be cached by the optimizer). I’m talking about using any number of features supported by SQL Server which, when used allow you to submit an entire data set (, , ) and allow the database to work with the data as a set. Anything else is [RBAR](http://www.simple-talk.com/sql/t-sql-programming/rbar--row-by-agonizing-row/)</font>

<font color="#333333">If anything is [evil](http://www.tonymarston.net/php-mysql/stored-procedures-are-evil.html)</font>

##### Caveat

Back in 2003 I was looking for a nice clean way to build a data access layer. I found by [Frans Bouma](http://weblogs.asp.net/fbouma/default.aspx)

## Security

In my opinion, this is an argument that is inaccurately made by both camps, with the ORM camp simply saying “create two roles and give one update permissions”. Yeah, that works fine until an account (or the account) with update permission gets compromised.

The security model for stored procedures is an example of security in-depth. Stored procedures provide an API on your database that can be secured for each operation. Yes you could do this as a service but you’re still running around with an account that has full CRUD access to your tables. And last I checked SQL Injection isn’t the only way to hack your database. As one example, a recent study claims there are about [a half-million database servers publicly exposed on the internet](http://www.computerworlduk.com/management/security/data-control/news/index.cfm?newsid=6198)

Here’s an example I’ve seen used to show how stored procedures don’t protect you from SQL injection attacks:

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px">strsql = "EXECUTE findtitle '" & textboxtitle.text & "'"</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px">objCmd = New SqlCommand(strSQL, objConn) </pre>

This is true, but only if your application has been granted access to perform operations other than EXECUTE. If you’re using stored procedures as a security measure, then the account won’t have access other than EXECUTE and you’re safe.

## Vendor Lock-in

How many applications have you really worked on that you’ve had to move between database vendors? Really? And if you have, how many other applications have you worked on that didn’t require it?

I don’t think stored procedures are the issue here. If you wanted to change database vendors and couldn’t was it really because of stored procedures? Or was it because your database layer wasn’t properly abstracted from the rest of your application? I worked on an application once with this issue and we were using an ORM, but we still couldn’t change. The reason was GUIDs, the target we wanted to move to didn’t support the UNIQUEIDENTIFIER data type. We had some UDFs and actually had a stored procedure or two, but these were supported and could have been migrated.

## Be Smart

Up to this point I have largely argued in favor of stored procedures. My reasoning is that among developers those who favor stored procedures are in the minority (the reverse is most likely true among DBAs). My preference is to use a hybrid of both. ORM/Ad hoc queries have very strong advantages over stored procedures, but the argument can be made both ways. This is why the debate gets so hot, because no one is 100% right. Here’s what I recommend:

**Generate your CUD as stored procedures** – Here I’m referring to CRUD, minus the “R”. I strongly believe that you should never directly update records in your table. I cannot be convinced that a two-role model where one role has write access to the table is sufficient. Your application is not the only attack vector on your database. Since it is true that maintaining stored procedures by hand after a schema change is a nightmare you should generate your stored procedures in this case. This is easy enough to do by writing a script that uses SQL Server metadata to build your procedures. If possible, provide a means to do batch updates in a single call, you’ll thank me.

**Use ORM/Ad hoc for SELECT** – if you want to use a stored procedure for “select by id” or “select all” you can it makes no difference really. But in my experience there are too many different ways to retrieve your data and you WILL have a maintenance nightmare on your hands if you try to write stored procedures for every case. Many who use stored procedures will do this in one of two ways (both are bad in my opinion):

* **<font color="#ff0000">Dynamic SQL</font>**: This is just plain wrong and evil IMHO. You open your stored procedures up to SQL injection attack vectors. This means you now have a false sense of security, just don’t do it. Also, it’s like building HTML strings in your code – difficult to maintain and hard to debug (plus it’s like nails on a chalkboard for me). A second argument against this method is that your stored procedure will be recompiled every time the different arguments are used, the more parameters you have the more often you will see the stored procedure recompiled.
* **<font color="#ff0000">COALESCE/ISNULL Functions</font>**: This protects you from SQL injection attacks, but you now opened up a performance problem. I usually see these used to along with default parameters to make a stored procedure flexible enough to search on any column, but it can disable the use of indexes. Avoid this practice if you can.

In the long run, using ORM for any trivial execution plan will save you time and headaches. As far as security goes, granting SELECT on the table is not a huge problem unless you have sensitive data. If you have data you don’t want to expose carte blanche then use a view.

**Use stored procedures for complex queries** – ORM tools are great, but it can be difficult to really optimize complex queries being generated by an ORM.

Some queries which would be otherwise simple are made complex by ORM tools which of necessity must accommodate any scenario. It will be easier to track down these problem children when using Profiler and you can also create solutions which don’t match your object model but will vastly outperform anything your ORM can generate.

And remember that your query will survive procedure cache flushes longer.

NOTE: I don’t mean to imply that you should do your performance tuning before you determine it’s needed. But you can encapsulate the query in your DAL and then as soon as you need it, replace your ad hoc query with a stored procedure – you’ll keep your hair.

**Avoid Lazy-Loading** - Lazy loading is just that: lazy. Lazy is synonymous with sloppy. This is one feature that is almost guaranteed to come back and bite you. The main reason is you will almost certainly end up in a loop and inside that loop you will need related data. You will say, “Hey, this is so cool! Look, ma! No Hands”. This is VERY BAD! Enough said. Dump your ORM and find one that supports eager loading and LINQ (LINQ is my own preference, it’s not required I just really like it).

**Use Repository/ActiveRecord** – use some sort of pattern to abstract your database from your business logic. This gives you the freedom to mix and match and go back and forth between either stored procedures or ORM/Ad hoc without affecting your application. You’ll be able to choose the best solution for each situation and you’re not tied to either choice.

## Conclusion

Don’t be a lemming. Give it some thought, weigh the pros and cons and then pick what’s right for the application you’re working on. Whatever your preference is try to be objective enough to step back and think about what will meet the needs of your application. If you ever hear some zealot/disciple screaming about how they’ll never use one or the other just smile and nod. Then when they’re not looking deck ‘em and run :).