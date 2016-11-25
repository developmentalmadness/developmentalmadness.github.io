---
layout: post
title: 'MVVM with Prism 101 – Part 5b: ServiceLocator vs Dependency Injection'
date: '2009-11-02 19:24:00'
tags:
- silverlight
- prism
- mvvm
- mvvm-with-prism-101
- service-locator
- inversion-of-control
- dependency-injection
- blend
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



Now that we've seen the View-Model in Part 5, how do we wire up the View-Model to the View? As any developer worth his salt would say, "it depends" (I'm trying to raise my worth to at least the value of salt ;) ).

#Inversion of Control

First, let me define a few things. First, Inversion of Control is a pattern wherein creation of objects is delegated in an effort to simplify instantiation and/or defer it until runtime. Huh? Inversion of Control is a means of programming against interfaces. Your classes reference interfaces at design-time and then delegate the creation of the concrete classes to a single component or service. The result is you now have a only a single dependency – the "Container" – instead of a complex hierarchy of dependencies:

    public class ServiceA() {
        public ServiceA(){ //... }
    }
    public class ServiceB() {
        public ServiceB(ServiceA, ServiceD){ //... }
    }
    public class ServiceC(ServiceA) {
        public ServiceC(){ //... }
    }
    public class ServiceD(ServiceA) {
        public ServiceD(){ //... }
    }
     
    public class Consumer {
        private ServiceB m_ServiceB;
        private ServiceC m_ServiceC;
        
        public Consumer() {
                ServiceA serviceA = new ServiceA();
                ServiceD serviceD = new ServiceD(serviceA);
                
                m_ServiceB = new ServiceB(serviceA, serviceD);
                m_ServiceC = new ServiceC(serviceA);
        }
    }

The example above is not uncommon. Not only is it difficult to test, but if any of the classes require a change in constructor parameters or you want to change which service you're referencing you've got to clean up every consumer class which uses the service you just changed. We're looking at a high level of complexity and a very brittle implementation.

Most often Inversion of Control uses an object called a "Container" which is responsible for building these dependency hierarchies. The Container allows you to defer the creation of concrete classes until runtime. At some point before your class is instantiated, the Container is configured – most often either in your startup process or in a config file – with the mappings between your interfaces and the concrete implementations of your classes. Then when you need to get a reference to the concrete implementation of an interface or just create a new instance of a standard class you use the Container to wire everything up. For example, given the example above you can do either of the following:

    ServiceB m_ServiceB = Container.Resolve<ServiceB>();    // Create a new instance of a concrete class
    ISomeInterface m_SomeObject = Container.Resolve<ISomeInterface>(); // get a concrete instance of an interface

The first example may have you saying why use Container.Resolve<ServiceB>() instead of new ServiceB()? Well, given the definitions above, you'd actually need to do this:

    ServiceA serviceA = new ServiceA;
    ServiceD serviceD = new ServiceD;
    ServiceB m_ServiceB = new ServiceB(serviceA, serviceD);

Using the Container is much cleaner. As for line 2, you really see the power of IoC where your code isn't tied to any concrete implementation at all. This makes testing very simple and your code becomes very, very flexible.

#Dependency Injection

Here's a term around which there can be much confusion. It seems at times that it is synonymous with Inversion of Control (IoC), a term I have used some here in this series. It is true you don't often see one without the other, but they are not the same.

Dependency Injection refers explicitly to the way you use IoC. Constructor Injection is the form of Dependency Injection you will see used in Prism. Other forms of Dependency Injection are Setter Injection and Interface Injection. I really don't use these and so instead of floundering for when and how to use them I'll refer you to Martin Fowler for more on these alternative forms of Dependency Injection.

    public class ServiceA() : InterfaceA {
        public ServiceA(){ //... }
    }
    public class ServiceB() : InterfaceB {
        public ServiceB(InterfaceA, InterfaceD){ //... }
    }
    public class ServiceC(InterfaceA) : InterfaceC {
        public ServiceC(){ //... }
    }
    public class ServiceD(InterfaceA) : InterfaceD {
        public ServiceD(){ //... }
    }
     
    public class Consumer {
        private InterfaceB m_ServiceB;
        private InterfaceC m_ServiceC;
        
        public Consumer(InterfaceB, InterfaceC) {
                m_ServiceB = InterfaceB;
                m_ServiceC = InterfaceC;
        }
    }

In this last example all the services implement interfaces and our consumer then accepts those interfaces as arguments to the constructor. In order to call Container.Resolve<Consumer>() we need to register our services with the container. You can do this either in your Bootstrapper or an IModule implementation like this:

    Container.RegisterType<InterfaceA, ServiceA>();
    Container.RegisterType<InterfaceB, ServiceB>();
    Container.RegisterType<InterfaceC, ServiceC>();
    Container.RegisterType<InterfaceD, ServiceD>();

Now you can create an instance of the Consumer class anywhere in your application with a single line of code. Also, when you test Consumer you can replace the actual implementation of the services with mock versions which allow you to test Consumer in isolation.

#Dependency Injection with Prism

So how do we use Dependency Injection in a Prism application? It's easy, here's how:

EditorView.xaml.cs (code behind)

    using System.Windows.Controls;
    using CodeCamp.Common.ViewModel;
     
    namespace CodeCamp.Editor
    {
        public partial class EditorView : UserControl
        {
            public EditorView(EditorViewModel model)
            {
                InitializeComponent();
     
                this.DataContext = model;
            }
        }
    }

EditorModule.cs

    using CodeCamp.Common.ViewModel;
    using Microsoft.Practices.Composite.Modularity;
    using Microsoft.Practices.Composite.Regions;
    using Microsoft.Practices.Unity;
     
    namespace CodeCamp.Editor
    {
        public class EditorModule : IModule
        {
            private IRegionManager m_Manager;
     
            public EditorModule(IRegionManager manager)
            {
                m_Manager = manager;
            }
     
            #region IModule Members
     
            public void Initialize()
            {
                m_Manager.RegisterViewWithRegion("MainRegion", typeof(EditorView));
            }
     
            #endregion
        }
    }

You should recognize the code in EditorModule.cs from part 4 of this series. Here we're not doing anything but telling Prism to load EditorView into the MainRegion region of our Shell. From there Prism takes over by using the Unity IoC Container to create an instance of our EditorViewModel class and pass it to the EditorView constructor during the build process. Then the EditorView class takes the reference to EditorViewModel and sets it as the DataContext for the View. From there all we need to do is declare our bindings in Xaml:

EditorView.xaml

    <UserControl x:Class="CodeCamp.Editor.EditorView"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        xmlns:cmd="clr-namespace:Microsoft.Practices.Composite.Presentation.Commands;assembly=Microsoft.Practices.Composite.Presentation"
        xmlns:controls="clr-namespace:CodeCamp.Common.Controls;assembly=CodeCamp.Common"
        Width="400" Height="25">
     
        <StackPanel Orientation="Horizontal">
            <StackPanel x:Name="LayoutRoot" Background="White" Orientation="Horizontal" DataContext="{Binding Path=CurrentMessage}">
                <TextBlock>Message:</TextBlock>
                <TextBox Width="200" Text="{Binding Path=Content, Mode=TwoWay}" VerticalAlignment="Top" />
                <controls:ErrorStatus PropertyName="Content" />
            </StackPanel>
            <Button Content="Send" VerticalAlignment="Top" Width="100" 
                    cmd:Click.Command="{Binding SendMessage}" 
                    cmd:Click.CommandParameter="{Binding Path=CurrentMessage.Content}" />
        </StackPanel>
    </UserControl>

Nothing to it. You could refactor an interface from EditorViewModel. For me, sometimes I do sometimes I don't. There isn't a need for it, since if you're able to keep your View clear of any logic then there isn't anything to test. If there's nothing to test then, in the case of the View there is no need to ever substitute a mock of EditorViewModel for the real thing. In our sample application I use interfaces because it demonstrates the principal of registering types and allowing the IoC Container to resolve those types at runtime, but unless there is a reason you need to be able to substitute concrete objects and mock objects you can keep it simple here.

#ServiceLocator

With ServiceLocator you can remove the dependency on the Container. ServiceLocator is a static class with properties which expose your service interfaces. Your ServiceLocator becomes your dependency. It knows about which concrete classes map to which interfaces. When you get the value of a property ServiceLocator will return the concrete implementation:

 
    public class ServiceLocator {
        public static InterfaceA { 
            get{ return new ServiceA(); }
        }
        
        public static InterfaceB {
            get{ 
                return new ServiceB(
                    ServiceLocator.InterfaceA,
                    ServiceLocator.InterfaceD
                );
            }
        }
        
        public static InterfaceC {
            get{
                return new ServiceC(
                    ServiceLocator.InterfaceA
                );
            }
        }
     
        public static InterfaceD {
            get{
                return new ServiceC(
                    ServiceLocator.InterfaceA
                );
            }
        }
    }

You get the same benefits of Dependency Injection, without the dependence on the Container.

In my view Dependency Injection requires less work. With ServiceLocator you need to write the class, then you will also need to maintain a separate version of that class that returns mock objects for testing purposes. For that reason, I prefer Dependency Injection over ServiceLocator. So why bother bringing it up then?

#Design-Time Databinding

ServiceLocator is great for providing sample data which can be used during design-time to allow you to be more productive. Without it you will more often than not spend a lot of time in the modify-build-run-modify cycle where every change or tweak you make requires you to run the application to see what it actually looks like. However, Blend (and now the upcoming VS 2010) has a designer which gives you a view of what your view will actually look like without running it. Blend 3 has a sample data feature which allows you to bind to a sample data source when you're designing your view, but this requires you to maintain sample data for test scenarios as well as for the designer. Using a ServiceLocator to provide a reference to your View-Model which has been provided with mock data means you are designing your view using data that will pass through your actual View-Model. This means your design-time experience is realistic and you can have a single source of mock data that can be used for both testing and designing. 

In the sample project I am using along with this series HistoryView uses this technique.

HistoryViewModel.cs (ctor)

    public HistoryViewModel(IMessageServiceAsync messageService)
    {
        // store parameters as local member variables
    }

MockMessageService.cs

    using System;
    using System.Collections.Generic;
    using CodeCamp.Model;
     
    namespace CodeCamp.Common.Utility
    {
        public class MockMessageService : IMessageServiceAsync
        {
            #region IMessageServiceAsync Members
     
            public IAsyncResult BeginGetMessages(AsyncCallback callback, 
                object state)
            {
                return new MockAsyncResult { AsyncState = state };
            }
     
            public IList<Message> EndGetMessages(IAsyncResult result)
            {
                return new List<Message> {
                    new Message { Content = "Message 1", 
                        Date = new DateTime(2009, 1, 1, 15, 02, 35) },
                    new Message { Content = "Message 2", 
                        Date = new DateTime(2009, 1, 1, 15, 08, 21) },
                    new Message { Content = "Message 3", 
                        Date = new DateTime(2009, 1, 1, 15, 11, 01) }
                };
            }
     
            public IAsyncResult BeginAddMessage(Message message, 
                AsyncCallback callback, object state)
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

ServiceLocator.cs

    using System;
    using System.Diagnostics;
    using CodeCamp.Common;
    using CodeCamp.Common.Utility;
    using CodeCamp.Common.ViewModel;
    using Microsoft.Practices.Composite.Events;
    using Microsoft.Practices.Unity;
    using CodeCamp.Model;
    using CodeCamp.Common.Services;
     
    namespace CodeCamp.History
    {
        public class ServiceLocator
        {
            private static IUnityContainer BuildDesignTimeContainer()
            {
                IUnityContainer container = new UnityContainer();
     
                // register view models
                container.RegisterType<IMessageServiceAsync, MockMessageService>();
     
                return container;
            }
     
            private static IUnityContainer _container;
            public static IUnityContainer Container
            {
                get
                {
                    if (_container == null)
                    {
                        // setup container
                        _container = BuildDesignTimeContainer();
                    }
     
                    return _container;
                }
                set
                {
                    _container = value;
                }
            }
     
            #region ViewModels
     
            public static HistoryViewModel  HistoryViewModel
            {
                get
                {
                    try
                    {
                        return Container.Resolve<HistoryViewModel >();
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine(ex.Message);
                        return null;
                    }
                }
            }
     
            #endregion
        }
     
                    
    }

HistoryView.xaml

    <UserControl x:Class="CodeCamp.History.HistoryView"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        xmlns:History="clr-namespace:CodeCamp.History"
        xmlns:Common="clr-namespace:CodeCamp.Common;assembly=CodeCamp.Common"
        Width="400" Height="300">
        <UserControl.Resources>
            <History:ServiceLocator x:Key="HistoryService" />
            <Common:DateFormatConverter x:Key="DateFormatter" />
        </UserControl.Resources>
        <ScrollViewer DataContext="{Binding Source={StaticResource HistoryService}, 
                                        Path=HistoryViewModel}">
            <ListBox ItemsSource="{Binding History}">
                <ListBox.ItemTemplate>
                    <DataTemplate>
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="100" />
                                <ColumnDefinition />
                            </Grid.ColumnDefinitions>
                            <TextBlock Grid.Column="0" 
                                       FontWeight="Bold" 
                                       Foreground="Green" 
                                       Text="{Binding Date, 
                                        Converter={StaticResource DateFormatter}, 
                                        ConverterParameter=H:mm:ss tt}" />
                            <TextBlock Grid.Column="1" 
                                       Text="{Binding Content}" />
                        </Grid>
                    </DataTemplate>
                </ListBox.ItemTemplate>
            </ListBox>
        </ScrollViewer>
    </UserControl>

Going backwards, notice that the ScrollViewer in HistoryView.xaml binds to the HistoryViewModel property from a static resource (defined in our UserControl) named HistoryService which is our ServiceLocator. The ServiceLocator class resolves HistoryViewModel using the Unity IoC container (I'll explain why in a second) which injects a MockMessageService object into the HistoryViewModel object it returns to the HistoryView.

First, the reason this works is because the Xaml designer can use ServiceLocator's static properties. The ServiceLocator class doesn't need to be instantiated and so the designer is able to get the sample data and use it to render the view as it would be seen at runtime with live data.

![](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2009/11_02/DesignTimeDatabinding.jpg)

Second, the reason I'm using an IoC Container when I said ServiceLocator doesn't need it is because what this allows me to do is set the ServiceLocator.Container property at runtime from the Bootstrapper or duing IModule.Initialize. So at design-time I get a Container with mock objects from the ServiceLocator.BuildDesignTimeContainer method and at runtime I get my container with my real concrete objects and production services without having to change anything. So while ServiceLocator is a little more work, when you need design-time data it is worth the effort.

One last important thing to note with ServiceLocator, you will want to create it in the same project where your View(s) is (are) located. The reason for this is you don't want to have to create references between different Modules because you want your Modules to be completely independent of one another. Because of this the best way to maintain this clean separation is to have a single ServiceLocator in each project where it is needed. Your mock classes can be located in your Common project and you should have everything you need without creating unnecessary dependencies between Modules.

#Conclusion

We've covered quite a bit of ground at this point in our series. This last post should help you understand how to wire up your View to your View-Model. If you're wondering when you'd want to use which technique, or thinking why you wouldn't want design-time data binding (I know I asked that one when I first discovered this technique) I'll tell you what I do. If your View requires you to build your project, run it and navigate to the view to see how it looks with a larger font size then you'll be more productive with ServiceLocator. If you know your View will look the same in the designer as it does at runtime, then save yourself some effort and just use Dependency Injection.

Next I'll be tackling Commands and along with Commands we'll be looking at the best way to create a Web Service Client for your application.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/CodeCamp.zip)
