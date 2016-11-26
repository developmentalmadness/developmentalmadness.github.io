---
layout: post
title: 'MVVM with Prism 101 - Part 3: Regions'
date: '2009-10-14 12:32:00'
tags:
- silverlight
- prism
- mvvm
- regions
---

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Regions.zip)

* [Part 1: The Bootstrapper](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/)
* [Part 2: The Shell](/2009/10/12/mvvm-with-prism-101-ndash-part-2-the-shell/)
* [Part 3: Regions](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/)
 * [Part 3b: View Injection and The Controller Pattern](/2009/10/15/mvvm-with-prism-101-ndash-part-3b-view-injection-and/)
* [Part 4: Modules](/2009/10/23/mvvm-with-prism-101-ndash-part-4-modules/)
* [Part 5: The View-Model](2009/10/28/mvvm-with-prism-101-ndash-part-4-modules/)
 * [Part 5b: ServiceLocator vs Dependency Injection](/2009/11/02/mvvm-with-prism-101-ndash-part-5b-servicelocator-vs-depdency/)
* [Part 6: Commands](/2009/11/04/mvvm-with-prism-101-ndash-part-6-commands/)
 * [Part 6b: Wrapping IClientChannel](/2010/03/08/mvvm-with-prism-101-ndash-part-6b-wrapping-iclientchannel/)


This is the third post in a series of articles about implementing the Model-View-View-Model (MVVM) architectural pattern for Silverlight/WPF. The bulk of the series describes the implementation details when using the Composite Application Library (Prism) Framework. For some background on MVVM as well as a discussion on the Bootstrapper concept see part 1. For more about the Shell concept I'll be referencing in this article, see part 2.

#Regions

Within the Prism Framework, Regions are analogous to the ContentPlaceHolder control used in an ASP.NET MasterPage. However a Region is not a control, it is applied to a control via the RegionName attached property - like this:

    <ContentControl Regions:RegionManager.RegionName="Region1" />

I wanted to provide a graphic here, but since I lack any artistic talent and my skills with Visio are similarly stunted I have "borrowed" a graphic from the Prism documentation and hope they don't mind:

![](http://dvm-public-assets.s3.amazonaws.com/images/2009/10_14/UICompDCFig2-Layout.png)

As demonstrated in this image, the shell has a number (in this case 2) of regions defined which indicate areas of the UI where a view may appear. Each region is explicitly named and generally defines the type of content which will appear in the region. This allows the layout of the UI to evolve over time while each view is unaffected because it is isolated from the details where it appears on the surface.

Regions can be applied to any control which inherits from ContentControl, ItemsControl or Selector and in the case of Silverlight there is additionally explicit support for the Tab control since it doesn't inherit from ItemsControl like it does in WPF. Depending upon the control you use to define your region the views hosted within will behave differently. For example, the ContentControl will only display one view at a time - whichever is the active view. This allows you to create a navigation view (like above) using a Selector. The SelectedItem can be used to determine which view is hosted within the ContentControl. Or another option providing similar results could be to use a Tab control instead. The tabs will provide your navigation and the active tab will determine which view to display without any coding on your part.

If you wanted to display multiple instances of the same (or similar) views at the same time you could take advantage of an ItemsControl, like you would use a DataTemplate, except that each view can have its own View-Model.

Now that we understand what a region is I want to look at how to use them. The whole point of regions is to host views and a view can be any Object. There is no requirement that the view implement any interfaces or abstract classes, but I would recommend sticking to classes which inherit from DependencyObject. That said, there are two methods used to add your view object to a region: View Discovery and View Injection.

#View Discovery

View Discovery is a passive means of adding a view. You simply register either the view's type or a delegate which returns your view with the RegionManager which can be obtained via Dependency Injection or directly from your IoC container after Bootstrapper has run. When your views are mostly static or you have a default view which will to be displayed when your Shell loads then this is often the method you will use to load your views.

By type:

    IRegionManager regionManager = Container.Resolve<IRegionManager>();
    regionManager.RegisterViewWithRegion("MainRegion", typeof(MyView));

Or using a delegate:

    IRegionManager regionManager = Container.Resolve<IRegionManager>();
    regionManager.RegisterViewWithRegion("MainRegion", () => Container.Resolve<IMyView>());

By default, your view will be displayed auto-magically once your region is created. View Discovery works well with a Tab control for navigation and because with Xaml you can do almost anything you like with the UI your Tab control doesn't have to look like tabs. The Reference Implementation (RI) in the Prism Framework samples uses a tab control for navigation - it looks nice and doesn't look at all like tabs. If you don't require much control for your navigation then stick with View Discovery as your method. This is the method you'll see used throughout this series in the source code and code snippets.

#View Injection

View Injection gives you more control by allowing you to programmatically add/remove and activate the views in a region. This technique can be valuable for master/detail scenarios as well as for navigation controls. 

    string viewName = employeeId.ToString(CultureInfo.InvariantCulture);
    IRegion detailsRegion = regionManager.Regions["DetailsRegion"];
    object view = detailsRegion.GetView(viewName);
     
    if(view == null)
    {
        view = Container.Resolve<IEmployeeView>();
        detailsRegion.Add(view, viewName);
    }
     
    detailsRegion.Activate(view);

In the above snippet, assuming you already have references to your IoC container (line 7) and IRegionManager instance (line 2) then you'll need to resolve references to your view (line 3 or 7) and the region where you'll be injecting the view (line 3). Then after you add the view to the region (line 3) you activate the view.

#The Controller Pattern

If you plan on using View Injection then I would recommend looking at the Controller pattern as a way of managing the views in the targeted region. There is a View Injection Quick Start included with the Prism Framework samples and source code which would be a valuable guide to doing this right. Otherwise, if you don't mind waiting until my next post, I'll go into a bit of a breakout on the Controller pattern and how it is used with View Injection.

#Conclusion

We're getting closer to the meat of this series where we'll be getting into topics where we can finally do something besides print "Hello World" messages that are hard-coded into our Xaml. My next post will be a breakout on the Controller pattern and View Injection before I move on to Modules.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/Regions.zip)
