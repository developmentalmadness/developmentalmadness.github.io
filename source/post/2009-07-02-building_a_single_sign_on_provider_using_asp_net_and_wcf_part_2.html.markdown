---
layout: post
title: 'Building a Single Sign On Provider Using ASP.NET and WCF: Part 2'
date: '2009-07-02 06:00:00'
tags:
- net_framework_3_5
- forms_authentication
- wcf
---

## Using Forms Authentication with WCF

This is the second article in a four part series on building a single sign on () provider using the platform. If you just want to know about forms authentication and and aren’t interested in implementing SSO read ahead. Otherwise, make sure to check out (, , and the [source](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/SSO.zip)

## Introduction

An important distinction to make here before I get started is that I am not using FormsAuthentication to secure a WCF service. I am using FormsAuthentication to manage user identity. FormsAuthentication comes with handy Encrypt/Decrypt methods which allow us to pass a token around between our service, the client and the web application using our service as a trusted identity/authentication provider. But the methods only operate on a FormsAuthenticationTicket instance.

This is really not a problem in this scenario, it gives us just enough of what we need – we can encrypt the data objects we’re passing around and we can also use serialization to include any complex objects in the FormsAuthenticationTicket.UserData property.

## Setup

As long as you are hosting WCF from ASP.NET you can take advantage of built-in ASP.NET features, including FormsAuthentication. There are many ways to secure an WCF service, but since we’re trying to build single sign on capabilities and we don’t want our users to be required to obtain additional credentials it makes sense to use FormsAuthentication for our service as well. MSDN contains [documentation for setting up FormsAuthentication](http://msdn.microsoft.com/en-us/library/bb398990.aspx)

1. Configure ASP.NET FormsAuthentication in the web application where your WCF service is located:

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"><system.web></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> ...</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> <authentication mode="Forms"></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> <forms cookieless="UseCookies" path="/SSO" name="SSOService"/></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> </authentication></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> ...</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"></system.web></pre>

This step isn’t required, however it is recommended at least during development. Setting up your dev machine to make your browser think you are communicating with multiple different sites. You need to edit your local “hosts” file, then add host headers to your IIS configuration and then setup Visual Studio to startup each application with the correct url. Then if you have multiple members on your team it further complicates things. If you do it this way, your SSO Service and each application you’re debugging can have a separate cookie path and everything will behave as if you were communicating across domains.

2. Add to the system.ServiceModel configuration section:

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"><system.serviceModel></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> <serviceHostingEnvironment aspNetCompatibilityEnabled="true"/></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> ...</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"></system.serviceModel></pre>

Step 2 gives you access to the ASP.NET intrinsic objects (Context, Server, Session, Request and Response) so you can read/write cookies.

[AspNetCompatibility](http://msdn.microsoft.com/en-us/library/aa702682.aspx)
3. Add the AspNetCompatibilityRequirements attribute to your service implementation class:

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;">[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">public class SSOService : ISSOService, ISSOPartnerService</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;">{</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> //... concrete interface implementation</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">}</pre>

If you don’t complete step 3, WCF will complain when it sees reads your config settings from step 2 and it doesn’t see the AspNetCompatibilityRequirements attribute on your service implementation.

## Using FormsAuthentication

If the client can supply valid credentials then we want to be able to determine the identity of the client for subsequent requests. So after validating the credentials we need to create a ticket and then send it back to the client:

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">public SSOToken Login(string username, string password)</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">{</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> // default response</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> SSOToken token = new SSOToken</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> Token = string.Empty,</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> Status = "DENIED"</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> };</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> // authenticate user</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> if (string.CompareOrdinal("foo", username) == 0</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> && string.CompareOrdinal("bar", password) == 0)</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> // mock data to simulate passing around additional data</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> Guid temp = Guid.NewGuid();</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> // manage cookie lifetime</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> DateTime issueDate = DateTime.Now;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> DateTime expireDate = issueDate.AddMonths(1);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> // create the ticket and protect it</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, username, issueDate, expireDate, true, temp.ToString());</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> string protectedTicket = FormsAuthentication.Encrypt(ticket);</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> // save the protected ticket with a cookie</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> HttpCookie authorizationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, protectedTicket);</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> authorizationCookie.Expires = expireDate;</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> // protect the cookie from session hijacking</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> authorizationCookie.HttpOnly = true;</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> // write the cookie to the response stream</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> HttpContext.Current.Response.Cookies.Add(authorizationCookie);</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> // update the response to indicate success</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> token.Status = "SUCCESS";</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> token.Token = protectedTicket;</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> }</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> return token;</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;">}</pre>

Next, when our client needs to assert its identity to a web application using our SSO service we need to provide something which can’t be tampered with and the web application can use to verify with our service to ensure no tampering occurred.

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;">public SSOToken RequestToken()</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;">{</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // default response</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> SSOToken token = new SSOToken</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> Token = string.Empty,</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> Status = "DENIED"</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> };</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // verify we've already authenticated the client</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> if (HttpContext.Current.Request.IsAuthenticated)</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // get the current identity</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> FormsIdentity identity = (FormsIdentity)HttpContext.Current.User.Identity;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // we'll send the client its own FormsAuthenticationTicket, but </pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // we'll encrypt it so only we can read it when the partner app</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // needs to validate who the client is through our service</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> token.Token = FormsAuthentication.Encrypt(identity.Ticket);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> token.Status = "SUCCESS";</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> }</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> return token;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;">}</pre>

We’ll use the FormsAuthenticationTicket we created and give the client an encrypted copy. Neither the client nor the web application can read it. The intent is that we give it to the client, the client will forward it to the web application and then the web application will be required ask our service if we can read it and if it is valid. If everything succeeds, we’ll confirm to the web application that the user is indeed who it says it is and can accept our assertion of the client’s identity.

## Security

I mentioned this in the last post, but I’ll say it again here. We don’t want to allow session hijacking here and so make sure you set your cookies to [HttpOnly](http://www.owasp.org/index.php/HTTPOnly)

## Conclusion

Basically, as long as you configure your service correctly for AspNetCompatibility you can still use forms authentication. By using FormsAuthentication you get everything you need for identity management pre-built for you.

If you’re following the SSO series, the next installment will focus on configuring WCF to support JSONP.