---
layout: post
title: 'MVVM with Prism 101 – Part 6b: Wrapping IClientChannel'
date: '2010-03-08 19:00:00'
tags:
- silverlight
- prism
- mvvm
- mvvm-with-prism-101
- wcf-client-proxy
- faults
- iclientchannel
---

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/CodeCamp.zip)

* [Part 1: The Bootstrapper](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/)
* [Part 2: The Shell](/2009/10/12/mvvm-with-prism-101-ndash-part-2-the-shell/)
* [Part 3: Regions](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/)
 * [Part 3b: View Injection and The Controller Pattern](/2009/10/15/mvvm-with-prism-101-ndash-part-3b-view-injection-and/)
* [Part 4: Modules](/2009/10/23/mvvm-with-prism-101-ndash-part-4-modules/)
* [Part 5: The View-Model](2009/10/28/mvvm-with-prism-101-ndash-part-4-modules/)
 * [Part 5b: ServiceLocator vs Dependency Injection](/2009/11/02/mvvm-with-prism-101-ndash-part-5b-servicelocator-vs-depdency/)
* [Part 6: Commands](/2009/11/04/mvvm-with-prism-101-ndash-part-6-commands/)
 * [Part 6b: Wrapping IClientChannel](/2010/03/08/mvvm-with-prism-101-ndash-part-6b-wrapping-iclientchannel/)

I wasn’t originally planning on a post specific to this topic, and there is likely some rehashing here, but I’ve gotten questions from my last post about this and so I decided to write this to clarify things a little.

#Wither the Client Service Proxy?

I could have used the title “Ditching Client Service Proxy” or “Avoiding Add Service Reference”, but that’s not what the meat of the post is about. However, that is essentially the goal of this post. The client service proxy generated when you use “Add Service Reference…” to reference your web service from your client project is used by almost every demo I know. It quickly generates a proxy class for you that at first blush is “the bee’s knees”. There are some things to like about it:

* You don’t have to worry about IDispatcher
* It uses the familiar event driven publish/subscribe method from WinForms and WebForms that we’ve all been raised on
* It generates everything for you, why do any work?
* There might be more, feel free to jump in and add to the list

Let me answer with a question of my own: have you ever tried to program to the interface it generates? If you open the project right now and use svcutil.exe or run the “Add Service Reference…” wizard, then open up the Reference.cs file generated for you (you’ll need to either open it from Windows Explorer or tell Visual Studio to “show all files” in your project). Here’s what you’ll see at the top of the file:

    public interface IMessageService {
        
        System.IAsyncResult BeginAddMessage(CodeCamp.Model.Message message, System.AsyncCallback callback, object asyncState);
        
        void EndAddMessage(System.IAsyncResult result);
        
        System.IAsyncResult BeginGetMessages(System.AsyncCallback callback, object asyncState);
        
        System.Collections.ObjectModel.ObservableCollection<CodeCamp.Model.Message> EndGetMessages(System.IAsyncResult result);
    }

Right off you can check benefits one and two off the list above. You’ll need to use IDispatcher and there are no events on the interface either so you’re stuck using the Async Pattern still.

I know some of you are out there asking, “Why would I care? Why do I need to use the interface?”. Have you not been reading the previous posts in this series? We’re talking about writing modular, testable code here. Coupling your code to a concrete service implementation means:

* Your projects must reference your Service project
* Design-time data binding is not an option
* Your unit tests now become integration tests

The other argument against the client service proxy that I have heard is that your client and service can get out of sync and it’s a pain to deal with. Not having experienced this problem because I haven’t ever used the Client Service Proxy in production I can only just pass it on as hearsay.

#System.ServiceModel.ChannelFactory<T>

So if we’re not using “Add Service Reference…” how do we create our client classes? While I discussed this in my last post, just to make it easy I’m gonna mention it here as well. Essentially, ChannelFactory provides the same benefit of generating a proxy class for you without the hangups we discussed above, and it does it all in one method call – CreateChannel(). Here it is again, in case you missed it last time:

    ChannelFactory messageFactory = new ChannelFactory<IMessageServiceAsync>("BasicHttpBinding_IMessageEndpoint");
    IMessageServiceAsync service = messageFactory.CreateChannel();

This gives us the exact same interface as the above example which was generated for us. Now we had to do some extra work here, but you can cheat a little if you like (I’ll get to that). The extra work we had to do is that we had to define our own IMessageServiceAsync interface to match the contract we defined on the server side. So if our service contract is this:

    [ServiceContract]
    public interface IMessageService
    {
        [OperationContract]
        void AddMessage(Message message);
        [OperationContract]
        IList<Message> GetMessages();
    }

Then we need to create this ourselves:

    [ServiceContract(Name = "IMessageService")]
    public interface IMessageServiceAsync
    {
        [OperationContract(AsyncPattern = true)]
        IAsyncResult BeginAddMessage(Message message, AsyncCallback callback, Object asyncState);
        void EndAddMessage(IAsyncResult result);
     
        [OperationContract(AsyncPattern = true)]
        IAsyncResult BeginGetMessages(AsyncCallback callback, Object asyncState);
        IList<Message> EndGetMessages(IAsyncResult result);
    }

Notice the “Name” argument to the ServiceContract attribute? Combine that with the “AsyncPattern” argument to the OperationContract attribute as well as the Async Begin/End convention (this includes the references to AsyncCallback, IAsyncResult and Object for async state as well as the method names) and your client can now use the Async Pattern to communicate with your WCF service.

Also, because you’re doing this by hand, don’t forget to create your ServiceReferences.ClientConfig file:

    <configuration>
        <system.serviceModel>
            <bindings>
                <basicHttpBinding>
                    <binding name="BasicHttpBinding_IMessageService" maxBufferSize="2147483647"
                        maxReceivedMessageSize="2147483647">
                        <security mode="None">
                            <transport>
                                <extendedProtectionPolicy policyEnforcement="Never" />
                            </transport>
                        </security>
                    </binding>
                </basicHttpBinding>
            </bindings>
            <client>
                <endpoint address="http://localhost:3722/MessageService.svc"
                    binding="basicHttpBinding" bindingConfiguration="BasicHttpBinding_IMessageService"
                    contract="CodeCamp.Model.IMessageServiceAsync" name="BasicHttpBinding_IMessageEndpoint" />
            </client>
        </system.serviceModel>
    </configuration>

Now I can hear the wining already about maintaining two matching interfaces and a client config file, boo hoo. Well for those of you who really think this is a big deal, here’s the cheat I mentioned. If you really don’t want to do any of this by hand, you can use “Add Service Reference..” to generate both ClientConfig as well as the async version of your interface for you. After you’ve copied and pasted what you need, just remove the service reference and delete the files it generated for you. Voila!

Now you’re ready to use ChannelFactory and your client is only referencing an interface and not a concrete implementation of your service. Here’s what it looks like when you use it:

    IMessageServiceAsync m_MessageService;
     
    void SendMessageExecute(String arg)
    {
        Message message = new Message
        {
            Content = arg,
            Date = DateTime.Now
        };
        m_MessageService.BeginAddMessage(message, new AsyncCallback(EndSendMessage), null);
    }
     
    void EndSendMessage(IAsyncResult result)
    {
        m_MessageService.EndAddMessage(result);
    }

#Faults (or Why ClientChannelWrapper?)

When using services exceptions are called “Faults”, and whenever your service throws an exception or there is an error communicating with your service on the client side your proxy (the class which implements IClientChannel) becomes unusable. When this happens the IChannel.State property will return CommunicationState.Faulted. Now when this happens you need to be able to recover by initializing a new instance of your proxy. The problem comes up in when you are using Dependency Injection, “How do I create a new concrete instance of my proxy?”. You could call into your IoC container to resolve a new instance, but that is considered bad form, and what if your container is configured to treat your proxy as a singleton? What now?

It’s been a while since I first researched this, so for the purposes of this article I just googled “WCF CommunicationState.Faulted” and here are two results I picked quickly to back up my point:

http://bloggingabout.net/blogs/erwyn/archive/2006/12/09/WCF-Service-Proxy-Helper.aspx

http://blogs.microsoft.co.il/blogs/orenellenbogen/archive/2007/09/06/Making-WCF-Proxy-useable.aspx

The basic idea here is to allow the application to receive fault exceptions, but to make sure our client proxy is durable. Otherwise, our users will have to restart our application every time they experience a fault.

ClientChannelWrapper is designed to be a wrapper for IClientChannel and ClientChannelFactory. My original design required a wrapper class for each different service used by the client application. This was instantly not a hit with me. So I decided to make use of the C# lambda features to make my wrapper flexible. It requires a little extra to call the service methods, but I kinda like the flexibility it gives me. Here’s how you use it:

    void SendMessageExecute(String arg)
    {
        Message message = new Message
        {
            Content = arg,
            Date = DateTime.Now
        };
        m_MessageService.BeginInvoke(m => m.BeginAddMessage(message, new AsyncCallback(EndSendMessage), null));
    }
     
    void EndSendMessage(IAsyncResult result)
    {
        m_MessageService.EndInvoke(m => m.EndAddMessage(result));
    }

Notice, the wrapper has just BeginInvoke and EndInvoke methods and you pass in a call to your proxy’s async interface method as a lambda expression. Here’s the full source for ClientChannelWrapper:

    using System;
    using System.Collections.Generic;
    using System.ServiceModel;
    using CodeCamp.Model;
     
    namespace CodeCamp.Common.Services
    {
        /// <summary>
        /// Wrapper class ensures proper life-cycle handling for IClientChannel 
        /// objects by implementing proper Open, Close and Dispose techniques
        /// based on recommended practices.
        /// </summary>
        /// <remarks>
        /// The idea for BeginInvoke and EndInvoke methods was derived from
        /// this <see cref="http://msdn.microsoft.com/en-us/magazine/ee309512.aspx">MSDN article</see>
        /// </remarks>
        /// <typeparam name="T">An interface which defines an async ServiceContract</typeparam>
        public class ClientChannelWrapper<T> : IDisposable, IClientChannelWrapper<T> where T : class
        {
            private ChannelFactory<T> m_Factory;
            private T m_Service;
            private Object m_SyncRoot = new Object();
     
            public ClientChannelWrapper(String endpointName)
            {
                m_Factory = new ChannelFactory<T>(endpointName);
            }
     
            public ClientChannelWrapper(T service)
            {
                m_Service = service;
            }
     
            public IAsyncResult BeginInvoke(Func<T, IAsyncResult> function)
            {
                try
                {
                    return function.Invoke(Current);
                }
                catch (Exception)
                {
                    CloseChannel();
                    throw;
                }
            }
     
            public TResult EndInvoke<TResult>(Func<T, TResult> function)
            {
                try
                {
                    return function.Invoke(Current);
                }
                catch (Exception)
                {
                    CloseChannel();
                    throw;
                }
            }
     
            public void EndInvoke(Action<T> action)
            {
                try
                {
                    action.Invoke(Current);
                }
                catch (Exception)
                {
                    CloseChannel();
                    throw;
                }
            }
     
            protected void CloseChannel()
            {
                if (m_Service != null)
                {
                    lock (m_SyncRoot)
                    {
                        if (m_Service != null)
                        {
                            IClientChannel channel = m_Service as IClientChannel;
                            if (channel != null)
                            {
                                try
                                {
                                    channel.Faulted -= IClientChannel_Faulted;
                                    if (channel.State == CommunicationState.Faulted)
                                        channel.Abort();
                                    else
                                        channel.Close();
                                }
                                catch (CommunicationException) { channel.Abort(); }
                                catch (TimeoutException) { channel.Abort(); }
                                catch (Exception) { channel.Abort(); throw; }
                                finally { m_Service = null; }
                            }
                        }
                    }
                }
            }
     
            protected T Current
            {
                get
                {
                    if (m_Service != null)
                        return m_Service;
     
                    lock (m_SyncRoot)
                    {
                        if (m_Service == null)
                        {
                            m_Service = m_Factory.CreateChannel();
                            ((IClientChannel)m_Service).Faulted += IClientChannel_Faulted;
                        }
                    }
     
                    return m_Service;
                }
            }
     
            private void IClientChannel_Faulted(Object sender, EventArgs e)
            {
                CloseChannel();
            }
     
            #region IDisposable Members
     
            private Boolean m_IsDisposed = false;
     
            public void Dispose()
            {
                if (m_IsDisposed)
                    throw new ObjectDisposedException("ClientChannelWrapper");
     
                try
                {
                    CloseChannel();
                }
                finally
                {
                    m_IsDisposed = true;
                }
            }
     
            #endregion
        }
    }

And here’s how you instantiate ClientChannelWrapper:

    IClientChannelWrapper<IMessageServiceAsync> service = new ClientChannelWrapper<IMessageServiceAsync>("BasicHttpBinding_IMessageEndpoint");

Where “BasicHttpBinding_IMessageEndPoint” is the name of your endpoint configuration in your ClientConfig file.

The last bit here is that we need an interface so we aren’t bound to a specific implementation and we can make sure our solution is still testable and that we haven’t disabled design-time data binding. Here’s the interface definition:

    public interface IClientChannelWrapper<T> where T : class
    {
        IAsyncResult BeginInvoke(Func<T, IAsyncResult> function);
        void Dispose();
        void EndInvoke(Action<T> action);
        TResult EndInvoke<TResult>(Func<T, TResult> function);
    }

The nice thing about this is that it doesn’t change the concrete implementation of our proxy. For runtime, we will continue to use ClientChannelFactory when we pass in an endpoint name (you could update this to include a ctor which accepts an instance of an endpoint if you like). Then for testing, we can pass in our own mock implementation of our service proxy. The source code included with all the posts in this series includes a MockMessageService if you’d like to see an example.

#Conclusion

First of all I want to make note that I did not address a few things in this post. Namely, interacting with IDispatcher to coordinate with the UI thread, commands, and service implementation and error handling. For those I refer you back to my previous post. There had been some confusion specifically on two points:

* Why not “Add Service Reference…”?
* Why ClientChannelWrapper?

My last post was really long and so I only lightly touched these topics. Since there was confusion I decided a post addressing these topics was needed. I hope I have succeeded in clearing things up for you.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/CodeCamp.zip)
