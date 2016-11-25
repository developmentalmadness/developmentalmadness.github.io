---
layout: post
title: The Zen of Akka (Lambda Days 2016) Cliff Notes
date: '2016-04-22 19:45:25'
tags:
- akka
- cliff-notes
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/tC-joPMPJLs" frameborder="0" allowfullscreen></iframe>

Below are all the points, what time to find them in the video and what I found were the important talking points. I left most stuff actually on the slide out.

#1. One Actor Is No Actor

(about 3:17)

Semantically, a system with a single actor is not a concurrent system.

Use `ActorRef` over actor selection

#2. Structure Your Actors

(about 6:13)

Prefer `context.actorOf` over `system.actorOf`. This will create a parent/child relationship which allows for actor supervision. `system.actorOf` creates all new actors on the same 'level' instead of within a hierarchy. 

#3. Name Your Actors

(about 7:22)

Allows actor names to have meaning within the domain:

* Default naming: bad - no context when logging/debugging
* `[name]-[counter]`: better - but still lacks important meaning. Example: `fetch-worker-1`, `fetch-worker-2`
* `[name]-[contextual-id]`: best - combines meaningful name with the execution context. Example for actor which fetches videos from web sites: `fetch-yt-[youtube-identifier]`, `fetch-vm-[vimeo-identifier]`

**Note:** Don't use scala string interpolation for logging:

    //BAD - the string is always built/evaluated
    log.debug(s"Something heavy $generateId from $physicalAddress")

    //GOOD - string built only when DEBUG level is ON
    log.debug("Something heavy {} from {}", generateId, physicalAddress)

#4. Matrix Of Mutability (Pain)

(about 11:49)

(Lower number is better):

1. Immutable Val - great, but you can't do anything with it
2. Immutable Var - most of the time, you can mutate it but if it gets "leaked" (sent to another actor) it can't be modified (thread-safe).
3. Mutable Val - shouldn't do this. Not thread-safe.
4. Mutable Var - never do this

#5. Blocking Needs Careful Management

(about 14:25)

When you block - isolate it - use a non-defualt dispatcher on it's own thread pool. Aka "Bulkhead Pattern"

When configured in your config file like this:

    // application.conf
    
    my-blocking-dispatcher {
      type = Dispatcher
      executor = "thread-pool-executor"
      
      thread-pool-executor {
        //in akka previous to 2.4.2
        core-pool-size-min = 16
        core-pool-size-max = 16
        max-pool-size-min = 16
        max-pool-size-max = 16
    
        // or in Akka 2.4.2+
        fixed-pool-size = 16
      }
    
      throughput = 100
    }

Then you can do this:

    implicit val blockingDispatcher = system.dispatchers.lookup("my-blocking-dispatcher")

    val routes: Route = post {
      complete {
        Future {
          Thread.sleep(5000)
          System.currentTimeMillis().toString
        }
      }
    }

This is good because you're blocking only on a dedicated dispatcher instead of the default dispatcher.

#6. Never Await, for/FlatMap instead

(about 19:20)

Use Monadic composition of futures (`for` block) or `akka.pattern.after` with `Future.firstCompletedOf` (best)

#7. Avoid Java Serialization

(about 22:38)

Java serialization is the default because it made for easy "Hello World" default case for those learning. Problem is people don't change the defaults going into production and decide "Akka is slow".

Good suggestions are ProtoBuf or Kryo. Both have pros/cons. Kryo is easier to setup, but poor schema evolution. ProtoBuf requires more setup but better evolution. Other suggestions are SBE, Thrift, and JSON.

Even XML is smaller/faster than default Java serialization.

#7.5. Trust no-one, benchmark everything

(about 29:54)

[all info is on the slide]

#8. Let it Crash! Supervision, Failures, & Errors

(about 30:48)

Error - is expected and handled. Report to end user

Failure - an unexpected event. Report to supervisor

Ask who can do something about a problem?

#9. Backoff Supervision

(about 35:00)

Exponential Backoff

Persistent actor -> Datbase

If fail/restart is immediate you're basically DDOS your database/system

Instead use Backoff Supervisor, something outside the hierarchy and is provided by Akka if you configure it. 

#10. Design using State Machines

(about 38:27)

**Bad**: Long list of `case` matches for 15 or more messages in an actor's receive looks like "pyramid of doom" found in async programming frameworks like javascript.

**Good**: You may end up using the FSM (Finite State Machine) DSL to help you achieve this goal.

#11. Cluster Convergence and Joining

(about 40:25)

Cluster Gossip Convergence: Everybody knows something, then we make a decision on it.

`allow-weakly-up-members`: allow "up" (join) state before all nodes can see it. Allows nodes to join even when there is a network partition.

#12. Cluster Partitions and "Down"

(about 43:04)

Opposite of last point.

When a node gets marked as unreachable it gets marked as "down". When it comes back everyone refuses to talk to it. If you don't want this behavior you can turn it off, but then make sure you don't use features that follow "single writer principle" (eg. Akka Persistance). Instead use CRDT based like Akka Distributed Data.

#13. A fishing rod is a Tool. Akka is a Toolkit

(about 44:54)

Use the least powerful abstraction that gets the job for you. Sometimes a `Future` is enough but not distributed. `Actors` are distributed, but require more work - so it's a tradeoff.

#Q&A

(about 47:20)

Distributed Akka Streams? Try Intel GearPump:

 * https://www.lightbend.com/resources/case-studies-and-stories/intels-gearpump-real-time-streaming-engine-using-akka
 * https://software.intel.com/en-us/blogs/2015/08/14/all-about-gearpump-the-real-time-big-data-streaming-engine-behind-intel-s-latest
 
Backpressure using Backoff Supervisor strategy? No

