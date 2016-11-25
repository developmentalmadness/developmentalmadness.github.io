---
layout: post
title: 'SQL 2008 Installation Fails: "Previous Release of Microsoft Visual Studio
  2008"'
date: '2008-08-14 17:54:00'
tags:
- visual_studio_2008_sp_1
- sql_2008_rtm
---

I have been trying since yesterday to install the RTM of SQL 2008. But once I have selected the components to install I get a failure during the check of installation rules. The rule failing is "Previous releases of Microsoft Visual Studio 2008". I have downloaded and installed Visual Studio 2008 SP 1. In fact I've run the install several times.

Then I found this post describing why this error is happening. It turns out I had installed and uninstalled an RC version of 2008 several months ago. But I still had **Visual Studio 2008 Shell (integrated mode)** installed as well. So I uninstalled this. But after completing the uninstall I was still unable to install SQL 2008.

So I went back to the SP 1 page and noticed there was a separate link for Express Editions of Visual Studio. I remembered I had VC++ 2008 Express installed! After visiting I found this little gem in the page :

###IMPORTANT
If you have multiple Visual Studio products installed, you must upgrade all of them to SP1. **If you have Visual Studio 2008 and one or more 2008 Express Editions, you cannot upgrade the Express Editions until you have upgraded Visual Studio.**

That is the kicker. I had to install SP 1 for VS 2008 first, then ALSO install SP1 for VC++ 2008. This goes for all express editions: Web Developer Express, Visual Basic Express and Visual C# as well as VC++ Express.

I am in the process of installing VC++ 2008 SP 1 (which appears to be a full install), if I run into any other problems I'll update this post. But otherwise, this should correct the issue. Hope it helps!
