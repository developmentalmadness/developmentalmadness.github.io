---
layout: post
title: 'MVVM with Prism 101 – Part 6: Commands'
date: '2009-11-04 19:00:00'
tags:
- silverlight
- prism
- mvvm
- mvvm-with-prism-101
- icommand
- wcf-client-proxy
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


*I have to apologize for the length of this article. I wanted to split it into two separate parts, but the way I ended up writing it all just seems difficult to split it now that I'm done. Hopefully the section headings are clear enough for those who are only interested in specifics can find what they are looking for.*

This is part 6 in my series on implementing MVVM with the Prism Framework (CompositeWPF). This time we're going to discuss Commands. You can think of Commands as an abstraction of Events, but don't confuse the two. An Event is fired by a single publisher and anyone who is interested in that event may subscribe to it. With regards to the UI, a Button has a Click event. If you want to handle that click event you subscribe to it by creating an event handler which will be called when the event fires. Your event handler can then perform an action whenever it is called in response to the event to which it is subscribed. In other words, if you subscribe to the Button.Click event your event handler will be called anytime the Button is clicked. Additionally, other objects interested in the Click event of the button may be notified and they will also be able to perform other operations when the Click event fires.

A command is technically the opposite. The command itself performs a specific operation and the command is exposed as part of a public interface which can be called to execute that operation. It can be called by any object which can access the command but it provides no means to subscribe to the command or notifications that it has been called. The command itself is actually more analogous to the event handler than it is to the event. But the way you wire it up seems familiar to those used to wiring up events and event handlers using the Visual Studio designer.  When wiring up a Command to a Button object you use an attached property to bind the UI element to the Command, similar to the way you can use the OnClick attribute of the Button element to declare an event handler you wish to be called when the Button is clicked.

##Event Example

    <Button Content="Send" Click="Button_Clicked" />

##Command Example
    
    <Button Content="Send" VerticalAlignment="Top" Width="100" 
             cmd:Click.Command="{Binding SendMessage}" />
 
WPF and Silverlight both provide an interface named ICommand which is defined this way:
 
    using System;
     
    namespace System.Windows.Input
    {
        // Summary:
        //     Defines the contract for commanding, 
        //        using the same contract as used in WPF.
        public interface ICommand
        {
            // Summary:
            //     Occurs when changes occur that affect 
            //        whether the command should execute.
            event EventHandler CanExecuteChanged;
     
            // Summary:
            //     Defines the method that determines 
            //        whether the command can execute in its
            //         current state.
            //
            // Parameters:
            //   parameter:
            //     Data used by the command. If the 
            //        command does not require data to be passed,
            //        this object can be set to null.
            //
            // Returns:
            //     true if this command can be executed; 
            //        otherwise, false.
            bool CanExecute(object parameter);
            //
            // Summary:
            //     Defines the method to be called when the 
            //        command is invoked.
            //
            // Parameters:
            //   parameter:
            //     Data used by the command. If the command 
            //        does not require data to be passed,
            //         this object can be set to null.
            void Execute(object parameter);
        }
    }

The important parts of the interface are the Execute and CanExecute methods. Execute is the method which will be called and CanExecute indicates wither or not the Command is currently active. For example, if you don't want the user clicking on the Save button which is bound to your SaveCommand then you can provide logic in the CanExecute method which will only return true when the state of your ViewModel (or the data model exposed by your ViewModel) is "modified". If CanExecute returns "false" then WPF/Silverlight will disable the button until CanExecute returns "true".

#Exposing Commands

In order to bind a UI element to a command first you must provide a command from your View-Model. Prism provides an implementation of ICommand named DelegateCommand<T>. When implementing MVVM you will want to use a command implementation other than RoutedCommand provided by WPF. The reason for this is because RoutedCommand is tied to the UI and you will possibly experience some difficulties using RoutedCommand with MVVM as your application grows in complexity and you try to keep your views modular. If you want more details on what those issues are, see the Prism documentation for "Commands". Most of my experience has been with Silverlight, which is why I defer to the Prism docs. Silverilght doesn't have an implementation of ICommand, so no RoutedCommand. For that reason, I would most likely say something wrong since I don't really have any experience with it.

DelegateCommand<T> provides a UI agnostic means of exposing your commands to the View. And because it uses Generics it also allows you to work with strongly typed parameters. Here's how I've implemented the SendMessage command in the sample application I have provided with this series:

    public EditorViewModel(IMessageServiceAsync service, 
        IEventAggregator aggregator)
    {
        m_MessageService = service;
        // ... other setup code ...
        SendMessage = new DelegateCommand<String>(
                SendMessageExecute, SendMessageCanExecute);
    }
     
    public ICommand SendMessage { get; set; }
     
    private void SendMessageExecute(String arg)
    {
        Message message = new Message
        {
            Content = arg,
            Date = DateTime.Now
        };
        IAsyncResult result = m_MessageService.BeginAddMessage(
            message, new AsyncCallback(EndSendMessage), null);
     
        if (result.CompletedSynchronously)
            EndSendMessage(result);
    }
     
    private bool SendMessageCanExecute(String arg)
    {
        return !String.IsNullOrEmpty(Message.Content);
    }
     
    private void EndSendMessage(IAsyncResult result)
    {
        m_MessageService.EndInvoke(m => m.EndAddMessage(result));
    }

As you can see CanExecute will only return true when the the Message property of our ViewModel is not null or empty. In our view the Message property is bound to the TextBox where the user will enter the message they wish to send.

#Command Parameters

In the last code snippet you may have noticed that Execute and CanExecute accept a string parameter. The ICommand interface declares these as simple object type parameters, but DelegateCommand<T> provides the strongly typed version for us. Either way, because of the parameters we can make our Command a bit more flexible (not that we need it in this situation). Prism provides a second attached property which allows you to bind a value to the parameter for ICommand.Execute.  If you are using WPF or Silverlight 3 you could bind to the TextBox's Text property or any other element on your UI. If you're using Silverlight 2 you can only bind to a StaticResource or some public property of the Button's DataContext.

    <Button Content="Send" VerticalAlignment="Top" Width="100" 
             cmd:Click.Command="{Binding SendMessage}" 
             cmd:Click.CommandParameter="{Binding Path=CurrentMessage.Content}" />
 
Using Command Parameters like this allows you to, for example, add a button to each item of a list and pass the object bound to the DataContext of each item to the Command on your view model. When a button is clicked the correct object will be passed as an argument to the Execute method.

#Service Client Communication

Many of the commands you define will be backed by an external web service and given that Visual Studio provides a nice wizard to connect to a web service and generate a client proxy to communicate with any service I have been asked why I don't use the "Add Service Reference" utility provided by Visual Studio or SvcUtil.exe provided with the .NET Framework SDK. Personally, I don't like the messy designer file generated by the utility. I don't have full control over the namespace generated and I found mocking the interfaces to be a pain. Many of the examples which demonstrate using the proxy generated by the utility look like this:

    private void GetMessagesExecute(Object arg)
    {
        MessageServiceClient client = new MessageServiceClient();
        client.GetMessagesCompleted += new EventHandler<GetMessagesCompletedEventArgs>(client_GetMessagesCompleted);
        client.GetMessagesAsync();
    }
     
    void client_GetMessagesCompleted(object sender, GetMessagesCompletedEventArgs e)
    {
        ObservableCollection<Message> result = e.Result;
    }
 
There are some nice features here. First and foremost, you don't have to worry about the UI thread. When the completed event fires you don't have to get a reference to the Dispatcher to update properties which raise INotifyPropertyChanged or INotifyCollectionChanged. It makes things nice and clean. But you can't mock this class. I've tried and it requires practically writing the whole thing myself. The generated proxy has an interface which matches the interface I defined for my service, but there is no interface which exposes the "MyMethodCompleted" events or the "MyMethodAsync" methods. So if I want to be able to write unit tests which are independent of any external dependencies then I cannot use the Async/Completed model, I must use the Begin/End Async patterns. And if I am going to use those anyway then why mess with a generated proxy when all it requires is a single line of code to create my service proxy:

    IMessageServiceAsync service = new ChannelFactory<IMessageServiceAsync>(
        "BasicHttpBinding_IMessageEndpoint").CreateChannel();
To support this, there is an extra few steps:

* I must define an Async version of my Service Contract
* If I am using Silverlight I must add a link to not only the file which contains Async Service Contract definition but also the class files which define the types returned by my service.
* If I change my Service Contract I must mirror the change in the Async version of my Service Contract.

But except for maintaining an async version of my Service Contract these are one time setup steps that really don't take much time. And as for maintaining an async interface, it really doesn't take any more time than it does to remove the service reference and re-add it. For me it is worth the time saved trying to create the mock objects needed to properly test in isolation. We are all generally allergic to additional typing but in the end I find that doing it this way saves me time in the long run.

##Protecting from Faults

For a long time I was uncomfortable with just using the raw ClientChannel object provided for me. When applications are deployed in the wild, stuff happens and you want a clean way for your application to recover. For example, when you experience a Fault in your communication with the service you need to properly clean up the communication channel. But what do you do if you still need to communicate with the service. You need a new channel for communication. But in our scenario the ViewModel doesn't know how to create the channel. So how do we properly handle faults and recover gracefully from them without requiring our user to do anything?

    using System;
    using System.Collections.Generic;
    using System.ServiceModel;
    using CodeCamp.Model;
     
    namespace CodeCamp.Common.Services
    {
        public class MessageServiceWrapper : IMessageServiceAsync, IDisposable
        {
            private ChannelFactory<IMessageServiceAsync> m_Factory;
            private IMessageServiceAsync m_Service;
            private Object m_SyncRoot = new Object();
     
            public MessageServiceWrapper(String endpointName)
            {
                m_Factory = new ChannelFactory<IMessageServiceAsync>(endpointName);
            }
     
            private void CloseChannel()
            {
                if (m_Service != null)
                {
                    lock (m_SyncRoot)
                    {
                        if (m_Service != null)
                        {
                            try
                            {
                                IClientChannel channel = (IClientChannel)m_Service;
                                channel.Faulted -= IClientChannel_Faulted;
                                if (channel.State == CommunicationState.Faulted)
                                    channel.Abort();
                                else
                                    channel.Close();
                                channel.Dispose();
                            }
                            catch (CommunicationException) { }
                            catch (TimeoutException) { }
                            m_Service = null;
                        }
                    }
                }
            }
     
            private IMessageServiceAsync Current
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
     
            #region IMessageServiceAsync Members
     
            public IAsyncResult BeginAddMessage(Message message, 
                AsyncCallback callback, object asyncState)
            {
                return Current.BeginAddMessage(message, callback, asyncState);
            }
     
            public void EndAddMessage(IAsyncResult result)
            {
                try
                {
                    Current.EndAddMessage(result);
                }
                catch
                {
                    
                    CloseChannel();
                    throw;
                }
            }
     
            public IAsyncResult BeginGetMessages(AsyncCallback callback, 
                object asyncState)
            {
                return Current.BeginGetMessages(callback, asyncState);
            }
     
            public IList<Message> EndGetMessages(IAsyncResult result)
            {
                try
                {
                    return Current.EndGetMessages(result);
                }
                catch
                {
                    CloseChannel();
                    throw;
                }
            }
     
            #endregion
     
            #region IDisposable Members
     
            private Boolean m_IsDisposed = false;
     
            public void Dispose()
            {
                if (m_IsDisposed)
                    throw new ObjectDisposedException("MessageServiceWrapper");
     
                CloseChannel();
     
                ((IDisposable)m_Factory).Dispose();
     
                m_IsDisposed = true;
            }
     
            #endregion
        }
    }

My first attempt at this was to create a wrapper class for each service I used on my client. The problem was it was too much work. I had to maintain the proper methods and signatures to keep my contracts in sync with my interfaces. This had to be done for every operation on every service. I really didn't like this method at all.

So I created a base class which helped a little, but I still had to keep the interface in sync.

###ClientChannelWrapper.cs

    using System;
    using System.Collections.Generic;
    using System.ServiceModel;
    using CodeCamp.Model;
     
    namespace CodeCamp.Common.Services
    {
        public class ClientChannelWrapper<T> : IDisposable where T : class
        {
            private ChannelFactory<T> m_Factory;
            private T m_Service;
            private Object m_SyncRoot = new Object();
     
            public ClientChannelWrapper(String endpointName)
            {
                m_Factory = new ChannelFactory<T>(endpointName);
            }
     
            protected void CloseChannel()
            {
                if (m_Service != null)
                {
                    lock (m_SyncRoot)
                    {
                        if (m_Service != null)
                        {
                            IClientChannel channel = (IClientChannel)m_Service;
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

###MessageServiceWrapper.cs

    using System;
    using System.Collections.Generic;
    using CodeCamp.Common.Services;
    using CodeCamp.Model;
     
    namespace CodeCamp.Services
    {
        public class MessageServiceWrapper : ClientChannelWrapper<IMessageServiceAsync>, IMessageServiceAsync
        {
            public MessageServiceWrapper(string endPointName)
                : base(endPointName)
            {
     
            }
     
            public MessageServiceWrapper()
                : base("BasicHttpBinding_IMessageEndpoint")
            {
     
            }
     
            #region IMessageServiceAsync Members
     
            public IAsyncResult BeginAddMessage(Message message, AsyncCallback callback, object asyncState)
            {
                try
                {
                    return Current.BeginAddMessage(message, callback, asyncState);
                }
                catch
                {
                    CloseChannel();
                    throw;
                }
            }
     
            public void EndAddMessage(IAsyncResult result)
            {
                try
                {
                    Current.EndAddMessage(result);
                }
                catch
                {
     
                    CloseChannel();
                    throw;
                }
            }
     
            public IAsyncResult BeginGetMessages(AsyncCallback callback, object asyncState)
            {
                try
                {
                    return Current.BeginGetMessages(callback, asyncState);
                }
                catch
                {
                    CloseChannel();
                    throw;
                }
            }
     
            public IList<Message> EndGetMessages(IAsyncResult result)
            {
                try
                {
                    return Current.EndGetMessages(result);
                }
                catch
                {
                    CloseChannel();
                    throw;
                }
            }
     
            #endregion
     
        }
    }

This wasn't much better, it did help but I knew I couldn't really use this in any more than a trivial application with few or only one service. But I've been reading a bit on functional programming (not enough to write F# code or Haskell or anything for that matter) and I ran into this article by Jeremy Miller. He demonstrates using a technique to reduce the need to write so much boilerplate code required to call a repository. So I sacrificed a little cleanliness in my interfaces and came up with this:

###IClientChannelWrapper.cs

    using System;
     
    namespace CodeCamp.Common.Services
    {
        public interface IClientChannelWrapper<T> where T : class
        {
            IAsyncResult BeginInvoke(Func<T, IAsyncResult> function);
            void Dispose();
            void EndInvoke(Action<T> action);
            TResult EndInvoke<TResult>(Func<T, TResult> function);
        }
    }

###ClientChannelWrapper.cs

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

And here's how you use it :

###Create/Register ClientChannelWrapper

    IClientChannelWrapper<IMessageServiceAsync> service = new ClientChannelWrapper<IMessageServiceAsync>("BasicHttpBinding_IMessageEndpoint");
    m_Container.RegisterInstance<IClientChannelWrapper<IMessageServiceAsync>>(service);

###Reference ClientChannelWrapper

    public class EditorViewModel : IEditorViewModel
    {
        private IClientChannelWrapper<IMessageServiceAsync> m_MessageService;
     
        public EditorViewModel(IClientChannelWrapper<IMessageServiceAsync> service, 
            IEventAggregator aggregator)
        {
            m_MessageService = service;
            // ... other ctor stuff ...
        }

###Use ClientChannelWrapper

    IAsyncResult result = m_MessageService.BeginInvoke(
        m => m.BeginAddMessage(message, new AsyncCallback(EndSendMessage), null));

What this does for us is that all our service calls can now be wrapped in try/catch blocks which will auto-magically clean up the connection correctly (call Abort - can't call Dispose) if there is a fault. Then you can gracefully catch the exception and recover. When you retry a new client channel will be created for you without any knowledge on the part of your ViewModel.

#Mind Your UI Thread

If you aren't using a generated client proxy or if you are doing any other kind of asynchronous calls (like sockets) you need to be aware of the UI thread. Making your UI more responsive by performing long running tasks on a background thread is all well and good. However, when your operation completes and you need to update your ViewModel you must keep in mind that your UI is running on a static thread and can't be updated from a background thread. Basically this means any public properties on your ViewModel which will raise INotifyPropertyChanged or INotifyCollectionChanged cannot be updated by your background thread. So how do you update them if our ViewModel doesn't know anything about the UI?

I have defined an interface I call IDispatcher:

    using System;
     
    namespace CodeCamp.Common
    {
        public interface IDispatcher
        {
            void BeginInvoke(Action action);
            void BeginInvoke(Delegate action, params Object[] args);
        }
    }

Then I have a concrete class called DispatcherFacade which allows me to pass in a flag telling it if the application is running on a UI thread or if is running in a test environment or design mode. If the application UI is not running (false) then the action or delegate is invoked on the current thread. If the UI is running (true) then it gets a reference to the UI thread and executes the delegate on the UI thread:

    using System;
    using System.Windows;
     
    namespace CodeCamp.Common
    {
        public class DispatcherFacade : IDispatcher
        {
            private Boolean m_IsHtmlEnabled;
     
            public DispatcherFacade(Boolean isHtmlEnabled)
            {
                m_IsHtmlEnabled = isHtmlEnabled;
            }
     
            #region IDispatcher Members
     
            public void BeginInvoke(Action action)
            {
                if (m_IsHtmlEnabled == false)
                    action.Invoke();
     
                Deployment.Current.Dispatcher.BeginInvoke(action);
            }
     
            public void BeginInvoke(Delegate action, params object[] args)
            {
                if (m_IsHtmlEnabled == false)
                    action.DynamicInvoke(args);
     
                Deployment.Current.Dispatcher.BeginInvoke(action, args);
            }
     
            #endregion
        }
    }

This keeps me from having to write code which is dependent upon the UI and I don't have to write a mock for IDispatcher as DispatcherFacade handles all three situations.

#Why Check IAsyncResult.CompletedSyncronously?

    private void GetMessagesExecute(Object arg)
    {
        IAsyncResult result = m_MessageService.BeginInvoke(
            m => m.BeginGetMessages(new AsyncCallback(EndGetMessages), null));
        if (result.CompletedSynchronously)
            EndGetMessages(result);
    }

You'll notice whenever I make a call to a BeginXX async method I check the CompletedSyncronously property. If it's "true" then I call my EndXX AsyncCallback method. The reason for this is to simplify testing. Writing tests for asynchronous method calls is a pain, this way my tests are cleaner and self-contained in a single method without having to account for race conditions caused by a different environment (test vs. runtime). In order for this to work I just needed to implement my own version of IAsyncResult:

    using System;
    using System.Threading;
     
    namespace CodeCamp.Common.Utility
    {
        public class MockAsyncResult : IAsyncResult
        {
     
            #region IAsyncResult Members
     
            private Object m_AsyncState;
            public object AsyncState
            {
                get { return m_AsyncState; }
                set { m_AsyncState = value; }
            }
     
            ManualResetEvent m_WaitHandle = new ManualResetEvent(true);
            public System.Threading.WaitHandle AsyncWaitHandle
            {
                get { return m_WaitHandle; }
            }
     
            public bool CompletedSynchronously
            {
                get { return true; }
            }
     
            public bool IsCompleted
            {
                get { return true; }
            }
     
            #endregion
        }
    }

Then in my mock service implementation I use it like this:

    using System;
    using System.Collections.Generic;
    using CodeCamp.Model;
     
    namespace CodeCamp.Common.Utility
    {
        public class MockMessageService : IMessageServiceAsync
        {
            #region IMessageServiceAsync Members
     
            public IAsyncResult BeginGetMessages(AsyncCallback callback, object state)
            {
                return new MockAsyncResult { AsyncState = state };
            }
     
            public System.Collections.Generic.IList<Message> EndGetMessages(IAsyncResult result)
            {
                return new List<Message> {
                    new Message { Content = "Message 1", Date = new DateTime(2009, 1, 1, 15, 02, 35) },
                    new Message { Content = "Message 2", Date = new DateTime(2009, 1, 1, 15, 08, 21) },
                    new Message { Content = "Message 3", Date = new DateTime(2009, 1, 1, 15, 11, 01) }
                };
            }
     
            public IAsyncResult BeginAddMessage(Message message, AsyncCallback callback, object state)
            {
                return new MockAsyncResult { AsyncState = state };
            }
     
            public void EndAddMessage(IAsyncResult result)
            {
                return;
            }
     
            #endregion
        }
    }

This also makes it easier to support design-time databinding because I make sure to call my AsyncCallback directly.

#Conclusion

A lot has been covered in this last post. I wasn't able to cover as much as I would have liked because it was just getting too long. If you have questions specific to anything in this article or series I'll be happy to clarify.

We're almost to the end of our series. In my next post, the last one, I'll be looking at events using the EventAggregator and we'll be using it to provide a global error handler to recover gracefully from unhandled exceptions.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/CodeCamp.zip)
