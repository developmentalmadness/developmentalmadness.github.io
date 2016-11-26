---
layout: post
title: 'Docker: Copy Arbitrary Files Between Docker Containers'
date: '2016-03-28 23:34:18'
tags:
- docker
---

Do you need to copy an arbitrary file from within a [Docker](https://en.wikipedia.org/wiki/Docker_(software)) container to your host file system? The `docker cp` command has got your back!

    $ docker cp [container_id]:[container_path] [localpath]

So to copy a file named `output.log` to the current working directory from a container named `mycontainer` you would run:

    $ docker cp mycontainer:/my-app-logs/output.log output.log

The command works the other direction as well:

    $ docker cp output.log mycontainer:/my-app-logs/output.log

Full details on the command can be found in the [Docker cp documentation](https://docs.docker.com/v1.8/reference/commandline/cp/).