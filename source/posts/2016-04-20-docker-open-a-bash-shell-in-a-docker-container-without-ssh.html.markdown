---
layout: post
title: 'Docker: Open a Bash Shell in a Docker Container Without SSH'
date: '2016-04-20 22:29:03'
tags:
- docker
---

[You don't need to install SSHd on your Docker containers.](http://blog.docker.com/2014/06/why-you-dont-need-to-run-sshd-in-docker/). However, the method you use has changed. Now Docker has the `exec` command to do this for you. 

If you have a container named `my-app-container` then you would run:

    $ docker exec -it my-app-container bash

To open a bash shell in your container.

As an added bonus, if you're in development and you want to get into your Docker VM then the easiest way is to run:

    $ docker-machine ssh [docker_vm_name]

For most of us using the `default` VM it would look like this:

    $ docker-machine ssh default

Once you've opened `ssh` into your VM, then you can run the `docker exec` command at the top.

#References:
* [Docker exec command](https://docs.docker.com/engine/reference/commandline/exec/) 