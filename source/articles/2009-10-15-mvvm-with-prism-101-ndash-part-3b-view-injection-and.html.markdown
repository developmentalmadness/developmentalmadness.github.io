---
layout: post
title: 'MVVM with Prism 101 - Part 3b: View Injection and the Controller Pattern'
date: '2009-10-15 12:37:00'
tags:
- silverlight
- prism
- mvvm
- regions
- mvvm-with-prism-101
- controller
---


* [Part 1: The Bootstrapper](/2009/10/03/mvvm-with-prism-101-ndash-part-1-the-bootstrapper/)
* [Part 2: The Shell](/2009/10/12/mvvm-with-prism-101-ndash-part-2-the-shell/)
* [Part 3: Regions](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/)
 * [Part 3b: View Injection and The Controller Pattern](/2009/10/15/mvvm-with-prism-101-ndash-part-3b-view-injection-and/)
* [Part 4: Modules](/2009/10/23/mvvm-with-prism-101-ndash-part-4-modules/)
* [Part 5: The View-Model](2009/10/28/mvvm-with-prism-101-ndash-part-4-modules/)
 * [Part 5b: ServiceLocator vs Dependency Injection](/2009/11/02/mvvm-with-prism-101-ndash-part-5b-servicelocator-vs-depdency/)
* [Part 6: Commands](/2009/11/04/mvvm-with-prism-101-ndash-part-6-commands/)
 * [Part 6b: Wrapping IClientChannel](/2010/03/08/mvvm-with-prism-101-ndash-part-6b-wrapping-iclientchannel/)


In my [last post](/2009/10/14/mvvm-and-prism-101-ndash-part-3-regions/) I addressed regions in the Composite Application Library for WPF/Silverlight (Prism). I looked at what they were and how they were used. But by the end of the post I felt that the concept of View Injection needed further attention. I've almost exclusively used View Discovery up to this point in my development. But when I've run into a need to use View Injection I'm uncomfortable with what seems to be a tightly coupled relationship.


View Injection is used to provide programmatic control over how and where a view is created and activated. Which means that often we use View Injection in response to some sort of event, most likely user-driven. I haven't gotten this far in the discussion of the MVVM pattern, but I hope you'll bear with me for a brief moment. When developing an application using the MVVM pattern your goal is to use Commands to communicate between the View and the View-Model. When you do this, and need to create another MVVM triad ("triad" - because of the 3 objects Model, View and View-Model) then your View-Model is coupled not only to the creation and activation of the triad, but to the region where it will be displayed. Here's an example of the code required for the View Injection method:

    string viewName = employeeId.ToString(CultureInfo.InvariantCulture);
    IRegion detailsRegion = regionManager.Regions["DetailsRegion"];
    object view = detailsRegion.GetView(viewName);
     
    if(view == null)
    {
        view = Container.Resolve<IEmployeeView>();
        detailsRegion.Add(view, viewName);
    }
      
    detailsRegion.Activate(view);

The problem with this is that our View-Model now knows too much about the other view (type, region name, and model). Additionally, if logic is required to remove the view from the region then that also becomes the responsibility of our View-Model. This then violates the principal of single responsibility.

#Controller Pattern

I've kinda stepped in *it* at this point. I didn't really have a name for the pattern at use other than the name used by the Prism team in their QuickStart. When I went around to look for a good definition of Controller which matched with how it was used I didn't find one. Turns out I was just blindly following the examples in the Prism Guidance. After searching around a bit, it turns out no one has actually formalized this pattern in the context of Silverlight/WPF. That's not to say I or the Prism team are inventing anything new here. Just that I don't have a formalized pattern to discuss here, nor to I have documentation or collective community behind me.

What I do have though, are a couple of good blog posts by Ward Bell discussing a pattern for which he is still looking for a good name. For now, he's calling it ScreenFactory. I'm not one to get into big discussions on what to name things. In fact for me, if it takes me more than a couple minutes to come up with a proper name for a class or pattern, I punt. I'll either name it AClassThatDoesSomethingIWantItToDo (thanks to intellisense this unwieldy name is not a big deal) or more often than not I'll come up with something that is good enough and then add comments and remarks to explain my intent clearly.

Here are the posts by [Ward Bell](http://neverindoubtnet.blogspot.com), I recommend reading them as it's a good to help understand what the goal here is. In my view the Controller pattern in the Prism QuickStarts is very close if not exactly the same thing as Bell's ScreenFactory:

* http://neverindoubtnet.blogspot.com/2009/05/birth-and-death-of-m-v-vm-triads.html
* http://neverindoubtnet.blogspot.com/2009/06/screen-factory.html (specifically, the sidebar at the end "Coordinated Collaborating Views")

The basic idea here is that part of the goal of the View-Model is to create a class which is completely independent of the UI. No references at all in the View-Model to any UI classes. For me, I try to stick pretty close to the rule and when there are exceptions (FileDialog for example) I first look to the view's code behind.

That said, while we aren't actually referencing any UI classes, View Injection deals with the concept of opening/closing and activating/deactivating views. The less your View-Model knows about any view, including the one it represents the better because you have the greater chance of reuse without complication when you abide by this principle.

#The Point

So the controller here is responsible for the life-cycle of the related views. It creates a view (if it doesn't already exist) and activates it. In the example here there is no addressing of closing and cleanup of the view. However, that also would be the responsibility of the controller.

Forgive me for jumping so far ahead, but I don't want to gloss over anything important. As I was writing my last post I felt uncomfortable with presenting the concept of View Injection without properly looking at how to use it. For me it's like demonstrating an SQL snippet that is open to an injection attack. I'm far from perfect in many areas, but when I can I try to show how to do things properly instead of promulgating bad practices.

Back to View Injection...

#View Injection

Instead of coming up with a contrived example of using View Injection I thought I'd use the Prism team's contrived example ([their words](http://compositewpf.codeplex.com/Thread/View.aspx?ThreadId=50763), not mine ;) ). Actually, I don't think it's so bad. I think it's a pretty good example of decoupling the responsibility over a related from a View-Model. I'm referring to the View Injection QuickStart in the Prism Guidance samples. If you'd like to follow along, you can [download it from MSDN](http://www.microsoft.com/downloads/details.aspx?FamilyID=fa07e1ce-ca3f-4b9b-a21b-e3fa10d013dd&DisplayLang=en). Just download the .exe package and run the installer. Make note of where it installs the Guidance and run the batch file to start up the View Injection QuickStart.

If you are following along, then once you've opened the QuickStart, open the UIComposition.Modules.Employee.XXX project and under Views\EmployeesView\EmployeesPresenter.cs and Controllers\EmployeesController.cs. For the rest of you here's the source code:

    public interface IEmployeesController
    {
        void OnEmployeeSelected(BusinessEntities.Employee employee);
    }
     
    public class EmployeesPresenter
    {
        private IEmployeesListPresenter listPresenter;
        private IEmployeesController employeeController;
     
        public EmployeesPresenter(
            IEmployeesView view,
            IEmployeesListPresenter listPresenter,
            IEmployeesController employeeController)
        {
            this.View = view;
            this.listPresenter = listPresenter;
            this.listPresenter.EmployeeSelected += new EventHandler<DataEventArgs<BusinessEntities.Employee>>(this.OnEmployeeSelected);
            this.employeeController = employeeController;
     
            View.SetHeader(listPresenter.View);
        }
     
        public IEmployeesView View { get; set; }
     
        private void OnEmployeeSelected(object sender, DataEventArgs<BusinessEntities.Employee> e)
        {
            employeeController.OnEmployeeSelected(e.Value);
        }
    }
     
    public class EmployeesController : IEmployeesController
    {
        private IUnityContainer container;
        private IRegionManager regionManager;
     
        public EmployeesController(IUnityContainer container, IRegionManager regionManager)
        {
            this.container = container;
            this.regionManager = regionManager;
        }
     
        public virtual void OnEmployeeSelected(BusinessEntities.Employee employee)
        {
            IRegion detailsRegion = regionManager.Regions[RegionNames.DetailsRegion];
            object existingView = detailsRegion.GetView(employee.EmployeeId.ToString(CultureInfo.InvariantCulture));
     
            if (existingView == null)
            {
                IProjectsListPresenter projectsListPresenter = this.container.Resolve<IProjectsListPresenter>();
                projectsListPresenter.SetProjects(employee.EmployeeId);
     
                IEmployeesDetailsPresenter detailsPresenter = this.container.Resolve<IEmployeesDetailsPresenter>();
                detailsPresenter.SetSelectedEmployee(employee);
     
                IRegionManager detailsRegionManager = detailsRegion.Add(detailsPresenter.View, employee.EmployeeId.ToString(CultureInfo.InvariantCulture), true);
                IRegion region = detailsRegionManager.Regions[RegionNames.TabRegion];
                region.Add(projectsListPresenter.View, "CurrentProjectsView");
                detailsRegion.Activate(detailsPresenter.View);
            }
            else
            {
                detailsRegion.Activate(existingView);
            }
        }
    }

What we're seeing here is our View-Model (EmployeesPresenter) receives an instance of a Controller (IEmployeesController) and IEmployeesListPresenter.

I know what you're thinking, "didn't you just say the less the View-Model knows about other View-Models the better?". Yes I did, but I didn't write this code and I would do it differently but this post is already further down the road than I'd like for what we've covered so far in this series. I will just say that a better (although slightly more complicated) solution would be to use Aggregate Events since EmployeesPresenter doesn't need to know anything about IEmployeesListPresenter - it just needs to know when the selected employee has changed. For now, my assumption is that the Prism team didn't want to muddy the waters here but wanted to keep things familiar and thus easier to understand.

The important piece here is that we're subscribing to an event that exposes the selected employee for us. Then just forwarding it to our controller - we just fire and forget because what the controller does with it at this point is up to the controller and we get nice clean separation.

What the controller *does* do here should look familiar. Below are some screenshots of the application running in Silverlight and WPF. You'll notice that there is a "Select Employee" list at the top of the page and the employee details are shown below in a Tab control. The Tab control comprises multiple views: employee details and project lists. So when the Controller's OnEmployeeSelected method is called in response to the EmployeeSelected event the controller first looks to see if the view has already been created. If not, it builds the MVVM triads required (Details and ProjectsList), injects each view into the appropriate region and activates the view.

![](http://dvm-public-assets.s3.amazonaws.com/images/2009/10_15/mvvm-with-prism-101-part3b-imageA.png) 
![](http://dvm-public-assets.s3.amazonaws.com/images/2009/10_15/mvvm-with-prism-101-part3b-imageB.png)

Honestly, for the longest time I simply accepted the coupling of views in this situation as "technical debt" and I didn't really understand what the Prism team was doing with these Controller classes and interfaces in the QuickStarts. And it seems like I'm not alone. As I was researching for the series I found a dearth of information on the topic. In fact when I googled  the topic today my post from yesterday was in the top 10 results. So I hope that this clears things up for those with questions about how to properly use View Injection as well as those like me who looked at the controllers and said, "what?".

