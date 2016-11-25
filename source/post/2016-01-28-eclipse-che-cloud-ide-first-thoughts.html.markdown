---
layout: post
title: 'Eclipse CHE Cloud IDE: Setup and First Thoughts'
date: '2016-01-28 18:56:49'
tags:
- net
- java
- docker
- eclipse
---

Just saw an [announcement](http://sdtimes.com/eclipse-che-beta-arrives/) for [Eclipse CHE](http://www.eclipse.org/che/) beta last night. Currently I'm more of an [IntelliJ](https://www.jetbrains.com/idea/) fan and I was even excited to hear about the development of an IntelliJ-based IDE for .NET ([Project Rider](http://blog.jetbrains.com/dotnet/2016/01/13/project-rider-a-csharp-ide/)). 

#Setting Up CHE

For those just interested in getting started with CHE here's how (you may want to also review the [command-line startup docs](https://eclipse-che.readme.io/docs/usage#command-line) for troubleshooting or special conditions I don't cover here):

[Download](http://www.eclipse.org/che/download/) Eclipse CHE ZIP or TGZ package. (There's installers for Windows & OSX, but I prefer a low-impact setup).

 CHE is a server. So if your team is using it you'll do this on a central server instead of on a developer's machine. We're also going to go full Docker here instead of installing a local server on your machine - again low-impact.

Extract the archive wherever you want it installed. For OSX/Linux:

    tar -xvf eclipse-che-latest.tar.gz

#The Easy Way

If you prefer the easiest way, I was contacted by [@TylerJewell](https://twitter.com/TylerJewell) CHE Team Lead to let me know I've been trying to hard. If you don't care if the CHE server is running in Docker then simply do the following at this point:

    $ cd eclipse-che-[version]
    $ bin/che.sh run

Or on windows

    $ bin\che.bat run

Now just navigate to http://localhost:8080 and you're set.

#All In With Docker

If you want to run 100% in docker keep reading. Otherwise, thanks for coming or you can skip over this section to my thoughts on the CHE project.

**Update 2/1/16:** Modifying the VirtualBox network settings as described below is not necessary. If you read the output from the `che.sh run` command you should see something like this:

    ############## HOW TO CONNECT YOUR CHE CLIENT ###############
    After Che server has booted, you can connect your clients by:
    1. Open browser to http://192.168.99.101:8080, or:
    2. Open native chromium app.
    #############################################################

Just enter the address from #1 into your browser instead of localhost (below) and you should be fine. If you however you want to play with using `localhost` instead of the IP address the VirtualBox network settings I describe below should work for you. Otherwise, skip head to the part about starting up CHE.

##Using localhost

If you want to be able to point your browser to localhost on OSX/Windows in VirtualBox forward port 8080 from your Docker VM to port 8080 on your host.

**Open Settings**

 ![VirtualBox Main](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2016/01_28/VirtualBox-Main.png)

**Select "Network"**

 ![Network Settings](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2016/01_28/VirtualBox-NetworkSettings.png)

 **Add an entry to forward TCP port 8080 to 8080**

 ![Port Forwarding](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2016/01_28/VirtualBox-PortForwarding.png)

Now the startup script will be able to communicate with Docker and your Eclipse CE Server.

If you forget this step you'll likely run into the following error when you try and start CHE:

> !!! Running 'docker' succeeded, but 'docker ps' failed. This usually means that docker cannot reach its daemon.

#Starting CHE
From the command-line, navigate to the directory where you extracted the CHE archive:


    $ cd [directory path]


Now to start CHE:

**OSX / Linux**

    $ bin/che.sh -i run

**Windows**

    $ bin\che.bat -i run

Once you see the following (with different timing of course) you're ready to go:

    - Server startup in 9605 ms

If you followed the VirtualBox directions above navigate to http://localhost:8080 and you should see your CHE Dashboard:

![CHE Dashboard](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2016/01_28/CHE-Dashboard.png)

Otherwise, use the IP of your VirtualBox VM: 
    
    http://[your_vm_ip]:8080. 

Click on "New Project" and you'll see this:

![CHE New Project](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2016/01_28/CHE-NewProject.png)

Out of the box you'll have "Stacks" for Java, Node, PHP, and ASP.NET (Mono).

At this point that's as far as I've gone so for now I'll leave the experimentation as an exercise for the reader. I'll post again once I've had more time to play with this.

For those interested in why they should care there are a couple things that give me reason to be really excited about CHE:

#Zero Impact Setup

According the the home page one of the stated goals is:

> We are building a world where anyone can contribute to a project without installing software.
 
I have long been a proponent of developer productivity. When on-boarding a new team member I strive to make the experience as close to checkout-build-run as possible. I believe the developer should be able setup their dev environment according to their own preferences and not have to spend days or week(s) setting up the project. 

Also working on multiple branches should be just as painless. 

At work we are looking to adopt Docker for our new environments and on my list of research is using [Docker Compose](https://docs.docker.com/compose/) to set up a full development environment. CHE would support not only the same goal but go even farther by not requiring the setup of a development environment - we could truly work from anywhere.

#Microsoft Support

According to the [CHE Features](http://www.eclipse.org/che/features/) page Microsoft is contributing to the CHE project. I haven't dug into the documentation yet (that's next) but given the work Microsoft have already done[ supporting intellisense in OmniSharp](http://www.hanselman.com/blog/OmniSharpMakingCrossplatformNETARealityAndAPleasure.aspx) and Visual Studio Code I think we'll see support for C# and ASP.NET on par with the Java support already provided by CHE. There's already an ASP.NET stack that comes with CHE, just not intellisense yet.

In and of itself this is really not that big a deal. However, Microsoft is getting ready to release [Windows Server 2016 with native Docker support](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/about/about_overview), so I believe Microsoft will make sure that CHE works with Windows Containers as well. Since there are so many companies with heavy Microsoft investments and very complex setups I could see many (probably not all) could greatly benefit from what CHE is offering. 

Of course I'm making a few assumptions here: 

* Windows Containers will support the full .NET Framework, not just the newly minted .NET Core and ASP.NET Core. I'm pretty sure this is true.
* Windows Containers will support full Windows Server installs, not just Windows Nano. I'm not sure about this one.

Depending on which of those assumptions are true will determine which projects could actually take advantage of such a scenario.

I'm excited to see this project as it progresses and if it meets my needs I hope to be able to contribute in some way.

#Updates

* **1/29/16:** Updates based on recommendations by [@TylerJewell](https://twitter.com/TylerJewell) and some errata.
* **2/1/16:** Updates clarifying that there is no need to change VirtualBox network settings