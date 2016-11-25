---
layout: post
title: 'Building a Single Sign On Provider Using ASP.NET and WCF: Part 1'
date: '2009-07-01 16:47:00'
tags:
- net_framework_3_5
- wcf
- asp_net
- ajax
---

This is the first in a 4 part series on building a single sign on provider using the ASP.NET platform (ASP.NET and WCF). Originally, I wrote the article as a single post but it was pretty long, even for me.

**Part 1** addresses the problem in general and how I decided to architect it.

[**Part 2**](http://developmentalmadness.blogspot.com/2009/07/building-single-sign-on-provider-using_02.html)

[**Part 3**](http://developmentalmadness.blogspot.com/2009/07/building-single-sign-on-provider-using_06.html)

describes the implementation details and includes the [source code](http://cid-2c81058206cadea2.skydrive.live.com/self.aspx/.Public/CodeSamples/SSO.zip)

## Part 1: Planning an SSO Solution

We’re using a custom provider and I was asked last week to integrate into our application. Since we don’t have a single sign on service I had to build one from scratch. I found a few solutions I thought would work, but I had erroneously assumed that the applications would all live on the same [domain](http://en.wikipedia.org/wiki/Domain_name)

## Architecture

I dug around and considered the two public SSO solutions I am most familiar with: and [Microsoft LiveID](http://msdn.microsoft.com/en-us/library/bb676631.aspx)

[![SSOFlowDiagram_thumb2](http://lh3.ggpht.com/_09jBj8qnWKM/SkuTK_LEERI/AAAAAAAAADY/gGkpRSuoWO0/SSOFlowDiagram_thumb24.gif?imgmax=800 "SSOFlowDiagram_thumb2")](http://r4pflq.bay.livefilestore.com/y1pu3Y9DmmfOotQlrIBgxUtxukRxStzUIG8Trvi62xi5MGvHS4tnRd3SUmn2R6PYgGmGb06HTOQfFN4GPTFY9S1Vw/SSOFlowDiagram.gif)

Guess what? I can hear you laughing from here. Disclaimer: I suck at Visio.

Here’s a description of what you’re seeing:

* **Client** – a web browser attempting to access a web application which has been secured by a trusted SSO service.
* **Application** – a web application which delegates the validation of user credentials to a centralized authentication service.
* **SSO Service** – a centralized repository of user credentials and (potentially) profile data managed by a trusted 3rd party.

The SSO service has no UI whatsoever. All communication between the client and SSO service is done via cross-domain calls ([JSONP](http://niryariv.wordpress.com/2009/05/05/jsonp-quickly/)

Here’s how the process flows:

1. When an unauthenticated client requests a secured resource from the application that client is redirected to an authentication page.
2. The authentication page makes a request (via JSONP) to the SSO service for a token which can then be presented to the application as evidence of the client’s identity with the SSO service.
3. If the client has already authenticated with the SSO service and has an active session then skip to step #7 otherwise the request is denied.
4. An unauthenticated client (SSO authentication) is redirected to a login page where the client then submits credentials for the SSO service.
5. Upon submitting a valid set of credentials to the SSO service the client receives a cookie containing a token which is valid for the SSO service.
6. Now that the client has successfully authenticated with the SSO service the client is redirected back to the application’s authentication page (step #2).
7. The client receives an encrypted copy of the authentication ticket from the SSO service which it can then submit to the application. NOTE: This extra step is required when cookies are set to “[HttpOnly](http://www.owasp.org/index.php/HTTPOnly)
8. The client now submits the SSO token to the application. The application verifies the token with the SSO service by forwarding it and asking if it is a valid token.
9. The SSO service responds to the application with a flag indicating wither or not the submitted token is valid or not. Potentially, the SSO service could also provide additional information regarding the identity of the client. If the token was valid, the application then responds to the client with a token of it’s own which identifies the client to the application.
10. The client, now authenticated with both the SSO service as well as the application, resubmits the request for the resource from step #1\.

#### Security

Messages over JSONP are not considered secure, so at the very least you will want to make sure and use SSL to protect communication with the SSO service.

Also, EVAL is called on the JSONP response to execute the callback returned by the service. If the service is vulnerable to injection attacks and the scripts injected into the service are returned somehow via JSONP then those scripts will be executed on the client.

There are security issues you should consider when using JSONP or any type of cross-domain communication.

## Conclusion

There are those among you who would be able to implement the entire solution on your own at this point – none of this is cutting edge. Stay tuned for the next installment on setting up FormsAuthentication with WCF.