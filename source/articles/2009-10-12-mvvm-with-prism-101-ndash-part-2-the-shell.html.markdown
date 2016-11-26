---
layout: post
title: 'MVVM with Prism 101 - Part 2: The Shell'
date: '2009-10-12 12:18:00'
tags:
- silverlight
- mvvm
- bootstrapper
- pris
---

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Bootstrapper.zip)

* [Part 1: The Bootstrapper](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/)
* [Part 2: The Shell](/2009/10/12/mvvm-with-prism-101-ndash-part-2-the-shell/)
* [Part 3: Regions](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/)
 * [Part 3b: View Injection and The Controller Pattern](/2009/10/15/mvvm-with-prism-101-ndash-part-3b-view-injection-and/)
* [Part 4: Modules](/2009/10/23/mvvm-with-prism-101-ndash-part-4-modules/)
* [Part 5: The View-Model](2009/10/28/mvvm-with-prism-101-ndash-part-4-modules/)
 * [Part 5b: ServiceLocator vs Dependency Injection](/2009/11/02/mvvm-with-prism-101-ndash-part-5b-servicelocator-vs-depdency/)
* [Part 6: Commands](/2009/11/04/mvvm-with-prism-101-ndash-part-6-commands/)
 * [Part 6b: Wrapping IClientChannel](/2010/03/08/mvvm-with-prism-101-ndash-part-6b-wrapping-iclientchannel/)


This is the second post in a series of articles about implementing the Model-View-View-Model (MVVM) architectural pattern for Silverlight/WPF. MVVM in itself is not a complex pattern, however having a framework can reduce the work required to accomplish more advanced scenarios. For example, communicating between modules in a loosely coupled way requires some sort of event framework. Prism provides this and I'll talk about it more in a future post. The framework I have been using is the Composite Application Library for Silverlight/WPF (aka Prism). The bulk of the series has to do with the intricacies of implementing MVVM within the Prism framework. If you are unfamiliar with Prism then make sure and read [Part 1](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/) before continuing.

Something I forgot to mention in the first series, the source code provided includes several supporting projects. These all contain functionality which will be used as we go through the series - for example a WCF service we will use to demonstrate abstraction of service communication. Because this is a Silverlight application, the main projects are CodeCamp.Shell and CodeCamp.Web. CodeCamp.Web is the startup project for Visual Studio and CodeCamp.Shell is the main Silverlight application. The rest are class libraries - either Silverlight Class Library (client side) or Windows Class Library (server side). I will touch on each piece of the included projects at some point in the series so everything will be explained. Hopefully (at least I don't plan on it) there won't be any "Pay no attention to the man behind the curtain" business going on.

I realize now that I am writing this post on the Shell that "Shell" is probably a poor name for the main Silverlight application project, CodeCamp.Shell - it's ambiguous. Just realize that in the context of this series the "Shell project" is the startup project for our Silverlight application. This is where the Bootstrapper is hosted as well as App.xaml and our Shell (the concept discussed in this article).

#The Shell

Within the Prism Framework, the Shell contains the visual elements that define the overall layout and style of your application. This is not actually a requirement, but it is recommended. The Shell is analogous to an ASP.NET MasterPage. Both allow you to define content regions as placeholders for the views you define. Both allow you to host common functionality such as navigation. Both allow you to define visual styles and layout which will be applied to the views which are displayed within the content regions you define.

In the context of Silverlight you will only have a single Shell. The application can define multiple versions of your shell (skins) but once your Shell has been set as the value of Application.Current.RootVisual you cannot change it. According to the documentation for Prism, WPF is more flexible in that you can define multiple shells when your application uses multiple windows, but because of [the way the Bootstrapper works](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/) (CreateShell method) it seems to me that logically you still have only one shell, any others are really just composite views.

Because it does not have a specific interface or abstract class to implement (all that the Bootstrapper requires is that your CreateShell method returns is an instance which inherits from DependencyObject) Shell is really more conceptual that anything else. If you were developing a simple application, which only involved a single view, then your Shell could be that view. In which case you would be using Prism to simply setup your IoC container and possibly provide a logging service or other similar functionality. Let's take a look at our basic Shell:

**Bootstrapper.cs**

    public class Bootstrapper : UnityBootstrapper
    {
        protected override DependencyObject CreateShell()
        {
            Shell shell = Container.Resolve<Shell>();
     
            Application.Current.RootVisual = shell;
     
            return shell;
        }
    }

**Shell.xaml**

    <UserControl x:Class="CodeCamp.Shell.Shell"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Width="400" Height="300">
        <StackPanel x:Name="LayoutRoot" Background="White">
            <TextBlock>I'm the shell.</TextBlock>
        </StackPanel>
    </UserControl>
    Shell.xaml.cs 

**(code behind)**
    
    using System.Windows.Controls;
     
    namespace CodeCamp.Shell
    {
        public partial class Shell : UserControl
        {
            public Shell()
            {
                InitializeComponent();
            }
        }
    }

You'll have all these files in a Silverlight Application Project which will load up and simply display "I'm the shell.". Boring really. If you want to see the solution and project (this is of course not a full implementation) to see how things are organized, then [download the source code)[] and have a look.

#Conclusion

So there's your basic "Hello World" example. Like I said, there's really nothing different about it than any other view you've designed before. The Shell is really just a placeholder for your visual styles and for hosting your dynamic content. It may not have even required an entire post on the topic, but I thought it was important to introduce it as the natural progression of putting together your application using Prism. Things will start to get more interesting next when we look at regions and modules.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Bootstrapper.zip)