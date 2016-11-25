---
layout: post
title: 'Docker: Troubleshooting 500 Error From Registry 2'
date: '2016-04-21 22:44:45'
tags:
- docker
- troubleshooting
---

Been fighting an [HTTP 500 Internal Server Error](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#5xx_Server_Error) from Docker Registry. We have several instances running on Amazon EC2 Container Service (ECS) behind Elastic Load Balancer (ELB). Whenever we tried to push a new image up we'd get:

> received unexpected HTTP status: 500 Internal Server Error

#Enable Debug Mode

Docker logs wasn't telling me anything. But searching around I read you can enable debug mode `-D` for Docker. After locating in the ECS documentation [how to enable debug mode](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/troubleshooting.html#docker-debug-mode) I did the following on each EC2 instance:

    sudo vi /etc/sysconfig/docker

And changed this line:

    OPTIONS="--default-ulimit nofile=1024:4096"

To this:

    OPTIONS="-D --default-ulimit nofile=1024:4096"

Then saved the file and restarted the Docker daemon:

    sudo service docker restart

And restarted both the ECS Agent and my Docker registry container:

    sudo docker start [ecs_container_id]
    sudo docker start [registry_container_id]

#Solution

Then after trying to push an image again I found this in our logs:'

    time="2016-04-21T22:18:48Z" level=error msg="response completed with error" err.code=unknown err.detail="s3aws: AccessDenied: Access Denied\n\tstatus code: 403, request id: XXXXXXXXXXXXXXXX" err.message="unknown error" go.version=go1.6.1 http.request.host=[hostname] http.request.id=[UUID value] http.request.method=PATCH http.request.remoteaddr=[IP Address] http.request.uri="/v2/[image_name]/blobs/uploads/[digest]?_state=[data]" http.request.useragent="docker/1.11.0 go/go1.5.4 git-commit/[hash] kernel/4.1.19-boot2docker os/linux arch/amd64 UpstreamClient(Docker-Client/1.11.0 \\(windows\\))" http.response.contenttype="application/json; charset=utf-8" http.response.duration=137.964693ms http.response.status=500 http.response.written=117 instance.id=[UUID value] vars.name=[image_name] vars.uuid=[UUID value] version=v2.4.0

The most helpful bit of the message was: 

> err.detail="s3aws: AccessDenied: Access Denied\n\tstatus code: 403, request id: XXXXXXXXXXXXXXXX"

Telling me that the container was missing the correct S3 permissions.


