---
layout: post
title: 'WCF: Unknown error (0xc000009a) Couldn''t get process information from performance
  counter'
date: '2008-09-25 17:44:00'
tags:
- intranet
- unknown_error
- wcf
---

I've been working with WCF in an intranet environment over the last couple weeks and have been getting some good experience which is forcing me to dig in more an more. My disclaimer is: I still only have a surface level understanding of how it works and why I want to do things a certain way. So if you see that I'm doing something wrong here please let me know so I can make the correction and prevent passing on bad code examples.

Because we are working in an intranet environment using ASP.NET our WCF endpoint binding config looks like this:


     <system.servicemodel>
            <bindings>
                <webhttpbinding>
                    <binding name="myBinding">
                        <security mode="TransportCredentialOnly">
                            <transport clientcredentialtype="Windows">
                        </security>
                    </binding>
                </webhttpbinding>
            </bindings>
        </system.serviceModel>
    

The data going back and forth is not sensitive and it is read-only, so we aren't concerned with encrypting the message. The reason for using Windows Authentication is solely to ensure that only authorized users have access to the application itself. But since we didn't want to configure the WCF service with anonymous access in IIS we chose to turn on Windows Authentication so the endpoint would be compatible with the IIS settings for the rest of the application.

The problem here is that when I try to run the application using the VS 2008 web server (Cassini) the web service doesn't respond. When I browse to the service page I get this:

    Unknown error (0xc000009a)
    Couldn't get process information from performance counter

The only way I figured this out was because the once I got an error message telling me that Windows Authentication was required (which by the way is pretty much the opposite error we get on the server when IIS has anonoymous access turned off and we haven't configured Windows Authentication for the endpoint).

If I change clientCredentialType="Windows" to clientCredentialType="None" everything works fine. So I know this is my solution. But I can be pretty scattered sometimes and it can be easy to forget to change the setting before releasing changes to an IIS environment. So I wanted to figure out how to determine which environment I was in and then use the correct clientCredentialType setting.

The solution involves creating a custom ServiceHost class. By implementing a custom ServiceHost class we can override the ApplyConfiguration method and change the ClientCredentialType when the service first loads.


    using System;
    using System.Runtime.Serialization;
    using System.ServiceModel;
    using System.ServiceModel.Activation;
    using System.ServiceModel.Web;
    using System.Configuration;
    using System.Collections.Generic;
     
    namespace MyWebApplication.Services
    {
        public class MyServiceHostFactory : ServiceHostFactory
        {
            protected override ServiceHost CreateServiceHost ( Type serviceType, Uri[] baseAddresses )
            {
                // Specify the exact URL of your web service
                MyServiceHost webServiceHost = new MyServiceHost( serviceType, baseAddresses );
                return webServiceHost;
            }
        }
     
        public class MyServiceHost : ServiceHost
        {
            public MyServiceHost ( Type serviceType, params Uri[] baseAddresses )
                : base( serviceType, baseAddresses )
            { }
     
            protected override void ApplyConfiguration ()
            {
                base.ApplyConfiguration();
     
                #if DEBUG
                    // allows testing w/ VS Cassini web server
                    ( (WebHttpBinding)this.Description.Endpoints[0].Binding ).Security.Transport.ClientCredentialType = HttpClientCredentialType.None;
                #endif
               
                return;
            }
        }
    }
    

Then modify your Service.svc file header by adding the Factory attribute as follows:


    <%@ ServiceHost Language="C#" Debug="true" Service="MyWebApplication.Services.MyService" Factory="MyWebApplication.Services.MyServiceHostFactory" CodeBehind="GALManager.svc.cs" %>
 

CONSESSION: This isn't the perfect solution, due to the fact that it only works if the DEBUG directive is defined in your build (by default if you are running using the Debug build configuration then this works) and you won't be able to release a debug build without turning off this directive. However, this should give you enough information to come up with a solution which works for your environment.

The key here is the override of the ApplyConfiguration() method in the MyServiceHost class. First we allow the base class implementation to run by calling base.ApplyConfiguration() - this way we don't have to implement these details ourselves. Then, once it is complete I change make any changes I need. In this case I get Binding property the first endpoint (in my case I only have one - so make sure this works for you) and cast it to WsHttpBinding (based on my binding config in the web.config). Then I can access the Transport property of the Security object and change the ClientCredentialType to None.

Now as long as I am using the appropriate build settings for my environment (Debug = local, Release = deployment) then my service will function properly.

Here is the complete web.config file:


    <system.servicemodel>
        <bindings>
            <webhttpbinding>
                <binding name="MyWebApplication.Services.MyBinding">
                    <security mode="TransportCredentialOnly">
                        <transport clientcredentialtype="Windows">
                    </security>
                </binding>
            </webhttpbinding>
        </bindings>
        <behaviors>
            <endpointbehaviors>
                <behavior name="MyWebApplication.Services.MyServiceAspNetAjaxBehavior">
                    <enablewebscript>
                </behavior>
            </endpointbehaviors>
            <servicebehaviors>
                <behavior name="MyWebApplication.Services.MyBehavior">
                    <servicemetadata httpgetenabled="true">
                    <!-- set this to "false" before publishing to production environment -->
                    <servicedebug includeexceptiondetailinfaults="false">
                </behavior>
            </servicebehaviors>
        </behaviors>
        <servicehostingenvironment aspnetcompatibilityenabled="false">
        <services>
            <service name="MyWebApplication.Services.MyService"
                     behaviorConfiguration="MyWebApplication.Services.MyBehavior">
                <endpoint bindingConfiguration="MyWebApplication.Services.MyBinding" address=""
                    behaviorConfiguration="MyWebApplication.Services.MyServiceAspNetAjaxBehavior"
                    binding="webHttpBinding" contract="MyWebApplication.Services.MyService" />
            </service>
        </services>
    </system.serviceModel>
