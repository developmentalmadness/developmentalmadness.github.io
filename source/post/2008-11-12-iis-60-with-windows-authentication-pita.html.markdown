---
layout: post
title: IIS 6.0 with Windows Authentication PITA
date: '2008-11-12 18:35:00'
tags:
- intranet
- anonymous_authentication
- iis_6_0
- integrated_windows_authentication
---

ulling. It all started when the test server was hosed (rebuilt) without asking me if it affect anything I was doing. Without going to much into the history, an application that should have been on production was on staging and being used as the production application. 

Stop right there - don't start pointing fingers cause I've got no control over this other than the continual protesting that I have been doing. Not to mention that the person who requested the rebuild of the server has been in meetings where I have said, "It's on test and needs to be deployed to production - the users are using test as production.".

Anyway, I find about it from the users and am tasked with getting the server configured. I'm no IIS guru/god, but I'm hardly a neophyte. However, I don't have a lot of IIS experience in an intranet environment because usually when I work in these envrionments there is someone dedicated to this role. 

First, I verfied IIS was configured the same way as our development environment, which was working correctly. Then I dug through the security event logs and found this message:

    Unknown user name or bad password

Also, the authentication method logged was kerberos - at the time this meant nothing to me for reasons I mentioned above. How was I supposed to know they weren't using kerberos? But it turns out that was the key.

Apparently, this is by design. IIS is configured to use kerberos for Windows Authentication by default. But when your application pool is using a local machine account (the default) your application cannot access the domain controller. The key is to tell IIS to use NTLM instead of kerberos. This support link will tell you how to resolve this:

http://support.microsoft.com/kb/871179
