---
layout: post
title: 'MVVM: Going it alone'
date: '2010-03-17 14:21:00'
tags:
- silverlight
- mvvm
- caliburn
- mix10
---

If you want to implement MVVM for your next/current project, but you can’t seem to find a framework that works for you then give a look at [Rob Eisenberg’s](http://devlicio.us/blogs/rob_eisenberg/default.aspx) presentation from MIX10, [Build Your Own MVVM Framework](http://live.visitmix.com/MIX10/Sessions/EX15?wa=wsignin1.0). Here’s the synopsis:

> You've heard a lot about Model-View-ViewModel (MVVM), but you've struggled to see how it can help you in your day-to-day work. Or, you're experienced at implementing MVVM, but looking for some ways to maximize your investment in this methodology. In this talk, we build a simple MVVM framework by iteratively identifying pain points in our UI development and eliminating them with simple solutions. You'll walk away with code, but more importantly with an understanding of how to apply some simple ideas to improve productivity with MVVM in your own projects.

Rob is the developer for the [Caliburn](http://caliburnproject.org/) framework, another MVVM framework in addition to [Prism](http://www.codeplex.com/CompositeWPF) and others you may have heard of. The source code for his talk can be found here. According to Rob, the framework is inspired by/based on Caliburn. I have not looked at Caliburn much, but it has been on my list of projects to watch for quite sometime. I have been meaning to dig into it much as I have Prism, but I just haven’t had the time. I might give it a look once I am done with my next and final post on Prism (EventAggregator).

One nice tidbit from Rob’s talk was that he has successfully prototyped and is planning on adding to Caliburn in the following months is support for Blend. I am really interested in seeing how he does this. If you have been following my posts on prism then you will remember my discussion of ServiceLocator. ServiceLocator is the way I support design-time binding in Blend. Rob mentioned in his presentation that he doesn’t like view-first composition, which is what ServiceLocator is. View-first is when, given a view, the view (or some mechanism attached to it) goes and discovers the view-model.

I also really liked how Rob demonstrated using [convention over configuration](http://en.wikipedia.org/wiki/Convention_over_configuration) to remove bindings for commands, properties and converters from the view. He favors reflection quite a bit in his framework (I’m assuming this is also true of Caliburn), but if that makes you squeamish don’t fret. In the Q&A at the end he addresses it, the framework he demonstrates allows you to override the convention based approach when you need (for performance) or you can also easily add caching so reflection is never used twice for the same binding. My take on it is that in 99% of the cases reflection is fine. This is being done on the client, by the client, so you’re not doing it on a large scale. So unless your view is rendering tons of bindings (and I mean a lot) the I don’t think reflection is going to cause performance problems.

Anyway, his approach really seemed to clean up both the view and the view-model a lot. Another example of this is his use of [co-routines](http://en.wikipedia.org/wiki/Coroutine) so that you can support the asynchronous programming model, but you can write your code in a synchronous way.

Here’s some helpful links:

* [Rob’s talk at MIX10](http://live.visitmix.com/MIX10/Sessions/EX15?wa=wsignin1.0)
* [Source code for Rob’s talk](http://devlicio.us/blogs/rob_eisenberg/archive/2010/03/16/build-your-own-mvvm-framework-is-online.aspx)
* [Caliburn Project homepage](http://caliburnproject.org/)
* [Caliburn Project on CodePlex](http://caliburn.codeplex.com/)