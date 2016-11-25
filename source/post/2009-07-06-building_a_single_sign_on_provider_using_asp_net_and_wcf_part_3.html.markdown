---
layout: post
title: 'Building a Single Sign On Provider Using ASP.NET and WCF: Part 3'
date: '2009-07-06 18:00:00'
tags:
- net_framework_3_5
- wcf
- ajax
---

## Using JSONP with WCF

This is the third article in a four part series on building a single sign on () provider using the platform. If you just want to know about and and aren’t interested in implementing SSO read ahead. Otherwise, make sure to check out and . ( and the ).[source code are now available](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/SSO.zip)

## JSONP

Also known as “JSON with Padding” is more of a back door to allow cross domain [AJAX](http://en.wikipedia.org/wiki/Ajax_%28programming%29)

Support for JSONP is built into the [jQuery](http://jquery.com/)

## Server-side JSONP Support

Even though [client-side support for JSONP is built in](http://docs.jquery.com/Release:jQuery_1.2/Ajax#Cross-Domain_getJSON_.28using_JSONP.29)

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;">callbackname({"property":"data"});</pre>

Where “callbackname” is the value of a query string parameter named “callback”. jQuery generates this callback at runtime, and expects it in the response so just check the value of Request.QueryString[“callback”] and replace “callbackname” with the value you get.

Do you see the problem yet? WCF controls the output stream here, so how do you handle this? According to Jason Kelly, you can [download JSONP samples from MSDN](http://msdn.microsoft.com/en-us/library/cc716898.aspx)

* JSONPBehavior.cs
* JSONPBindingElement.cs
* JSONPBindingExtension.cs
* JSONPEncoderFactory.cs

Then modify the service definition in your web.config by adding the extensions from the above files and modifing your bindings:

<pre size="8pt" color="black" style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"><system.serviceModel></pre>

<pre size="8pt" color="black" style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> <!-- add JSONP extensions --></pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <extensions></pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <bindingElementExtensions></pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <add name="jsonpMessageEncoding"</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> type="Microsoft.Ajax.Samples.JsonpBindingExtension, SSO.Service, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null"/></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> </bindingElementExtensions></pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> </extensions></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> <!-- using JSONP bindings --></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> <bindings></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> <customBinding></pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;"> <binding name="userHttp"></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> <jsonpMessageEncoding /></pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> <httpTransport manualAddressing="true"/></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> </binding></pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> </customBinding></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> </bindings></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"></system.serviceModel></pre>

Now you can tell WCF which operations need to support JSONP by applying the JSONPBehavior attribute like in the ServiceContract interface definition below:

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;">[ServiceContract]</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;">public interface ISSOService</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;">{</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> [OperationContract]</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> [WebGet(UriTemplate="/RequestToken",</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> BodyStyle=WebMessageBodyStyle.WrappedRequest,</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> ResponseFormat=WebMessageFormat.Json)]</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> [JSONPBehavior(callback = "callback")]</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> SSOToken RequestToken();</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> [OperationContract]</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> // javascript can't post w/ jsonp - has to be WebGet</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> [WebGet(UriTemplate="/Login?username={username}&password={password}",</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> BodyStyle = WebMessageBodyStyle.WrappedResponse,</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> ResponseFormat = WebMessageFormat.Json)]</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> [JSONPBehavior(callback = "callback")]</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> SSOToken Login(string username, string password);</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> [OperationContract]</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> [WebGet(UriTemplate = "/Logout",</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> BodyStyle = WebMessageBodyStyle.WrappedResponse,</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> ResponseFormat = WebMessageFormat.Json)]</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> [JSONPBehavior(callback = "callback")]</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> bool Logout();</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;">}</pre>

These custom bindings don’t seem to play well when you want to expose your ServiceContract to other clients. This was the main reason why I split my ServiceContract into 2 separate interfaces. By using separate contracts I could define an endpoint for the client and one for the application, each using separate bindings. The client endpoint uses the custom JSONP bindings and the application (partner) endpoint uses webHttpBinding.

## Service Implementation

After all this the service implementation is pretty vanilla although if you’re not following along the entire series, make sure that you either configure WCF to enable [AspNetCompatibility](http://msdn.microsoft.com/en-us/library/aa702682.aspx)

The Login operation (if the credentials are valid) generates and encrypts a FormsAuthenticationTicket and adds it to the Response.Cookies collection. The RequestToken operation reads the FormsAuthenticationTicket from the current Identity and returns it to the client and the ValidateToken operation decrypts the token and reads the UserData property, if that fails then the token isn’t valid. Here it is:

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;">[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;">public class SSOService : ISSOService, ISSOPartnerService</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;">{</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> #region ISSOService Members</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> public SSOToken RequestToken()</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> {</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> SSOToken token = new SSOToken</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> {</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> Token = string.Empty,</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> Status = "DENIED"</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> };</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> if (HttpContext.Current.Request.IsAuthenticated)</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> FormsIdentity identity = (FormsIdentity)HttpContext.Current.User.Identity;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> token.Token = FormsAuthentication.Encrypt(identity.Ticket);</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> token.Status = "SUCCESS";</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> return token;</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> }</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> public bool Logout()</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> HttpContext.Current.Session.Clear();</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> FormsAuthentication.SignOut();</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> cookie.Expires = DateTime.Now.AddDays(-10000.0);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> HttpContext.Current.Response.Cookies.Add(cookie);</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> return true;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> public SSOToken Login(string username, string password)</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> SSOToken token = new SSOToken</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> Token = string.Empty,</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> Status = "DENIED"</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> };</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> // authenticate user</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> if (string.CompareOrdinal("foo", username) == 0</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> && string.CompareOrdinal("bar", password) == 0)</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> Guid temp = Guid.NewGuid();</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> DateTime issueDate = DateTime.Now;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> DateTime expireDate = issueDate.AddMonths(1);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, username, issueDate, expireDate, true, temp.ToString());</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> string protectedTicket = FormsAuthentication.Encrypt(ticket);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> HttpCookie authorizationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, protectedTicket);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> authorizationCookie.Expires = expireDate;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> authorizationCookie.HttpOnly = true;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> HttpContext.Current.Response.Cookies.Add(authorizationCookie);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> token.Status = "SUCCESS";</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> token.Token = protectedTicket;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> }</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> return token;</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> }</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> public SSOUser ValidateToken(string token)</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> try</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(token);</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> return new SSOUser { </pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> Username = ticket.Name, </pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> SessionToken = new Guid(ticket.UserData) </pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> };</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> }</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> catch</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> return new SSOUser { </pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> Username = string.Empty, </pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> SessionToken = Guid.Empty </pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> };</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> }</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> }</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> #endregion</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;">}</pre>

## Client Communication

Now that we have a working service implementation, we need to access the service operations from our client. We’ll use jQuery to make this quick and simple:

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;">$(function() {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> $("#logon").click(function() {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> $.get('http://localhost:21259/SSOService.svc/user/Login?callback=?',</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> { username: $("#username").val(), password: $("#password").val() },</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> function(ssodata) {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> if (ssodata.LoginResult.Status == 'DENIED') {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // display some sort of 'login failed' message to the user</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> } else {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // the client now needs to get the authentication ticket from</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // the service and present it to the web application for </pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> // verification</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> }</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> }, 'jsonp');</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> });</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;">});</pre>

The nice thing about jQuery here is that JSONP support is built-in. You can just use the [$.get()](http://docs.jquery.com/Ajax/jQuery.get)

Notice the "?callback=?” query string added to the service url. “callback=?” tells jQuery to generate a callback method and forward that callback name to our service. The value of “callback” is immaterial since it will be handled behind the scenes between jQuery and WCF. Also, you can place “callback=?” anywhere in the query string. If you have other query string parameters you can either do as I have done and include them as part of the JSON object passed to the $.get() method or include them in the query string along with “callback=?”. So the URI could have looked like this:

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;">'http://localhost:21259/SSOService.svc/user/Login?callback=?&username=foo&password=bar'</pre>

or like this:

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;">'http://localhost:21259/SSOService.svc/user/Login?username=foo&password=bar&callback=?'</pre>

## Security

If you’re following the entire series, I’m sure your tired of hearing this, but cross-domain browser communication is considered unsafe. Protect your application and your users from session hijacking by setting your cookies [HttpOnly](http://www.owasp.org/index.php/HTTPOnly)

HttpOnly = true prevents session hijacking by preventing any client-side scripts which may be in the web application (which is beyond the control of the service application) from reading the cookie.

jQuery takes the response from the service and passes it to EVAL(). Using whitelists to validate userdata sent in response to client requests will prevent XSS scripts from being executed by the client.

## Conclusion

We’ve discussed SSO as well as configuring WCF to support FormsAuthentication and JSONP, next we’ll tie everything together and you’ll finally get your hands on the source code. See you for the next and final installment.