---
layout: post
title: 'Silverlight and Prism: Decoupling the WCF Client Proxy'
date: '2009-03-10 23:49:00'
tags:
- unit_testing
- silverlight
- design_patterns
- prism
- wcf
---

I’m in the process of creating the . Hopefully, for once, I’ll see it through to the end and also post the source and an [insightful blog entry to help everybody who’s struggling to do the same](http://developmentalmadness.blogspot.com/2009/06/prism-for-silverlight-2-taking-hello.html)

Anyhow, I’ve taken the recent release of Prism v2, which introduced Silverlight support, to dig in and get to know both Prism and Silverlight. As background, I have one production WFP application under my belt. We didn’t use Prism, although I looked at it. Instead, I had modeled it after Jonas Follesoe’s [Presentation Model implementation](http://jonas.follesoe.no/TechEd2008NdashSilverlight2ForDevelopers.aspx)

My goals for this demo application are that it would be fully testable and modular. It would incorporate WCF with Silverlight 2 and the tests could be run without the Silverlight Test Framework. About the last requirement, I have nothing against the SL Test Framework. In fact I see it has great potential, but I think as a rule if my code is really decoupled then it shouldn’t require the framework for testing. That said I really think it could be useful for functional testing and for compatibility testing between browsers.

**<u>UPDATE 3/12/09</u>**: While looking for a way to avoid using partial classes and explicit interface implementations I ran into a post about [avoiding generated proxies](http://ayende.com/Blog/archive/2008/03/29/WCF-Async-without-proxies.aspx)

**UPDATE 5/10/09**: I've since finished working through this and have an [updated post](http://developmentalmadness.blogspot.com/2009/06/prism-for-silverlight-2-taking-hello.html)

## Problem

One thing that has dogged me in this exercise has been the WCF client proxy generated when I add a service reference to my Silverlight project. I ran into a couple things that either didn’t work, or just didn’t smell right (eg. didn’t quite meet my goals listed above).

I like that the service generates a proxy class for me, I also like that it creates an interface for me as well. However, the first problem I ran into was trying to use the interface. Here’s what the generator creates:

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;">[System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "3.0.0.0")]</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">[System.ServiceModel.ServiceContractAttribute(Namespace="http://helloworld.org/messaging", ConfigurationName="Web.Services.HelloWorldMessageService")]</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;">public interface HelloWorldMessageService {</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> [System.ServiceModel.OperationContractAttribute(AsyncPattern=true, Action="http://helloworld.org/messaging/HelloWorldMessageService/UpdateMessage", ReplyAction="http://helloworld.org/messaging/HelloWorldMessageService/UpdateMessageResponse")]</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> System.IAsyncResult BeginUpdateMessage(string message, System.AsyncCallback callback, object asyncState);</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> void EndUpdateMessage(System.IAsyncResult result);</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> [System.ServiceModel.OperationContractAttribute(AsyncPattern=true, Action="http://helloworld.org/messaging/HelloWorldMessageService/GetMessage", ReplyAction="http://helloworld.org/messaging/HelloWorldMessageService/GetMessageResponse")]</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> System.IAsyncResult BeginGetMessage(System.AsyncCallback callback, object asyncState);</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> HelloWorld.Model.Message EndGetMessage(System.IAsyncResult result);</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">}</pre>

And for reference here’s my service definition:

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">public class Message</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">{</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> public DateTime Date { get; set; }</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> public String Value { get; set; }</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">}</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">[ServiceContract(Namespace = "http://helloworld.org/messaging")]</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;">[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">public class HelloWorldMessageService</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;">{</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> private static Message _message = new Message { Value = "Hello from WCF", Date = DateTime.Now };</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> [OperationContract]</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> public void UpdateMessage(string message)</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> {</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> _message.Value = message;</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> _message.Date = DateTime.Now;</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> }</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> [OperationContract]</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> public Message GetMessage()</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> {</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;"> return _message;</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> }</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">}</pre>

My first WPF project did not require asynchronous handling – you may scoff, but it only operated on small local files, converting them from one format to another and so asynchronous communication would have been better but would not have made any difference to the end user.

When I first attempted to work with asynchronous communication (first in a xaml-type application) I was a little flustered. All the examples I could find (in books or online) used the XXXAsync() methods and Completed events generated in the proxy class. But my problem was that these where not part of the interface generated for the class, so I couldn’t use them.

The interface includes methods which are standard to the asynchronous programming model. I’ve used them before for network communication, file system operations and other common operations which often block the current thread. So here’s what my first attempt looked like:

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;">public HelloWorldPresenter(IHelloWorldView view, IMessageServiceClient service)</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:#f4f4f4;">{</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> // store dependencies</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> _service = service;</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // load data asyncronously</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> IAsyncResult result = _service.BeginGetMessage(new AsyncCallback(BeginGetMessageComplete), null);</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> // do some other stuff</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">}</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">private void BeginGetMessageComplete(IAsyncResult result)</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;">{</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // get result</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> Message output = _service.EndGetMessage(result);</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> this.Message = output;</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">}</pre>

But when I ran it I got the following error:

**_UnauthorizedAccessException: Invalid cross-thread access._**

Which translates to, “you can’t update the UI thread from a background thread, dummy”.

## Solution

After digging (and missing the solution a couple of times), I found that I had to use the System.Threading.Dispatcher class to correct the issue. The reason I had missed it was because I didn’t understand Dispatcher (I did say I only had one WPF app under my belt and it didn’t use async methods). I remember reading during my search suggestion to store a reference to Dispatcher in the container so I could resolve it, but it didn’t seem right. But once I [read the documentation](http://msdn.microsoft.com/en-us/library/ms741870.aspx#)

As it turns out there is only one Dispatcher in your application (you can create more, but everything I’ve read says you should have a really good reason for it). The Dispatcher is attached to the CurrentThread and so that’s why it’s a good way to get back to the UI thread. So when your application starts, you register a reference to Dispatcher with your container. There’s a couple ways to access it, but I’m grabbing it from the view I’m registering as my RootVisual object.

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;">public class Bootstrapper : UnityBootstrapper</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">{</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> protected override IModuleCatalog GetModuleCatalog()</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> {</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> // setup module catalog</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> }</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> protected override DependencyObject CreateShell()</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> {</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // calling Resolve instead of directly initing allows use of dependency injection</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> Shell shell = Container.Resolve<Shell>();</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> // set shell as RootVisual</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> Application.Current.RootVisual = shell;</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // store reference to shell.Dispatcher so background threads can update UI</pre>

<pre style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: nonefont-family:consolas, 'Courier New', courier, monospace;font-size:8pt;color:white;"> Container.RegisterInstance<Dispatcher>(shell.Dispatcher);</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> return shell;</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> }</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">}</pre>

Now my presenter looks like this:

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">public HelloWorldPresenter(IHelloWorldView view, HelloWorldMessageService service, IUnityContainer container)</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">{</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // store dependencies</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="#f4f4f4" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> _service = service;</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> _container = container;</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // initialize locals</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> UpdateMessage = new DelegateCommand<string>(this.OnUpdateMessageExecute, this.OnUpdateMessageCanExecute);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> // load data asyncronously</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> IAsyncResult result = _service.BeginGetMessage(new AsyncCallback(BeginGetMessageComplete), null);</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // set reference to view (needed for RegionManager)</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> View = view;</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> // set the view's model to the presenter</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> View.Model = this;</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none">}</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none">private void BeginGetMessageComplete(IAsyncResult result)</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">{</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> // get result</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> Message output = _service.EndGetMessage(result);</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> // need dispatcher to execute on UI thread</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> Dispatcher dispatcher = _container.Resolve<Dispatcher>();</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> // update Message on UI thread</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> dispatcher.BeginInvoke(() => this.Message = output);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none">}</pre>

I can resolve a reference to Dispatcher and either update my model directly as I’ve done here or I could also make a method call and pass in the value of “output” as an argument. Here I’ve chosen to update the model directly since it is a simple one-liner.

Functionally, this meets my goals, but as an exercise I also wanted to make it so my modules didn’t have to reference each other. The Prism documentation recommends against it (if you can avoid it) and since I was trying to be thorough I decided to remove references between modules. First I created a new Silverlight Class Library project and called it “Interfaces”. Then I defined the following interface:

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none">public interface IMessageServiceClient</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none">{</pre>

<pre face="consolas, 'Courier New', courier, monospace" size="8pt" color="white" style="padding-right: 0px; padding-left: 0px; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; border-right-style: none; border-left-style: none; background- border-bottom-style: none"> IAsyncResult BeginGetMessage(AsyncCallback callback, object asyncState);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> string EndGetMessage(IAsyncResult result);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> IAsyncResult BeginUpdateMessage(string message, AsyncCallback callback, object asyncState);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> void EndUpdateMessage(IAsyncResult result);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none">}</pre>

Technically a module IS a Silverlight Class Library, but since not every Silverlight Class Library is a module I think I can get away with this and still meet the Prism guidelines.

The next step is to apply the interface to my WCF client proxy. This is easy since it is defined as a partial class. So all I had to do was this:

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">public partial class HelloWorldMessageServiceClient : IMessageServiceClient</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none">{</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> #region IMessageServiceClient Members</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> IAsyncResult IMessageServiceClient.BeginGetMessage(AsyncCallback callback, object asyncState)</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> {</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> return ((HelloWorldMessageService)this).BeginGetMessage(callback, asyncState);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> }</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> string IMessageServiceClient.EndGetMessage(IAsyncResult result)</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> {</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> return ((HelloWorldMessageService)this).EndGetMessage(result);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> }</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> IAsyncResult IMessageServiceClient.BeginUpdateMessage(string message, AsyncCallback callback, object asyncState)</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> {</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> return ((HelloWorldMessageService)this).BeginUpdateMessage(message, callback, asyncState);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> }</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> void IMessageServiceClient.EndUpdateMessage(IAsyncResult result)</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> {</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: #f4f4f4; border-bottom-style: none"> ((HelloWorldMessageService)this).EndUpdateMessage(result);</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> }</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none"> #endregion</pre>

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">}</pre>

You’ll have to do this for every WCF OperationContract in your service, so you can decide if this is worth it to you because if you modify your service you’ll have to do more than just execute “Update Service Reference” on your web service reference in the project.

The other trick in getting this to work is that you need a Silverlight project which has a copy of your object model in it. If you didn’t know already, you'r Silverlight project can’t contain a reference to anything but another Silverlight project. The best way around this is to have your model defined in a standard Class LIbrary Project, then create a Silverlight Class Library project and add each class file in your model to the Silverlight Class Library Project “As a Link”. This means there’s only one copy of each class file in your model, it’s a pain but for now it’s the only way to do it since you need access to your model definition in Silverlight and in your WCF project.

So in my “Interfaces” project, I’ve defined my interface and I have a linked copy of my Message class and this is the reference I use for module projects.

With these changes the only difference in my presenter class is the constructor arguments:

<pre style="padding-right: 0px; padding-left: 0px; font-size: 8pt; padding-bottom: 0px; margin: 0em; overflow: visible; width: 100%; color: black; border-top-style: none; line-height: 12pt; padding-top: 0px; font-family: consolas, 'Courier New', courier, monospace; border-right-style: none; border-left-style: none; background-color: white; border-bottom-style: none">public HelloWorldPresenter(IHelloWorldView view, IMessageServiceClient service, IUnityContainer container)</pre>

I just had to change the type of my “service” argument.

This allows me to completely decouple the actual WCF client proxy implementation from my Silverlight application. But I had one more concern that bothered me at this point: does the use of Dispatcher mean I’m coupled to the UI? I didn’t know if there were a way to instantiate or mock Dispatcher so I could properly test my code.

As it turns out there is a dependency required here, but it really isn’t significant. I had to dig around in reflector to find it because I was looking to see how it was instantiated since it didn’t seem to have a public constructor. Mind you I haven’t started writing tests yet here, but if your project references the WindowsBase assembly then you can either use the Dispatcher.CurrentDispatcher static property or Dispatcher.FromThread() static method to get an instance of Dispatcher. From there you should be able to run your tests without any dependency on WCF or the UI.

For now, you can download a rough draft of the code from [here](http://dl.getdropbox.com/u/273037/HelloWorld.Silverlight.zip)

![](http://res1.blogblog.com/tracker/29942641-8103378304036143870.gif?l=developmentalmadness.blogspot.com)