---
layout: post
title: Nesting Docker Containers? Stop!
date: '2016-03-05 19:30:04'
tags:
- docker
- scala-build-tool-sbt
---

In a recent blog post [I pointed out Docker is about microservices](/2016/02/27/working-with-docker/), and you should compose your containers instead of building monolithic ones. I was referring to adding tools and utilities for troubleshooting and whatnot. But today I have an even better example: building Docker images from within a container!

`sbt` ([Scala interactive built tool](http://www.scala-sbt.org/index.html)) has a plugin called `sbt-native-packager` which allows you to configure your project to be built and then packaged as a Docker container. Which means all I have to do is this:

    $ sbt docker:publish

And once my build finishes it will create the image and `push` it to whichever repository I've configured in my `build.sbt` file.

Except that most everyone on my team uses Windows. Which means that Java and sbt need to be installed on the Docker VM. But every time you restart your VM it gets wiped clean! 

Because of this, instead of just using the small, default boot2docker vm that comes packaged so nicely for you with the Docker install everyone goes through the process of installing a full Ubuntu VM and then configuring and installing Docker, Java and sbt. 

I'm against the whole give the new guy a Word document with setup instructions. It's part of why I like Docker so much. And this whole setup smells like we're going right back down that path. So today I found a much better way.

#Siblings Instead of Nesting

I can't claim credit for this, other than reading the documentation on the [Docker-in-Docker (dind)](https://hub.docker.com/_/docker/) page on Docker Hub. Here's links to the two relevant posts:

* [Using the `--privileged` flag](https://docs.docker.com/engine/reference/run/#runtime-privilege-linux-capabilities-and-lxc-configuration) - Docker Run reference
* [Using Docker-in-Docker for your CI or testing environment? Think twice](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) - jpetazzo 

After reading those two posts I decided there was a much better way, and after learning [how to make my VirtualBox shared folders permanent mounts](/2016/03/05/docker-permanently-mount-a-virtualbox-shared-folder/) I went looking for a Docker image which already had Java and sbt installed for me.

**UPDATE (3/17/16):** It was been pointed out that using shared folders is a security concern. This is correct. So let me add a disclaimer: the shared folders aspect of this post was included because I have been helping developers who thought they needed to install/configure all their build tools inside their Docker host in addition to their host OS so they could build their docker images. I'm not advocating shared folders in any other context.

#Sharing Docker Binaries

I settled on the excellent [1science/sbt](https://hub.docker.com/r/1science/sbt/) image which is a mere 176 mb (not bad for an image with the Java SDK installed). There were three things I had to figure out to get all this to work together:

First, how to share the Docker binaries with the 1science/sbt container:

    $ docker run -it --rm -v "$HOME/.ivy2":/root/.ivy2 -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker 1science/sbt sbt sbt-version

Let's break this down a little:

* `-it` allows us to run the container like `tty` to an [interactive shell](https://docs.docker.com/engine/reference/run/#foreground). If you left off `sbt-version` you'd be in the `sbt` interactive console.  

* `--rm` [removes the container](https://docs.docker.com/engine/reference/run/#clean-up-rm) as soon as the command is over. This is helpful since we just want to run the command in the foreground and then exit.

* `-v "$HOME/.ivy2":/root/.ivy2` maps the Ivy cache to a host volume so the cache will persist between runs and allow our builds to run faster after the first time.

* `-v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker` creates two more host mounted volumes that share the Docker binaries with the container. This is the most important piece since it's what allows `sbt` to build our container instead of just creating a `Dockerfile` for us to build ourselves.

* `$(which docker)` is an evaluated statement. In Linux `which` shows the full path of shell commands - so the output is the path to the docker command. We could look it up, but this makes the `run` command shorter.

The next step took me the longest to figure out because the `README` for the `1science/sbt` image indicated I needed to something different. So either I was doing it wrong or the docs are wrong. Feel free to correct me we're in this journey together.

    $ docker run -it --rm -v "$HOME/.ivy2":/root/.ivy2 -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker -v $(pwd):/app 1science/sbt ls

This command doesn't do much more than the last (notice we're only calling `ls`). But we've added a volume for the root of our project: `-v $(pwd):/app`. If it worked correctly you should see your project root files listed in the output. This of course only works if your current working directory for the `run` command is the root of your source project. If not, replace `$(pwd)` with the path to your project root. It should be the path as seen by Docker, which means it's from the context of your Docker VM.

The reason we needed to map the volume here is because the `1science/sbt` image sets `/app` as the `WORKINGDIR` for the image. Any commands will be executed from the context of `/app` which is empty, so we just map our project root to `/app` and `sbt` will find everything it needs (almost).

Most of you should be able to run the following now from your project root:

    $ docker run -it --rm -v "$HOME/.ivy2":/root/.ivy2 -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker -v $(pwd):/app 1science/sbt sbt docker:publish

Or if you're not setup with a central registry yet use `publishLocal`:

    $ docker run -it --rm -v "$HOME/.ivy2":/root/.ivy2 -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker -v $(pwd):/app 1science/sbt sbt docker:publishLocal

If your `build.sbt` file is configured correctly your project will build as a Docker image and publish to your configured registry (Docker Hub is the default). However, if your project is a Play application created using `activator` then you probably are getting the following error:

> sbt.ResolveException: unresolved dependency: com.typesafe.sbtrc#client-2-11;0.3.1: not found
unresolved dependency: com.typesafe.sbtrc#actor-client-2-11;0.3.1: not found

This is an [open issue](https://github.com/playframework/playframework/issues/4839) due to some funkyness with `activator` that doesn't work out of the box with `sbt`. But it's easily fixed. Just add the following to your `build.sbt` file:

    resolvers += Resolver.url("Typesafe Ivy releases", url("https://repo.typesafe.com/typesafe/ivy-releases"))(Resolver.ivyStylePatterns)

And your build will be fixed. Repeat the above `run` command and this time it should work.

This post is certainly laking in any actual `sbt` details, but I didn't want it to be too long. I'll work through a very simple example using Scala and post it soon.