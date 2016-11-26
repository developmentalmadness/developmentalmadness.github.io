---
layout: post
title: 'Docker: Configure Insecure Registry in Boot2Docker'
date: '2016-03-09 18:00:46'
tags:
- docker
---

I gotta say there's some confusing naming that goes on. `Boot2Docker` was originally a docker client that ran on OSX and Windows. That has been replaced by `docker-machine`. However, there is also a VirtualBox image (the default one) called `Boot2Docker`. In this post I'm talking about the latter.

I have a Docker Registry instance I just configured to run in AWS and is backed by S3 for storage. It's running as a farm of ECS containers behind an ELB. It is running in a private network so I have skipped setting up SSL. Which means I need to configure my docker daemon with the `--insecure-registry` option so I can pull images to my development machine. And as I mentioned above, I'm currently using the default `Boot2Docker` image so the configuration is very specific.

You should have a file in your Docker VM: `/var/lib/boot2docker/profile`. If you open it, it should look something like this:

    $ cat /var/lib/boot2docker/profile

    EXTRA_ARGS='
    --label provider=virtualbox
    '
    CACERT=/var/lib/boot2docker/ca.pem
    DOCKER_HOST='-H tcp://0.0.0.0:2376'
    DOCKER_STORAGE=aufs
    DOCKER_TLS=auto
    SERVERKEY=/var/lib/boot2docker/server-key.pem
    SERVERCERT=/var/lib/boot2docker/server.pem
    
To tell Docker to allow you to access an insecure registry you need to add the option to `EXTRA_ARGS` like so `--insecure-registry=[url]` like this:

    $ sudo vi /var/lib/boot2docker/profile

    EXTRA_ARGS='
    --label provider=virtualbox
    --insecure-registry=myregistry.mydomain.com
    '
    CACERT=/var/lib/boot2docker/ca.pem
    DOCKER_HOST='-H tcp://0.0.0.0:2376'
    DOCKER_STORAGE=aufs
    DOCKER_TLS=auto
    SERVERKEY=/var/lib/boot2docker/server-key.pem
    SERVERCERT=/var/lib/boot2docker/server.pem

Then just restart the docker daemon:

    $ sudo /etc/init.d/docker restart

You should now be able to `push` and `pull` using your registry. 