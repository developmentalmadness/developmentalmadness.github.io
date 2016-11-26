---
layout: post
title: 'MVVM with Prism 101 – Part 5: View-Model'
date: '2009-10-28 23:06:00'
tags:
- silverlight
- prism
- mvvm
- mvvm-with-prism-101
- view-model
---

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/ViewModel.zip)

* [Part 1: The Bootstrapper](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/)
* [Part 2: The Shell](/2009/10/12/mvvm-with-prism-101-ndash-part-2-the-shell/)
* [Part 3: Regions](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/)
 * [Part 3b: View Injection and The Controller Pattern](/2009/10/15/mvvm-with-prism-101-ndash-part-3b-view-injection-and/)
* [Part 4: Modules](/2009/10/23/mvvm-with-prism-101-ndash-part-4-modules/)
* [Part 5: The View-Model](2009/10/28/mvvm-with-prism-101-ndash-part-4-modules/)
 * [Part 5b: ServiceLocator vs Dependency Injection](/2009/11/02/mvvm-with-prism-101-ndash-part-5b-servicelocator-vs-depdency/)
* [Part 6: Commands](/2009/11/04/mvvm-with-prism-101-ndash-part-6-commands/)
 * [Part 6b: Wrapping IClientChannel](/2010/03/08/mvvm-with-prism-101-ndash-part-6b-wrapping-iclientchannel/)


Alright, so we’re finally here. I could have started with this one, but where’s the fun in that. I wanted to go through the series introducing concepts in the order you would create objects if you where building a solution. Obviously you don’t have to go in the same order. If you were writing unit tests you can start anywhere you like. But until all the previous pieces we’ve discussed where in place you couldn’t actually run the solution and debug it in the browser.

#The Problem
Before we introduce the pattern, it is important to understand the problem domain so we can understand why we need the solution.

In modern UI development, whether we’re talking desktop, web client or RIA model state is stored in the user interface. We have widgets which are used to display data, allow users to edit the data and store the changes until the user indicates the changes should be persisted back to the store. Here’s an example in Xaml:

    <TextBox x:Name="MyTextBox" />

Regardless of where the original binding takes place – at some parent level or on the control itself – at some point we do something like this:

    MyTextBox.Text = MyClass.PropertyValue;

The state of MyClass.PropertyValue is now stored in the TextBox. Xaml solves part of this problem because usually what you are doing is something more like this:

    MyStackPanel.DataContext = MyClass;

But you are still directly referencing the UI. Both situations have problems. The first situation requires us to read the value of MyTextBox.Text before we can do anything with it:

    MyClass.PropertyValue = MyTextBox.Text;

And if our property is not a string value, then we’re required to call some version of Parse() or TryParse(). And it becomes increasingly burdensome the more controls we have. But even if we can use the magic of Xaml databinding as in the example of the StackPanel.DataContext above, we’re still locked into our UI. Our View becomes brittle because it is subject to changes in the UI which can break the View. We must maintain some object named MyTextBox or MyStackPanel and the situation becomes worse as we add in event handlers and other references to the UI.
#View-Model: The Concept
In 2005, John Gossman introduced the concept of View-Model as part of a pattern called Model-View-View-Model (MVVM). View-Model is very similar (some have argued that there is really no difference) to Fowler’s Presentation Model. While the differences may be few it’s still not a bad idea to look at them both to understand why a new pattern name was created.

Fowler’s definition of Presentation Model is this:

> The essence of a Presentation Model is of a fully self-contained class that represents all the data and behavior of the UI window, but without any of the controls used to render that UI on the screen. A view then simply projects the state of the presentation model onto the glass.

Gossman’s definition is a little less specific:

> Given a Model consisting of a CLR class, XML schema, Web Service or relational data, create a View using XAML that contains the actual controls, styles and templates of the UI, a class or set of classes that abstract the state of the view (ViewState), define ValueConverters for Model types that do not map easily to the UI and Commands for operations on the Model or ViewState.  Then use Avalon's data binding functionality to declaratively (in the XAML) wire the View to the ViewState and/or directly to the Model.

What it boils down is that the view model is a composite of the following:

* an abstraction of the view
* commands
* value converters
* view state

The key difference between the two is that as Fowler states "Presentation Model is…a fully self-contained class that represents all the data and behavior of the UI window” while Gossmans definition indicates any number of classes, not at all self-contained which fall into 4 categories. Gossman wrote a whole series of posts with the simple goal of trying to nail down exactly what View-Model is. But for me, his statements above are clear enough to work with.

#View-Model: In Practice
For me, the idea boils down this: “use Avalon's data binding functionality to declaratively (in the XAML) wire the View to the ViewState and/or directly to the Model”. (Remember Avalon was WPF’s codename before it was released and as you read Gossman’s posts I believe Sparkle refers to what we now know as Blend). The goal of MVVM is that nowhere in your code should you reference any UI elements. In practice this doesn’t always work. It often depends on how good you are at Xaml. I’m ok and getting better, but I’m not the first person you want to come to if you can’t figure out what’s wrong with your xaml. So sometimes in order for us xaml mortals to get something done on time we resort to using the codebehind. But the goal should be to not use codebehind at all if we can avoid it.

Here’s an example of a xaml file and its codebehind:

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

HistoryView.xaml.cs

    using System.Windows.Controls;
     
    namespace CodeCamp.History
    {
        public partial class HistoryView : UserControl
        {
            public HistoryView()
            {
                InitializeComponent();
            }
        }
    }

As you can see there is really no code-behind to speak of. In the xaml file we have a ServiceLocator to bind the View with the View-Model and a Value Converter (DateFormatConverter) for date formatting. This example doesn’t include any command but not every component of View-Model is required in every situation.

Now let’s look at the View-Model for HistoryView:

    using System;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Windows.Input;
    using CodeCamp.Common;
    using CodeCamp.Common.ViewModel;
    using CodeCamp.Model;
    using Microsoft.Practices.Composite.Events;
    using Microsoft.Practices.Composite.Presentation.Commands;
    using CodeCamp.Common.Services;
     
    namespace CodeCamp.History
    {
        public class HistoryViewModel : IHistoryViewModel
        {
            IClientChannelWrapper<IMessageServiceAsync> m_MessageService;
            IDispatcher m_Dispatcher;
     
            public HistoryViewModel(IClientChannelWrapper<IMessageServiceAsync> messageService, 
                IEventAggregator eventAggregator, IDispatcher dispatcher)
            {
                this.History = new ObservableCollection<Message>();
     
                m_MessageService = messageService;
                m_Dispatcher = dispatcher;
     
                eventAggregator.GetEvent<MessageChangedEvent>().Subscribe(MessageChanged);
     
                this.GetMessages = new DelegateCommand<Object>(this.GetMessagesExecute);
                this.GetMessages.Execute(null);
            }
     
            public ICommand GetMessages
            {
                get;
                private set;
            }
     
            /// <summary>
            /// 
            /// </summary>
            /// <remarks>
            /// Method must be public to allow EventAggregator to maintain a 
            /// weak reference to prevent problems with Garbage Collection
            /// This can be made private, but you must manually unsubscribe 
            /// when this is disposed of if you want to make it private.
            /// </remarks>
            /// <param name="message"></param>
            public void MessageChanged(string message)
            {
                this.GetMessages.Execute(message);
            }
     
            private void GetMessagesExecute(Object arg)
            {
                IAsyncResult result = m_MessageService.BeginInvoke(
                    m => m.BeginGetMessages(new AsyncCallback(EndGetMessages), null));
                if (result.CompletedSynchronously)
                    EndGetMessages(result);
            }
     
            private void EndGetMessages(IAsyncResult result)
            {
                IList<Message> list = m_MessageService.EndInvoke(
                    m => m.EndGetMessages(result));
     
                m_Dispatcher.BeginInvoke(() => LoadMessages(list));
            }
     
            private void LoadMessages(IList<Message> list)
            {
                this.History.Clear();
                foreach (Message item in list)
                    this.History.Add(item);
            }
     
            #region IHistoryViewModel Members
     
            public ObservableCollection<Message> History
            {
                get;
                private set;
            }
     
            #endregion
        }
    }

As you look at the code you’ll see no references to any UI elements. You will still see a command however. Commands are still useful as part of your view model even if you do not bind them to the UI. But the key takeaway here is that the View-Model 1) doesn’t reference UI elements or specialty classes (ex. Visibility enum); 2) exposes properties which follow the pattern of notification (ICommand, ObservableCollection, INotifyPropertyChanged). #1 allows our View-Model to be reused as well as easily tested. #2 allows us to easily bind our View to the View-Model using either one-way or two-way binding.

Something else you may notice is that while our View-Model *does* implement a custom interface (IHistoryViewModel) it does not implement any framework abstract class or interface. The interface it does implement is simply used as an abstraction but not really needed since the View is not intended to be the target of any unit tests and so there is no reason to provide an mock View-Model. However, if you are using View Injection and need to reference one View-Model reference another, then it is a good idea to create an interface and then use the Controller pattern I describe in my part 3 sidebar on the Controller.

#Conclusion
I still have more to discuss on View-Model, but this post is already long enough. So I’ll continue on Part 5 with a discussion of different techniques of wiring up our View and View-Model. For example, in the xaml file in this post I used ServiceLocator, which has some cool benefits but requires more work. There are trade-offs and I’ll talk about it in my next post.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/ViewModel.zip)
