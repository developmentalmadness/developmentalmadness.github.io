---
layout: post
title: Streaming Http Response Data With Play WS Iteratee
published: false
---

https://gist.github.com/developmentalmadness/917972ac97cd874625524ba89c941751

I've been working on a feature that allows a user to submit an arbitrary HTTP request to a remote endpoint. I was worried about a request which could return a large payload and I wanted to be able to set a limit on the amount of data we would buffer to avoid destabilizing the current node.

    // see: http://mandubian.com/2012/08/27/understanding-play2-iteratees-for-normal-humans/
    // see: https://www.playframework.com/documentation/2.4.x/Iteratees
 

    // see: http://doc.akka.io/docs/akka/current/scala/dispatchers.html#More_dispatcher_configuration_examples
    // see: http://letitcrash.com/post/40755146949/tuning-dispatchers-in-akka-applications
