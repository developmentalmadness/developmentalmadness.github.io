---
layout: post
title: 'Play2: Debugging With IntelliJ Community Edition'
date: '2016-05-03 22:21:08'
tags:
- play2
- intellij
---

##Configure build.sbt

Comment out or remove 

    fork in run := true

##Configure IntelliJ

Create a remote debug configuration:

    Run > Edit Configurations > Add New Configuration > Remote

Set `Host` to `localhost` and `Port` to `9999`, name your configuration. I called mine "Debug Activator" then click "Apply", the "OK".

##Run Activator

From the command line:

    $ activator -jvm-debug 9999

Once that starts go back to IntelliJ and start your debug configuration. Then return to the command line prompt and execute:

    $ run

You don't have to do the command line in two steps. That's just if you want to debug the application startup. Otherwise this will work just fine:

    $ activator run -jvm-debug 9999

Then just set a breakpoint and make a request.