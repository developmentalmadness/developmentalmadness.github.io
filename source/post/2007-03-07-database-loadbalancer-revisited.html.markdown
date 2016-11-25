---
layout: post
title: Database Loadbalancer Revisited
date: '2007-03-07 20:22:00'
tags:
- sql_server
- sql_performance
---

The load balancer I wrote last year never made it into full production. While it was still in Q&A we hit our deadline and we stopped new development as we hit our "busy season". At MaxPreps, once the fall season starts and football is in full swing our architechture gets locked in and we don't make changes to it unless it's to fix problems we missed. So the load balancer went by the wayside. But now it's the time of year where we start preparing for the next year and so it's time to dust of the load balancer and pick up where we left off.

It worked pretty well and we almost had all the bugs worked out of it, but since last summer I've given it some thought and realized it had a few inherient flaws that needed tweaking. Here's some of the problems I've come up with:

1. The web server client would only use the current "optimum" connection So this meant that if all the web servers got the same server state during the same polling interval the server with the lowest CPU would get hammered by all the web servers at once.
* All polling was done on an interval by a series of worker threads. So if the threads didn't complete within the configured polling interval then the polling would start over with a new set of treads while the first series was still running. This would introduce race conditions if the number of servers being monitored caused polling to take longer than the configured interval.
* The client is responsible for retrieving the server state data. This means the more clients using the load balancer the greater load on the network just to determine the available servers.
* The performance counter data being collected (currently CPU is the only counter) isn't aggregated. This means that if a server is really busy but it happens to "take a breath" at the point the counter is checked it will give a false reading about how busy it is. The opposite is also true; if the server happens to have a spike when the counter is checked it will be underutilized.

Here's what I've come up with to deal with each of these issues:

1. Instead of using only the "optimum" connection the web server will not contain any decision logic. The load balancer will use a set of criteria to determine which connections are available and acceptable. Then the load balancer will send only "available" servers in the list. The client (web server) will then simply use a round-robin (mod) to choose which server will be used for the current connection.
* I'll have to do a bit of testing to determine which option will be best but I've got a couple ideas to solve this one. A) I could make the polling interval tied to each thread so the doesn't start again until the thread has completed in the first place or B) I could use a reset event to indicate when all threads have completed and signal the start of a new wait interval.
* The load balancer will use multi-casting to broadcast the server state on an interval. This means no matter how many clients are using the load balancer the amount of network traffic will remain the same.
* I will maintain the results for each polling interval within a configured interval. Once the interval is full new results will roll over and overwrite old ones that have "expired". The list of results will be used to calculate the aggregate.
* If I come up with any other problems/solutions I think of I'll post them here. Or if anyone else sees any problems they can post comments here or on the page where my article is located on codeproject: http://www.codeproject.com/useritems/dbloadbalancerservice.asp