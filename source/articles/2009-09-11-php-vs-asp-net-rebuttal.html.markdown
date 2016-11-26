---
layout: post
title: PHP vs ASP.NET Rebuttal
date: '2009-09-11 11:44:00'
tags:
- asp_net
- php
---

I should just ignore people sometimes, but today I couldn't help it. I read this post which claims to compare PHP to ASP.NET. I don't really care if someone likes one more than the other, but really this post didn't back up any claims and was full of false statements. I may get a few things wrong here as well, but I want to just set the record straight.

(Disclaimer: I am an ASP.NET developer). This article is obviously biased and provides no support for its claims:

####1. PHP is an Open Source Language

 This is true. ASP.NET is proprietary. Wither this is a pro or a con is a matter of opinion and for you to decide. I am ambivalent on this point. But I will add that last year the ASP.NET MVC Framework was released and with it comes the license to fork it and modify it to your hearts content. That is if it isn't already flexible enough for you. Yes, MVC is built on a proprietary framework, but there is already an open source project which extends and replaces much of the default functionality.

####2. PHP is Free

 All the operations mentioned (Binary file, FTP/HTTP communication, encrypt passwords using MD5, send email) can all be done either natively from the .NET Framework, free open source alternatives are available or you can extend the framework to do it yourself. There is a broad community around .NET where you can find out how in either blogs or forums.

####3. PHP is Flexible

 ASP.NET can connect to all the database platforms mentioned. The choice of which is up to you - there is no requirement to use MS-SQL and many hosting providers allow you to chose between MS-SQL and MySQL. And about the performance degrade - prove it.

####4. PHP is Portable

 MONO exists as a port of .NET, including ASP.NET I remember reading about possible performance issues due to garbage collection and that it was in the process of being address. But I haven't used it so I can't really argue this point. However, I'm guessing the author hasn't verified this either.

####5. PHP has very familiar and well known Syntax

 This point makes it painfully obvious the author has never used ASP.NET. He mentions the similarities in syntax between PHP and C++ as an advantage over ASP.NET. He then implies that this makes it easy to learn. Guess what C# is also similar to C++. Plus, ASP.NET doesn't force you use C#. You can also use VB.NET, IronPython, Delphi and other languages for ASP.NET - so you can choose the language and syntax that suits you best.

####6. PHP has less Code Complexity

 This is a rehash of #5, but at least acknowledges the existence of VB.NET and C#. --I'll acknowledge the point that to create a new ASP.NET site vs a new PHP site you can fire up a text editor dump some code into a single file and you'll be off and running. An ASP.NET site on the other hand requires a complex web.config file, global.asax, code-behind files for each .aspx page (optional) and a bin directory for compiled code. So for your basic small site or "hello world" example PHP is simpler.-- I'll admit to never using PHP, but I started with classic ASP and they are similar enough for me to know that once you start building a larger site the complexity increases exponentially. Include files (a primary means of code-reuse for interpreted web languages), debugging and the lack of compile-time checks greatly hampers developing when using an interpreted script language (which is the case for PHP).

 **CORRECTION**: Thanks to Jason Bunting for pointing out that I was wrong - an ASP.NET site requires nothing more than a single .aspx file. I guess I rely a little too much on the Visual Studio IDE sometimes. So again, PHP does not win on simplicity here either. I'll leave in the incorrect info above along with this correction.

####7. PHP is Fast

 I'd like to ask the author again, back it up. While I don't normally put much stock in benchmarks, for the sake of this discussion I will at least provide 2 examples I quickly found online (that weren't done by M$).

 [Nile benchmark by PCMag](http://www.pcmag.com/article2/0,2817,1172043,00.asp)

 [Wrensoft benchmark](http://www.wrensoft.com/zoom/benchmarks.html)

 Benchmarks often depend on what you're doing, but I'll go out on a limb and say that most often compiled code beats interpreted script hands down. I've heard of 3rd party commercial products (something the author is apparently against) which will pre-compile PHP code so this could be something that helps PHP, but I'll venture a guess that these run as native code once compiled instead of from the PHP interpreter.

####8. Free Webhosting

 The author is correct. I don't know of any free ASP.NET hosting providers. But remember the adage, "You get what you pay for". I'm all for free, but when it comes to web hosting, I wouldn't ever bank on a free provider for anything other than my personal family web site. Free hosting for an e-commerce app? Not on your life.

####9. PHP has Free Tools and Libraries

 Ever heard of Visual Studio Express Editions? They are free and I'd have to say I've never used an IDE better than Visual Studio - even the express editions. That's my personal opinion and you may not like Visual Studio, but there is still a free edition that includes debugging with edit-and-continue support as well as refactoring. And there are plenty of open source libraries written for .NET - try CodePlex.com over 10,000 open source projects on that site alone.

####10. Code Compaction

 First of all this is a ridiculous argument. It really depends on what you're doing. There are things that can be done very tersely in both languages and obviously he's never written a line of C#. But if something isn't terse enough for you, you can write your own code that will (if someone hasn't already done it for you on the internet) and reuse it anywhere you like. This is all PHP is, a library of objects and functions, in .NET you can write anything that doesn't already exist. As for the author's specific example, the model binding in ASP.NET MVC Framework allows for simple and very complex binding of GET and POST variables from scalar values to collections of complex objects - all strongly typed for you - no need for the ASP Request object.

####11. PHP is Light Weighted Language

 Again, for small projects absolutely he's right because of the basic files required for an ASP.NET project I mentioned above. But take two large and complex sites and it really depends on what you're doing and how you're doing it. You can write bloated code in any language - I guarantee it.

####12. Security

 I won't argue the comparison of Apache and IIS. I'll concede this, but I bet there's a lot of insecure PHP applications out there which are just as vulnerable to SQL Injection and XSS as any ASP.NET application. But if you ignore the web server (I know I'm asking a lot here - seriously) by default, there are more protections in ASP.NET than PHP. As an example, if you just lazily dump together an ASP.NET application and one in PHP, ASP.NET request validation forces you explicitly allow HTML tags in POST variables before it will let them be submitted my a user.

####13. Architecture

 You've got to be kidding me! This guy really has never been anywhere near ASP.NET. He's claiming that the parsing engine runs in a different process space than the ASP.NET Engine!?! First of all, as of IIS 7.0 ASP.NET no longer runs in a separate process space from IIS - it's integrated. But even if you were running in classic mode or a version of IIS previous to 7.0, IIS passes off a request to the ASP.NET engine which then handles the entire job in its own process and then sends the raw response back to IIS to be streamed (no parsing or anything required) back to the client.

####14. PHP/MYSQL combination is more efficient that ASP.NET/SQLSERVER combination

 See my link to the PCMag benchmark above, nuff said.

####15. PHP Website can be hosted on any Sever very efficiently

 It does cost more to host an ASP.NET application, true story. And w/o Mono you can't host it anywhere but Windows. But if you want to take your application elsewhere for better service and uptime - you're free to do it and with no more pain than any other platform. But yes, add the requirement for Linux and well that just doesn't fly as well.

####16. PHP is easy to learn

 Did the author have some kind of quota to fill? See #5 and #6. Oh and again, VB isn't the only language you can use to write ASP.NET. It isn't even the most widely used - C# is use by far more ASP.NET developers than VB.NET - I can count the latter that I know personally on one hand.

####17. PHP is easily debuggable [sic]

 Are we talking about debugging PHP itself or your web application written in PHP? If we are talking about the former, then yes don't count on getting a fix when there's a problem anytime soon unless you're a paying customer. But the entire source code for the .NET Framework is available for debugging purposes and BTW the Visual Studio debugger is one of the most advanced there is. So if we're talking about the latter, don't even bother because not only is VS equipped with deep debugging support, but the next version even has more advanced support for multi-threaded debugging than before.

 Which brings up a side point - what kind of support does PHP have for multi-threading, something very important to applications which require intensive calculations? Also ASP.NET provides support for asynchronous requests, something entirely different than multi-threaded operations. To improve scalability, you can free up threads on blocking operations (File I/O, network and database calls, etc) by using asynchronous calls. This allows your current thread to be used elsewhere until your blocking call returns - a big plus when you're in need of a lot of throughput for a high traffic web site.

####18. Database Support

 Here we are with the quota-filling again. ASP.NET can connect to every database that PHP can.

####19. PHP has so many free built-in functionalities

 Deja vu! See #2 - all this stuff is available, natively, from open source or you can roll your own if you don't like what's available.

####20. PHP is Popular

 I don't know which has more (because the author didn't bother to back up his statement with any recent surveys), but I do know that I have unlimited resources on ASP.NET for which I never have to look far to find answers I need. There are plenty of jobs as well. And in my purely anecdotal experience the jobs I see pay better for ASP.NET.

####21. PHP is easily available

Rudux of #20! This guy was really trying to stretch to meet his quota.

####Conclusion

I resubmit that the author made no real comparison between PHP and ASP.NET. I have not attempted to either, because I freely admit I do not have the experience with PHP to make a fair comparison. I have rarely seen such a biased, unsupported post. I am fine if others like PHP better than ASP.NET but at least get your facts straight. If you want to know the advantages of PHP talk to someone who knows it, same goes for ASP.NET but don't fall for lazy stuff like this.
