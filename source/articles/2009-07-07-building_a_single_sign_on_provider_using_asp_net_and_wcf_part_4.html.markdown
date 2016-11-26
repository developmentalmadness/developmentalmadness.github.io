---
layout: post
title: 'Building a Single Sign On Provider Using ASP.NET and WCF: Part 4'
date: '2009-07-07 06:00:00'
tags:
- net_framework_3_5
- wcf
- asp_net
- ajax
---

This is the fourth and final article in a four part series on building a using the ASP.NET platform. Make sure to check out , and [part 3](http://developmentalmadness.blogspot.com/2009/07/building-single-sign-on-provider-using_06.html)

[Source Code](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/SSO.zip)

## Implementing a Single Signon Provider

This is all a rehash since I’ve covered each point in detail to this point, but I’d like to tie everything together at this point and provide the source code. If you’d like detailed descriptions about how/why review the previous 3 parts. The full source code will be available [here](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/SSO.zip)

[![SSOFlowDiagram](http://lh6.ggpht.com/_09jBj8qnWKM/SkuVs9QX6FI/AAAAAAAAADg/L45l4MOjQeg/SSOFlowDiagram_thumb1.gif?imgmax=800 "SSOFlowDiagram")](http://r4pflq.bay.livefilestore.com/y1pu3Y9DmmfOotQlrIBgxUtxukRxStzUIG8Trvi62xi5MGvHS4tnRd3SUmn2R6PYgGmGb06HTOQfFN4GPTFY9S1Vw/SSOFlowDiagram.gif)

1. When an unauthenticated client requests a secured resource from the application that client is redirected to an authentication page.
2. The authentication page makes a request (via [JSONP](http://niryariv.wordpress.com/2009/05/05/jsonp-quickly/)
3. If the client has already authenticated with the SSO service and has an active session then skip to step #7 otherwise the request is denied.
4. An unauthenticated client (SSO authentication) is redirected to a login page where the client then submits credentials for the SSO service.
5. Upon submitting a valid set of credentials to the SSO service the client receives a cookie containing a token which is valid for the SSO service.
6. Now that the client has successfully authenticated with the SSO service the client is redirected back to the application’s authentication page (step #2).
7. The client receives an encrypted copy of the authentication ticket from the SSO service which it can then submit to the application. NOTE: This extra step is required when cookies are set to “[HttpOnly](http://www.owasp.org/index.php/HTTPOnly)
8. The client now submits the SSO token to the application. The application verifies the token with the SSO service by forwarding it and asking if it is a valid token.
9. The SSO service responds to the application with a flag indicating wither or not the submitted token is valid or not. Potentially, the SSO service could also provide additional information regarding the identity of the client. If the token was valid, the application then responds to the client with a token of it’s own which identifies the client to the application.
10. The client, now authenticated with both the SSO service as well as the application, resubmits the request for the resource from step #1\.

## Service Implementation

We’re using the FormsAuthentication API within WCF to manage identity

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;">[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]</pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;">public class SSOService : ISSOService, ISSOPartnerService</pre>

<pre size="8pt" color="black" style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;">{</pre>

<pre size="8pt" color="black" style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> #region ISSOService Members</pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> public SSOToken RequestToken()</pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> {</pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> SSOToken token = new SSOToken</pre>

<pre style="border-style: none; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> {</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> Token = string.Empty,</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> Status = "DENIED"</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> };</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> if (HttpContext.Current.Request.IsAuthenticated)</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> {</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> FormsIdentity identity = (FormsIdentity)HttpContext.Current.User.Identity;</pre>

<pre style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> token.Token = FormsAuthentication.Encrypt(identity.Ticket);</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> token.Status = "SUCCESS";</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> }</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> return token;</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> }</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> public bool Logout()</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> {</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> HttpContext.Current.Session.Clear();</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> FormsAuthentication.SignOut();</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName);</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> cookie.Expires = DateTime.Now.AddDays(-10000.0);</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> HttpContext.Current.Response.Cookies.Add(cookie);</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> return true;</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> }</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> public SSOToken Login(string username, string password)</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> {</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> SSOToken token = new SSOToken</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> {</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> Token = string.Empty,</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> Status = "DENIED"</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> };</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> // authenticate user</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> if (string.CompareOrdinal("foo", username) == 0</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> && string.CompareOrdinal("bar", password) == 0)</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> Guid temp = Guid.NewGuid();</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; width: 100%; direction: ltr;"> DateTime issueDate = DateTime.Now;</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> DateTime expireDate = issueDate.AddMonths(1);</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, username, issueDate, expireDate, true, temp.ToString());</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> string protectedTicket = FormsAuthentication.Encrypt(ticket);</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> HttpCookie authorizationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, protectedTicket);</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> authorizationCookie.Expires = expireDate;</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> authorizationCookie.HttpOnly = true;</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;font-size:8pt;color:black;"> HttpContext.Current.Response.Cookies.Add(authorizationCookie);</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; width: 100%; padding-right: 0px; direction: ltr;"> token.Status = "SUCCESS";</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> token.Token = protectedTicket;</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> }</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> return token;</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> }</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> public SSOUser ValidateToken(string token)</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> {</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> try</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> {</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(token);</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> return new SSOUser { </pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> Username = ticket.Name, </pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> SessionToken = new Guid(ticket.UserData) </pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> };</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> }</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> catch</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> {</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> return new SSOUser { </pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> Username = string.Empty, </pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> SessionToken = Guid.Empty </pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> };</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> }</pre>

<pre size="8pt" color="black" style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr;"> }</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> #endregion</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;">}</pre>

## Web Application Client

Web.Config – system.serviceModel definition

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"><system.serviceModel></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <bindings></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <webHttpBinding></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <binding name="partnerBinding" ></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> </binding></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> </webHttpBinding></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> </bindings></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <behaviors></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <endpointBehaviors></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <behavior name="partnerEndpointBehavior"></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <webHttp/></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> </behavior></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> </endpointBehaviors></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> </behaviors></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <client></pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> <endpoint address="http://localhost:21259/SSOService.svc/partner" behaviorConfiguration="partnerEndpointBehavior"</pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: white; padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> binding="webHttpBinding" </pre>

<pre style="border-style: none; margin: 0em; overflow: visible; text-align: left; padding-bottom: 0px; line-height: 12pt; background-color: rgb(244, 244, 244); padding-left: 0px; width: 100%; padding-right: 0px; direction: ltr; font-size: 8pt; color: black;"> bindingConfiguration="partnerBinding"</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> contract="References.ISSOPartnerService" </pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> name="partnerEndpoint" /></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> </client></pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"></system.serviceModel></pre>

For the web application all that is required is to call the ValidateToken method of the SSO service and then provide the client with a token that identifies the client for the ASP.NET application (Authenticate method calls FormsAuth.SignIn()):

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">[AcceptVerbs(HttpVerbs.Post)]</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;">public JsonResult Authenticate(string token, bool createPersistentCookie)</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">{</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> SSOPartnerServiceClient client = new SSOPartnerServiceClient("partnerEndpoint");</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> SSOUser user = client.ValidateToken(token);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> if (string.IsNullOrEmpty(user.Username)</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> || Guid.Empty.Equals(user.SessionToken))</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> return Json(new { result = "DENIED" });</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> }</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> FormsAuth.SignIn(user, createPersistentCookie);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> return Json(new { result = "SUCCESS" });</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;">}</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">public void SignIn(SSOUser user, bool createPersistentCookie)</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;">{</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> DateTime issueDate = DateTime.Now;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, user.Username,</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> issueDate, issueDate.AddMinutes(20), true, user.SessionToken.ToString());</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> string protectedTicket = FormsAuthentication.Encrypt(ticket);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, protectedTicket);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> cookie.HttpOnly = true;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> cookie.Expires = issueDate.AddMinutes(20);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> HttpContext.Current.Response.Cookies.Add(cookie);</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;">}</pre>

## jQuery Client

Authenticate.aspx View

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;">$(function() {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> // get valid token from SSO</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> $.get('http://localhost:21259/SSOService.svc/user/RequestToken?callback=?', {},</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New', courier, monospace;font-size:8pt;color:black;"> function(ssodata) {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> var logonPage = '<%=Url.Action("LogOn", "Account") %>';</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> if (ssodata.Status == 'SUCCESS') {</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> // get target url</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> var redirect = '<%=Request["redirectUrl"] %>';</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> if (redirect == '')</pre>

<pre face="'Courier New', courier, monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;"> redirect = '<%=Url.Action("Index", "Home") %>';</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> // validate SSO token thru current application</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> $.post('<%=Url.Action("Authenticate", "Account") %>',</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> { token: ssodata.Token, createPersistentCookie: true },</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> function(data) {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> if (data.result == 'SUCCESS')</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> document.location = redirect;</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> else</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> document.location = logonPage;</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> }, 'json');</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> } else {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> // not logged into SSO service, go to login page</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> document.location = logonPage;</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> }</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> // make sure to specify JSONP</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> }, 'jsonp');</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;">});</pre>

Logon.aspx View

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;">$(function() {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> $("#logon").click(function() {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> $("#error").text('').hide();</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> $.get('http://localhost:21259/SSOService.svc/user/Login?callback=?',</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr; font-family: 'Courier New',courier,monospace; font-size: 8pt; color: black;"> { username: $("#username").val(), password: $("#password").val() },</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> function(ssodata) {</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; direction: ltr;font-family:'Courier New',courier,monospace;font-size:8pt;color:black;"> if (ssodata.LoginResult.Status == 'DENIED') {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> $("#error").text('Login Failed').show();</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; direction: ltr;"> } else {</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> document.location = '<%=Url.Action("Authenticate", "Account") %>';</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> }</pre>

<pre face="'Courier New',courier,monospace" size="8pt" color="black" style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; direction: ltr;"> }, 'jsonp');</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: white; width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;"> });</pre>

<pre style="border-style: none; margin: 0em; padding: 0px; overflow: visible; text-align: left; line-height: 12pt; background-color: rgb(244, 244, 244); width: 100%; font-family: 'Courier New',courier,monospace; direction: ltr; color: black; font-size: 8pt;">});</pre>

## Conclusion

At this point you have everything you need to implement an SSO provider using . In theory, if you know how to setup to communicate with other platforms other than the [.NET Framework](http://msdn.microsoft.com/en-us/netframework/default.aspx)

If the scope of the applications you are targeting is smaller (they’re all part of the same domain or even on the same machine) there are certainly simpler ways to accomplish the same result with less effort. This is an example of a provider which can cover a group of applications from any domain and across any platform/hardware boundaries.

I’ve really learned a lot in this exercise, thanks for following me through this. I hope you enjoyed it as well.

[Source Code](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/SSO.zip)