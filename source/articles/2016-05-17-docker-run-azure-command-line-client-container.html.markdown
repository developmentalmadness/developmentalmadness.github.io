---
layout: post
title: 'Docker: Run Azure Command-Line Client Container'
date: '2016-05-17 17:47:55'
tags:
- docker
- azure
---

I've been using AWS, but I'm starting to look into Apache Spark for an up-coming project and Amazon EMR doesn't qualify under the AWS Free Tier so I decided to head on over to the world of Microsoft Azure to use my MSDN credits to do some experimentation without it costing my anything.

Microsoft has created a [Docker image for their Azure command-line client](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/#use-a-docker-container). Here's my setup:

    $ docker create --name azure-profile -v /root/.azure microsoft/azure-cli

The Azure cli stores configuration and access tokens in `~/`. Unless you want to authenticate each time to you fire up a new session I recommend creating a data volume container for your profile data. Then you can use it to make sure your profile data is persistent like this:

    $ docker run -it --rm --volumes-from azure-profile microsoft/azure-cli

This will create an interactive tty session `-it` in a new container which will be deleted `--rm` as soon as you exit. But as long as you use `--volumes-from` your profile data will be persistent. 

First let's look at the contents of the `~/.azure` directory before we log in:

    $ ls ~/.azure

    config.json  telemetry.json

Next before we go through the login steps, let's make sure we've correctly setup our volume. Open a second terminal session (make sure to run `eval "$(docker-machine env [name])"`). Now run `inspect` to make sure we have the volume right:

    $ docker inspect --format='{{json .Mounts}}' [container_id]

    [{"Name":"668d3cf8050abe1a87c29f4c1bd2023ecc9c27bec6bbd26d17e0fd24729e8c35","Source":"/var/lib/docker/volumes/668d3cf8050abe1a87c29f4c1bd2023ecc9c27bec6bbd26d17e0fd24729e8c35/_data","Destination":"/root/.azure","Driver":"local","Mode":"","RW":true,"Propagation":""}]

You should see something like the above output. The important part is the `Destination` should be `/root/.azure`. If it is you did it right. Otherwise, go back and look for typos.

Back in our interactive container session: We need to login. You may want to [review authentication options](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-connect/). As for me I have MFA enabled on my Microsoft account so I use the interactive login once I'm inside my interactive container session:

    $ azure login

Follow the directions and you'll be logged in.

Let's inspect our profile directory again:

    $ ls ~/.azure

    accessTokens.json  azureProfile.json  config.json  telemetry.json

Now if your volumes are correct you can exit your container session (which will remove your container because of the `--rm` option we specified):

    $ exit

Now fire up a new session again:

    $ docker run -it --rm --volumes-from azure-profile microsoft/azure-cli

Look inside your `~/.azure` directory and it should still have all 4 `.json` files. Now you're all set. Good luck!

