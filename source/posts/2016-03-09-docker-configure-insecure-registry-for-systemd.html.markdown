---
layout: post
title: 'Docker: Configure Insecure Registry for systemd'
date: '2016-03-09 21:16:42'
tags:
- docker
- systemd
---

If you're running a flavor of Linux that uses systemd Docker recommends using it to [configure and control your Docker daemon](https://docs.docker.com/engine/admin/systemd/). I needed to connect my Docker daemon running on my Jenkins build server to my Docker Registry running in AWS (that's a post for another day). They connect through a private network so I'm not using SSL which means I need to configure the daemon with the [--insecure-registry](https://docs.docker.com/engine/reference/commandline/daemon/#insecure-registries) option. Here's how to do that:

**NOTE:** Some posts recommend just changing the `/lib/systemd/system/docker.service` file. This works but the [documentation advises against it](https://docs.docker.com/engine/admin/systemd/):

> The files located in /usr/lib/systemd/system or /lib/systemd/system contain the default options and should not be edited.

If you'd rather save a few steps you can skip the "create" section below and move ahead to the "configure" section. Other than the paths of the files you'll be editing everything else should be the same.

#Create systemd Override Files

If the path `/etc/systemd/system/docker.service.d/docker.conf` already exists just open the `docker.conf` file and skip to the next section. If it doesn’t exist, create the directory `/etc/systemd/system/docker.service.d` directory and `docker.conf` file:

    $ sudo mkdir /etc/systemd/system/docker.service.d
    $ sudo touch /etc/systemd/system/docker.service.d/docker.conf
    $ sudo vi /etc/systemd/system/docker.service.d/docker.conf

Then add the following contents to `docker.conf`:

    $ sudo vi /etc/systemd/system/docker.service.d/docker.conf
    [Service]
    ExecStart=
    ExecStart=/usr/bin/docker daemon -H fd://

#Configure insecure-registry

Append the `--insecure-registry` option to the end of the `ExecStart` options so it looks something like this: (multiple entries follow array convention. [See docs](https://docs.docker.com/engine/reference/commandline/daemon/)) 

    ExecStart=/usr/bin/docker daemon -H fd:// --insecure-registry myregistry.mydomain.com

Just make sure you replace `myregistry.mydoamin.com` with the url (and optionally the port if you're not using port 80) for your registry.

Save the file, then flush changes and restart:

    $ sudo systemctl daemon-reload
    $ sudo systemctl restart docker

Verify docker daemon is running

    $ ps aux | grep docker | grep -v grep

#Or Use /etc/default/docker

It may be because using `systemd` is new or it may be personal preference. But if you want to use the `/etc/default/docker` file to configure your docker daemon then you just need to change a couple things. First change your `/etc/systemd/system/docker.service.d/docker.conf` file to look like this:

    ExecStart=/usr/bin/docker daemon -H fd:// $DOCKER_OPTS
    EnvironmentFile=-/etc/default/docker

Now you can add the following to your `/etc/default/docker` file (create it if it doesn't exist) and replace `myregistry.mydomain.com` with the url (and optionally the port number if it isn't over port 80):

    DOCKER_OPTS="--insecure-registry myregistry.mydomain.com"

Again save the file, flush changes and restart just like above.