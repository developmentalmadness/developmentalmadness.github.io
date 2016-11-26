---
layout: post
title: 'Prism for Silverlight 2: Taking ‘Hello World’ to a Whole New Level'
date: '2009-06-08 18:09:00'
tags:
- silverlight
- design_patterns
- wpf
- prism
- wcf
---

## The World’s Most Over-engineered “Hello World” Demo

[Download Source](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/HelloWorld.Silverlight.zip)

I wanted to build a demo/guidance application for [Silverlight](http://www.silverlight.net/)

* [WCF](http://msdn.microsoft.com/en-us/netframework/aa663324.aspx)
* Design-time data binding
* Independent, decoupled modules
* Commanding support

I chose to use the (aka Prism 2) since it came out of the box with commanding support and a framework for pluggable modules. Prism 2 was developed by Microsoft’s [Patterns and Practices](http://msdn.microsoft.com/en-us/practices/default.aspx)

I’ve posted a copy of my solution for anyone who’s interested in looking it over and maybe a more simple example than the Reference Implementation (RI) provided by the PnP team. The biggest part of this exercise for me was the integration of WCF with Prism. The RI provided with the Prism documentation uses a local XML file as a data source. For me this was disappointing. I had been hoping for a more complete RI since Silverlight really isn’t worth anything as a [LOB](http://en.wikipedia.org/wiki/Line_of_business)

Now that I’ve finished, I’d like to share both my [sample](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/HelloWorld.Silverlight.zip)

#### What This Post Is Not

This post is not a detailed document on Silverlight, WCF, Prism or DI/IoC. These are all used and are relevant to the discussion, but in the interest of time these are all beyond the scope of this post. I have tried to provide helpful links to information along the way, but for more information on related technologies beyond the scope of this post consult the links I have provided as well as google.

## Solution Structure

I tried to model the solution structure to mirror what would be realistic of an enterprise-level application. I wanted minimal project dependencies and a modular design. Here’s a description of the structure and why.

#### Modules

Implicit in my goals was that I did not want my modules referencing each other. So I created a Silverlight Class Library project which contains my interfaces, base and utility classes named HelloWorld.Interfaces. This is the only project referenced by the other class library projects.

#### Silverlight Project

The only project which references the modules is the Silverlight Application Project named HelloWorld.Silverlight. At this point I am not dynamically loading assemblies since I don’t actually need it yet. I may add it down the road, but for now my needs are met.

#### Client/Server Shared Files

Also, I wanted to be able to use the same code base on the server as well as the client. I didn’t want to have to copy/paste code for interfaces and my data model between layers. So for objects and interfaces which are used by both the client and the server I created the class files in the server projects (Windows Class Library and [ASP.NET](http://www.asp.net/)

## WCF Communication

#### Server

There really isn’t much to say about the service itself. For my purposes the interface is the important part:

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using System;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using System.ServiceModel;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using HelloWorld.Model;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">namespace HelloWorld.Interfaces</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">{</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> [ServiceContract(Namespace = "http://helloworld.org/messaging")]</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public interface IMessageService</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> [OperationContract]</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Message UpdateMessage(string message);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> [OperationContract]</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Message GetMessage();</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <summary></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// Async pattern implementation for IMessageService</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </summary></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// Found this idea here: http://ayende.com/Blog/archive/2008/03/29/WCF-Async-without-proxies.aspx</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// Because I declared Namespace on IMessageService both Name and Namespace were required for this to work,</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// if I don't use Namespace on the Sync version I can leave it off the Async version.</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> [ServiceContract(Name = "IMessageService", Namespace = "http://helloworld.org/messaging")]</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> public interface IMessageServiceAsync</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> [OperationContract(AsyncPattern = true)]</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> IAsyncResult BeginUpdateMessage(string message, AsyncCallback callback, object asyncState);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Message EndUpdateMessage(IAsyncResult result);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> [OperationContract(AsyncPattern = true)]</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> IAsyncResult BeginGetMessage(AsyncCallback callback, object asyncState);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Message EndGetMessage(IAsyncResult result);</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">}</pre>

By defining a second interface to represent the service contract as an asynchronous pattern the client can bind directly to the asynchronous interface without having to define a wrapper class on the client side.

#### Client

For me this was the biggest part of this exercise. Originally, I used the “Add Service Reference…” wizard to add a reference to my service. However, this had several shortcomings I wasn’t happy about which all boiled down to one deal-breaker for me: any module using the interface would require a reference to my services project.

1) I couldn’t control the namespace used. Yes, it asks me for the namespace, but that is appended to the default namespace of the project where the service client is added. I’d rather have complete control over the namespace.

2) The wizard will reuse the model classes in my other projects if I ask it to, this is a plus. However, it won’t reuse my interfaces. The reason this is a problem is that I am tied to the client that is generated, so can’t just reference my interfaces project I have to either place my service client in my interfaces project or reference the service project from each other project.

3) The asynchronous event model used is simple and easy to use, but it’s tied to concrete [EventArgs](http://msdn.microsoft.com/en-us/library/system.eventargs.aspx)

I understand the constraints behind the output from creating a service reference, but there was just so much maintenance work involved in using it in a loosely-coupled way that once I found an alternative that I dumped the service client implementation.

So I was grateful to find this by . All that is required is that I create a link to the interfaces defined in my Windows Class Library project (Silverlight requires this, [WPF](http://en.wikipedia.org/wiki/Windows_Presentation_Foundation)

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">IMessageServiceAsync service = new ChannelFactory<IMessageServiceAsync>("BasicHttpBinding_IMessageEndPoint").CreateChannel();</pre>

Nice, clean and no maintenance. I don’t even have to regenerate the proxy when the interface changes.

However, there is a tradeoff.

## Dispatcher

The nice thing you don’t have to worry about when using the service client proxy is threading. I haven’t figured out why yet, but something to do with the way the events are handled by the generated proxy means you can just register for the XXXCompleted event then call the XXXAsync method and directly update your UI from the XXXCompleted event handler. This is called the Asynchronous Event Model. However, using ChannelFactory<T> means you’re not using events, you’re using callbacks – what I’ll call the Standard Asynchronous Model (aka BeginXXX and EndXXX).

This is where Dispatcher comes in. is a class located in System.Windows.Threading. Without getting into details, Xaml based apps (Silverlight and WPF) are single-threaded. But Silverlight requires you to execute blocking calls asynchronously. So when your asynchronous method completes you’re on a different thread. Dispatcher allows you to execute a or [System.Action](http://msdn.microsoft.com/en-us/library/system.action.aspx)

Like I said, if you’re using the service reference proxy this is handled for you. Otherwise you need to do this on your own. So here’s what I’ve done:

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using System;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">namespace HelloWorld.Interfaces</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px">{</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <summary></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// Abstraction for System.Windows.Threading.Dispatcher</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </summary></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// <remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// I got this from a thread on Stackoverflow.com. This allows me to perform testing w/o the</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// Silverlight testing framework. The benefit is that it completely decouples the code from the UI.</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// http://stackoverflow.com/questions/486758/is-wpf-dispatcher-the-solution-of-multi-threading-problems</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// </remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public interface IDispatcher</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> void BeginInvoke(Action action);</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background- margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> void BeginInvoke(Delegate method, params object[] args);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">}</pre>

This is so I can create an adapter for Dispatcher to be used when the application is running, then I can also write tests using a MockDispatcher which means my tests can then execute on a single thread because my MockDispatcher would be single threaded. This wasn’t my idea, I was just able to find it thanks to [StackOverflow.com](http://stackoverflow.com/questions/486758/is-wpf-dispatcher-the-solution-of-multi-threading-problems)

Here’s my implementation of IDispatcher:

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using System;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using System.Windows;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">namespace HelloWorld.Interfaces</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">{</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <summary></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// A wrapper for System.Windows.Threading.Dispatcher</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </summary></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// This version requires a Dispatcher to exist, which</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// means this class is tied to the UI. For testing,</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// create a Mock IDispatcher which will invoke the</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// action or delegate on the same thread since there</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// is no worring about the UI.</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public class DispatcherFacade : IDispatcher</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public DispatcherFacade(bool isHtmlEnabled)</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /* this value needs to be passed in when it is initialized </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> * because for some reason calling HtmlPage.IsEnabled always </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> * returns false in this class. I'll need to look into the</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> * source code of HtmlPage.IsEnabled to find out why this </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> * happens</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> */ </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> isEnabled = isHtmlEnabled;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> #region IDispatcher Members</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> private bool isEnabled = false;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public void BeginInvoke(Action action)</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> if (isEnabled == false)</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> action.Invoke();</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> return;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Deployment.Current.Dispatcher.BeginInvoke(action);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public void BeginInvoke(Delegate method, params object[] args)</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> if (isEnabled == false)</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> method.DynamicInvoke(args);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> return;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Deployment.Current.Dispatcher.BeginInvoke(method, args);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> #endregion</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">}</pre>

Now that w'e’re looking at this, you may notice something a bit hackish. You’ll notice that my ctor has a Boolean parameter named isHtmlEnabled. And you’re asking why doesn’t this guy just reference System.Windows.Browser.HtmlPage.IsEnabled? Well, origionally I did. But inside this class (project?) the value returned was always False. Since my dispatcher is being used as a Singleton I just get the value of HtmlPage.IsEnabled during the StartUp event of App and pass it into my Dispatcher. Since this was easy to do and doesn’t cause me any problems I’m fine with this. If you actually know why this happens and have a suggestion, please let me know. But I about this on [Silverlight.net forums](http://silverlight.net/forums/)

Now, when the app is actually running I can safely update the UI thread. When the app isn’t running (Test run or Design mode) I can directly execute the passed in Action or Delegate. Here’s how to use it:

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">private void GetMessageComplete(IAsyncResult result)</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">{</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> // get result</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Message output = _service.EndGetMessage(result);</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> // need dispatcher to execute on UI thread</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> // update Message on UI thread</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> _dispatcher.BeginInvoke(() => UpdateUIThread(output));</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">}</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">public void UpdateUIThread(Message message)</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">{</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> this.Message = message;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">}</pre>

## Design-time Data Binding

This was an important issue for me for a couple of reasons:

* I suck at UI design and can use every bit of help I can get
* I’m working with a [Flash](http://en.wikipedia.org/wiki/Adobe_Flash)
* I want to know my bindings work without having to compile and load up the web browser.

I originally saw demonstrate this last summer in a . He created a ServiceLocator which used to load up a mock service provider during design time. By adding the ServiceLocator as a static global resource to App.xaml the Silverlight designer initializes ServiceLocator and then displays the data in your preview window (NOTE: this doesn’t work in the VS 2008 preview window just in [Blend](http://en.wikipedia.org/wiki/Microsoft_Expression_Blend)

ServiceLocator.cs:

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using System.Windows.Browser;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using HelloWorld.Interfaces;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using HelloWorld.Interfaces.Views;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using HelloWorld.Module.Views;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using HelloWorld.Services;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">using Microsoft.Practices.Unity;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;">namespace HelloWorld.Module</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px">{</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <summary></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// Provides access to ViewModels</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </summary></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// <remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// The purpose of this class is to enhance the design-time experience</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// by providing a default instance of UnityContainer with Mock </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// services which can function at design time to provide the </pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// data required by the view</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// </pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// This class exists exists in the scope of the module to avoid</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// conflicts (if any) between modules and their IUnityContainer instances.</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// </remarks></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <example></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// From view:</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// &lt;UserControl</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// x:Class="...."</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// xmlns="...."</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// xmlns:x="..."</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// DataContext="{Binding Path=HelloWorldViewModel, Source={StaticResource resourceLocator}}"</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// &gt;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// &lt;UserControl.Resources&gt;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// &lt;local:ServiceLocator x:Key="resourceLocator" /&gt;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// &lt;/UserControl.Resources&gt;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// &lt/UserControl&gt;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// </example></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public class ServiceLocator</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> private static IUnityContainer BuildDesignTimeContainer()</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> IUnityContainer container = new UnityContainer();</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> // if we're live (aka not in the designer/Blend) the Bootstrapper </pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> // will setup the container</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> if (HtmlPage.IsEnabled)</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> return container;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> // register required objects </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> container.RegisterInstance<IDispatcher>(new DispatcherFacade(false));</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> container.RegisterType<IHelloWorldPresenter, HelloWorldPresenter>();</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> // register mock services so they can be used in Design Mode</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> container.RegisterType<IMessageServiceAsync, MockMessageService>();</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> return container;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> }</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> private static IUnityContainer _container;</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public static IUnityContainer Container</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> get</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> if (_container == null)</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> // setup container</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> _container = BuildDesignTimeContainer();</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> return _container;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> set</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> _container = value;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// <summary></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// Public property for the ViewModel which</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> /// can be referenced by the View as a Resource</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> /// </summary></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0pxfont-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> public IHelloWorldPresenter HelloWorldViewModel</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> get</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> return Container.Resolve<IHelloWorldPresenter>();</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> }</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> }</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> }</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px">}</pre>

HelloWorldView.xaml:

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><UserControl x:Class="HelloWorld.Module.Views.HelloWorldView"</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> xmlns:cmd="clr-namespace:Microsoft.Practices.Composite.Presentation.Commands;assembly=Microsoft.Practices.Composite.Presentation"</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> xmlns:local="clr-namespace:HelloWorld.Module"</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> DataContext="{Binding Path=HelloWorldViewModel, Source={StaticResource serviceLocator}}"</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> xmlns:d="http://schemas.microsoft.com/expression/blend/2008" </pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> mc:Ignorable="d" </pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> d:DesignWidth="507"</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px">></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <UserControl.Resources></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> <local:ServiceLocator x:Key="serviceLocator" /></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> </UserControl.Resources></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> <Grid x:Name="LayoutRoot" Background="White"></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <Grid.RowDefinitions></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> <RowDefinition Height="50" /></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <RowDefinition Height="*"/></pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; border-top-style: none; border-left-style: none; overflow: visible; padding-top: 0px"> </Grid.RowDefinitions></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <Grid.ColumnDefinitions></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <ColumnDefinition Width="*" /></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <ColumnDefinition Width="100" /></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> </Grid.ColumnDefinitions></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <StackPanel Grid.Row="0" Grid.ColumnSpan="2"></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <TextBlock Text="{Binding Path=Message.Value}" Foreground="Green" </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> HorizontalAlignment="Center" FontSize="24" </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> FontWeight="Bold" /></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <TextBlock Text="{Binding Path=Message.Date}" </pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> FontWeight="Bold" HorizontalAlignment="Center" Foreground="Red" /></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> </StackPanel></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <TextBox Text="{Binding Mode=TwoWay, Path=Message.Value}" Grid.Row="1" Grid.Column="0" /></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <Button Grid.Row="1" Grid.Column="1" cmd:Click.Command="{Binding Path=UpdateMessage}"</pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> cmd:Click.CommandParameter="{Binding Message}" ></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> <TextBlock><Run Text="Update Message"/></TextBlock></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> </Button></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"> </Grid></pre>

<pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"></UserControl></pre>

The difference between Jonas’ [DiveLog](http://cid-1a08c11c407c0d8e.skydrive.live.com/self.aspx/Code%20samples/DiveLog%20Silverlight%202%20RTW.zip)

Also, I need to update the Container property during my module’s Initialize method so I can maintain a reference to my runtime [UnityContainer](http://www.codeplex.com/unity)

## Conclusion

I’ve really learned a lot from this exercise and I hope it helps others. I know I’ve still got quite a bit to learn but I figure this is a good starting point for anyone wanting to take advantage of Prism and it goes a bit further than the PnP RI. I welcome any comments on improvements or questions. Over the summer I will be putting this all to a real-world test and I will continue to provide updates on what I’ve learned.

[Download Source](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/HelloWorld.Silverlight.zip)