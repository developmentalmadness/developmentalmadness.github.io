---
layout: post
title: 'Entity Framework: How to Prevent Eager Loading'
date: '2009-02-24 23:09:00'
tags:
- entity_framwork
---

As we have been using Entity Framework on my current project I have found that it can be easy to kill eager loading on your queries. This can be a real problem if you are counting on it. I have been working on cross-cutting concerns up to this point, but because of my experience with Linq 2 SQL I was asked about some issues our team was having with eager loading. Namely, the Include() method, which is a method of the ObjectQuery type. If you’ve read any documentation on eager loading I’m sure you’ve read that using projections precludes the use of the Include method. That is you can use it, but it will be ignored (no errors), and you will be left scratching your head. I found we were doing two things which were killing eager loading, which I believe are tied to projections.

## Eager Loading

Before I mention the 3 issues I’ve seen to this point, I wanted to preface the list with a summary of how eager loading works.

In order to get the benefit of eager loading you need to, at minimum, define an association between your entities. This is done either in the designer or in your csdl (class structure element of your entity definition file (edmx). When you first create your model, you get this for free if you have defined foreign key constraints in your data model (RDBMS). If you have then the designer will automatically add navigation properties for each entity and an association between the two.

If you want Entity Framework to eager load related entities then you simply call the Include method of a ObjectQuery instance and pass in the name of the NavigationProperty for the association you want included:

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">using(AdventureWorksModel ctx = new AdventureWorksModel())</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none">{</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> var results = from p in ctx.Persons.Include("Addresses")</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> select p;</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> List<Person> customers = results.ToList();</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">}</pre>

Once you execute your query Entity Framework all the data, including the data for the association, will be loaded into a collection for you. When you reference the navigation property of an entity for the specified association you’ll find the data is there waiting for you. As long as the Navigation Property exists and you’ve typed the name correctly this will work.

## Eager Loading Anti-Patterns

So what can get in the way of eager loading? A couple things:

1. As I mentioned above, projections do not support eager loading. I believe this is at the root of the issue if you’re experiencing problems with eager loading. Why don’t projections allow for eager loading? For the simple reason that projections create anonymous types. If you aren’t projecting an anonymous type then it’s because the type you are projecting to isn’t in your entity model. Your entity model includes ssdl (storage definition) and mdl (mapping definition) which allows your entity to be mapped to a SQL query. Without these pieces you get nothing. If you need to do a projection of some sort, but you want to include eager loading then see [this article](http://www.thejoyofcode.com/Projection_blows_includes_in_Entity_Framework.aspx)
2. The first thing I ran into was casting to a subclass. With Entity Framework you can mark an entity as an abstract class and inherit from it. Then our LINQ query was casting the “select” clause to a subsclass like this:

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">var result = from ps in EntityModel.Persons.IncludeGraph("Addresses")</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> where ps is Customer</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> select ps as Customer;</pre>

I haven’t figured out yet what this is doing under the covers, but I’m guessing this is resulting in a projection, if not something very close to one. Here I am querying an EntitySet of type Person for a Customer type. While the Entity Framework supports inheritance like this, I can see how this would be treated like a projection because of the conversion required. Instead of doing this, I’ve found you can work around the issue by refraining from using the cast in the select statement. Instead cast the result of your query after it has been materialized.

3. Joining two tables in a query will kill eager loading. It would seem to me that the reason this breaks is because when you join like this it is unreliable. If you were to run this query against a one-to-one relationship you’d be fine. But in any other scenario this breaks down because unless you’re using the DISTINCT clause, things get sloppy.

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">var result = from ps in EntityModel.Persons.IncludeGraph("Addresses")</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> join a in EntityModel.Addresses on ps.PersonID equals a.PersonID</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> where ps is Customer && a.State == "CA"</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> select ps;</pre>

So Unless you need to create a projection with the results, in which case you can’t use eager loading anyway, then try and use subquerys (Any()).

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">var result = from ps in EntityModel.Persons.IncludeGraph("Addresses")</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> where ps is Customer && ps.Addresses.Any( a => a.State == "CA" )</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> select ps as Customer;</pre>

## Conclusion

So to recap, make sure you have defined navigation properties where you want to enable eager loading and that your arguments to the Include method are spelled the same as your navigation properties. Then avoid anything that Entity Framework would construe as an implicit (or explicit) projection. There may well be other reasons eager loading breaks down but this should be a start.