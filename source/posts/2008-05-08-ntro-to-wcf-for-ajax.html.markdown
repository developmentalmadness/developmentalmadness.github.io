---
layout: post
title: Intro to WCF for Ajax
date: '2008-05-08 18:34:00'
tags:
- asp_net_ajax
- wcf
---

It's finally time to dig into what all the buzz with WCF is about. From what I hear it should perform better than WebServices, has better security and be more flexible. But I'm a bit frustrated by some of the documentation out there. So much of what I'm seeing is either glazed over too much for me to immediately apply it (blogs, articles and forums) or it's too high level to get me started quick enough to play with it. So in order to cement what I'm learning about WCF I am planning on writing a series of posts that document what I've learned and hopefully help anyone else who shares the same frustration.

Since my plan is to use WCF for an application I am currently working on I wanted to start immediately with JSON formatting. So I am going to use two different examples of how this is done; running within an ASP.NET Application and running from a console application.

#WCF Console Application

Let's start with the console application since it will be the most simple. Fire up Visual Studio 2008 and create a new console application project. Make sure your project has references to at least the following libraries:

* System - no explaination needed.
* System.Runtime.Serialization - required for defining DataContracts used for returning complex types.
* System.ServiceModel - used to define our ServiceContract and it's operations (OperationContract).
* System.ServiceModel.Web - used to configure our output as JSON and create a WebServiceHost needed to communicate over Http.

Next add a new class file to our project and add the following code to the class file:


    using System;
    using System.ServiceModel.Web;
    using System.ServiceModel;
    using System.Runtime.Serialization;
    
    namespace WcfClassLibrary
    {
        [DataContract]
        public class Greeting
        {
            [DataMember]
            public String Message;
        }
    
        [ServiceContract]
        public class HelloWorld
        {
            [OperationContract]
            [WebGet(ResponseFormat=WebMessageFormat.Json)]
            public Greeting GreetJson()
            {
                Greeting g = new Greeting();
                g.Message = "Hello World!";
    
                return g;
            }
        }
    }

The first class here is our complex type. I would have just returned a System.String for our OperationContract, but since we want to get JSON as output we'll need a complex type. Just returning a simple type will just return a string value to our client. The important thing to take away from this is that you need a class marked with the DataContract attribute and any properties you would like to expose must be public and marked with the DataMember attribute. You can think of this like marking the class as Serializable and flagging which members you want exposed. In any case the data is the only thing being sent down the wire here and so don't plan on any methods being exposed.

The second class, our ServiceContract, defines the service and the available operations. To accomplish this we just need to use the ServiceContract and OperationContract attributes to flag public methods we want exposed by the service.

Next let's go to our Main method in the class file created as part of our Console application template. Add the following to our file:

    using System;
    using System.ServiceModel.Web;
    
    namespace WcfClassLibrary
    {
        class Program
        {
            static void Main(string[] args)
            {
                Uri baseAddress = new Uri("http://localhost:8001/");
    
                using (WebServiceHost host = new WebServiceHost(typeof(HelloWorld), baseAddress))
                {
                    host.Open();
    
                    Console.WriteLine("Greeting service listing at {0}", baseAddress);
    
                    Console.WriteLine("View greeting at {0}GreetJson", baseAddress);
                    Console.WriteLine("Press [Enter] to shut down service.");
                    Console.ReadLine();
                }
            }
        }
    }

I wanted the bare basics and there you have it. New up a WebServiceHost object so we can expose our service over Http. If we were using IIS (as we will be doing below) we would not worry about creating a ServiceHost object since IIS would do that for us. We just need to specify the Uri and the type of our ServiceContract. There's no config file here because by using WebServiceHost our endpoint is created and configured for us since it didn't find one in our config file. If we had defined one it would use that, but my goal here is to present the minimum requirements to get WCF up and running. But even without a config you should be able to define whatever you need at this point by working with the properties of the WebServiceHost object.

At this point, just hit F5. When your console loads up point your web browser (or whatever you client is) at http://localhost:8001/GreetJson (or whatever you may have configured your uri as) and you should get the following in your response:

    {"Message":"Hello World!"}

This should be consumable from any JSON aware client and you're off and running.


#AJAX-enabled WCF Service


You can also create a WCF Service which runs on IIS alongside your ASP.NET web app. Just open up any Web Application project targeting the 3.5 framework and from the 'add item' dialog select an AJAX-enabled WCF service. This will add an '.svc' file to your project. Now add the following code to the '.svc.cs' file:

    using System;
    using System.Runtime.Serialization;
    using System.ServiceModel;
    using System.ServiceModel.Activation;
    using System.ServiceModel.Web;
    
    namespace Developmentalmadness.WcfWebApplication
    {
        [DataContract]
        public class Greeting
        {
            [DataMember]
            public string Message;
        }
    
        [ServiceContract]
        [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]
        public class HelloWorld
        {
            // Add [WebGet] attribute to use HTTP GET
            [WebGet(ResponseFormat=WebMessageFormat.Json)]
            [OperationContract]
            public Greeting GreetJson()
            {
       WebOperationContext.Current.OutgoingResponse.ContentType = "text/plain";
                Greeting g = new Greeting();
                g.Message = "Hello World! " + System.Web.HttpContext.Current.Request.UserHostAddress;
          
                return g;
            }
        }
    }

There are a few differences here from our last example. When you create a WCF service in a web application, by default the AspNetCompatibilityRequirements attribute is added as part of the code template. What does this do? Well it allows your service to function as part of your application like any other web page. So you get access to HttpContext, which means the intrinsic server objects (Request,Response,Server,Session). This allows you to work with authentication and other built-in mechanisms. If your service doesn't need this functionality, turn it off by first removing the attribute since the default is off. If you prefer to be explicit, then set it to 'NotAllowed'. Then you'll need to go into your config file (unless your service is 'configless' which we'll discuss in a minute) and change the aspNetCompatibilityEnabled to 'false' for the serviceHostingEnvironment element. If you don't you'll see the following exception when you try to access the service:

> **The service cannot be activated because it does not support ASP.NET compatibility. ASP.NET compatibility is enabled for this application. Turn off ASP.NET compatibility mode in the web.config or add the AspNetCompatibilityRequirements attribute to the service type with RequirementsMode setting as 'Allowed' or 'Required'.**

Once these two settings are off any code which uses intrinsic objects will still compile, but you will get a NullReferenceException when it runs. But since we have it on, you can see we are able to use System.Web.HttpContext.Current.Request to get the use's host address. If you do decide to turn it off, you still have access to a few settings such as the ContentType as you can see above through the use of WebOperationContext. We've got it here so we actually see the result in the browser instead of getting a 'Save File' dialog.

Next if you right-click the '.svc' file and select 'View Markup' you'll see something similar to this:

    <%@ ServiceHost Language="C#" Debug="true" Service="Developmentalmadness.WcfWebApplication.HelloWorld" CodeBehind="HelloWorld.svc.cs" %>

We don't need to do anything here, but if you decide to change your namespace make sure to update this file as well. One other thing you can do here is make your service 'configless' by setting the 'Factory' attribute as follows:

    Factory="System.ServiceModel.Activation.WebScriptServiceHostFactory"

There's more to this setting than just that, but since my goal here is just to get a service up and running it's out of the scope of this post for now. But suffice it to say that adding this setting means that you can just remove the system.serviceModel config section from your web.config.

Now let's look at the serviceModel section in our web.config:

     <system.serviceModel>
      <behaviors>
       <endpointBehaviors>
        <behavior name="WcfWebApplication.HelloWorldAspNetAjaxBehavior">
         <enableWebScript/>
        </behavior>
       </endpointBehaviors>
      </behaviors>
      <serviceHostingEnvironment aspNetCompatibilityEnabled="true"/>
      <services>
       <service name="Developmentalmadness.WcfWebApplication.HelloWorld">
        <endpoint address="" behaviorConfiguration="WcfWebApplication.HelloWorldAspNetAjaxBehavior"
                      binding="webHttpBinding" contract="Developmentalmadness.WcfWebApplication.HelloWorld"/>
       </service>
      </services>
     </system.serviceModel>

This will be automatically added to your web.config file for you when you first add an WCF service to your application. Just make sure you change the name of your service here as well when you rename the service. You can name your behavior element anything you like, as long as you make sure to use the same name in the behaviorConfiguration attribute for your service element. The enableWebScript element is required for ASP.NET AJAX compatibility.

Make sure that the name attribute of the service element matches the fully-qualified name of your service or you'll see this error:

> **Service 'Developmentalmadness.WcfWebApplication.HelloWorld' has zero application (non-infrastructure) endpoints. This might be because no configuration file was found for your application, or because no service element matching the service name could be found in the configuration file, or because no endpoints were defined in the service element.**

In like manner, make sure the contract attribute matches the fully-qualified name of your ServiceContract or this is what you'll see:

> **The contract name 'DevelopmentalMadness.WcfWebApplication.HelloWorldoops' could not be found in the list of contracts implemented by the service 'DevelopmentalMadness.WcfWebApplication.HelloWorld'.**

Once we've done all this, hit F5 and then point the browser at /Service1.svc/GreetJson and you should see this:

    {"d":{"__type":"Greeting:#Developmentalmadness.WcfWebApplication","Message":"Hello World! 127.0.0.1"}}

From here it's up to you to write the client-side script to make use of this output, but you now have a working service which you can use. I'm pretty happy so far with things and look forward to exploring more in depth as we build on this in future posts.
