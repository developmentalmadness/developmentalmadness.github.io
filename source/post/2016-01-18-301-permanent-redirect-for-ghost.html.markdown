---
layout: post
title: 301 Permanent Redirect for Ghost
date: '2016-01-18 19:32:23'
tags:
- docker
- ghost-tag
- nginx
- seo
---

The [Ghost blogging platform](https://ghost.org/) (currently v0.7.4) doesn't currently provide a way to support moving resource urls. If you're moving from a blogging platform with a different url scheme there's no native support. Instead the recommended practice is to use [nginx](http://nginx.com).

I've never used it before now and plus I'm using [Docker](http://www.docker.com/) to host Ghost on [AWS EC2 Container Service](https://aws.amazon.com/ecs/). My current focus is learning Docker and AWS so I wanted a nice clean way to set everything up correctly without spending too much time learning how to configure everything.

#nginx-proxy 

After some quick searching I stumbled onto [nginx-proxy](https://github.com/jwilder/nginx-proxy) written by [Jason Wilder](http://jasonwilder.com/). The short of it is that nginx-proxy is a specialized version of the [docker-gen](https://github.com/jwilder/docker-gen) docker image (also by jwilder) configured to dynamically maintain the nginx configuration file. 

docker-gen monitors the current docker host for any containers with the `VIRTUAL_HOST` environment variable set along with an `EXPOSE` port defined. nginx-proxy is configures docker-gen so that when a new container is detected it rebuilds the config file and calls `nginx -s reload` so the new container is dynamically added behind nginx.

#nginx Configuration Template 
Create a docker-gen template file (`nginx.tmpl`) for nginx:

    # If we receive X-Forwarded-Proto, pass it through; otherwise, pass along the
    # scheme used to connect to this server
    map $http_x_forwarded_proto $proxy_x_forwarded_proto {
      default $http_x_forwarded_proto;
      ''      $scheme;
    }
    # If we receive Upgrade, set Connection to "upgrade"; otherwise, delete any
    # Connection header that may have been passed to this server
    map $http_upgrade $proxy_connection {
      default upgrade;
      '' close;
    }
    gzip_types text/plain text/css application/javascript application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
    log_format vhost '$host $remote_addr - $remote_user [$time_local] '
                     '"$request" $status $body_bytes_sent '
                     '"$http_referer" "$http_user_agent"';
    access_log off;
    # HTTP 1.1 support
    proxy_http_version 1.1;
    proxy_buffering off;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $proxy_connection;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
    server {
    	server_name _; # This is just an invalid value which will never trigger on a real hostname.
    	listen 80;
    	access_log /var/log/nginx/access.log vhost;
    	return 503;
    }
    {{ range $host, $containers := groupBy $ "Env.VIRTUAL_HOST" }}
    upstream {{ $host }} {
    
    {{ range $index, $value := $containers }}
        {{ with $address := index $value.Addresses 0 }}
        server {{ $address.IP }}:{{ $address.Port }};
        {{ end }}
    {{ end }}
    
    }
    
    {{/* Get the VIRTUAL_PROTO defined by containers w/ the same vhost, falling back to "http" */}}
    {{ $proto := or (first (groupByKeys $containers "Env.VIRTUAL_PROTO")) "http" }}
    
    server {
        server_name {{ $host }};
        listen 80;
        access_log /var/log/nginx/access.log vhost;
        location / {
            # rewrite urls for blogger and subtext schemes
            rewrite "^/archive/(\d{4}/\d{2}/\d{2}/.+)\.(?:aspx|html)$" /$1 last; 
            rewrite "^/[Tt]ags/(.*)/default\.(aspx|html)$" /tag/$1/ last;
            proxy_pass {{ trim $proto }}://{{ trim $host }};
        }
    
    }
    {{ end }}


* Quotes around the regex in the `rewrite` directives aren't always required. However I did find that using quantification in your patterns (ex. `{4}` and `{2}`) do require quoting the entire expression as I have above. If you don't you'll see the following when you run `docker logs blog-proxy`:
    
 > Error running notify command: nginx -s reload, exit status 1

   And if you log into the actual docker container and run `nginx -s reload` you'll see this:

 > nginx: [emerg] directive "rewrite" is not terminated by ";" in /etc/nginx/conf.d/default.conf:42

* [I ran into an issue](http://stackoverflow.com/questions/34662979/nginx-redirect-with-proxy-pass) where I had only a single `rewrite` directive and if I used `break` or `permanent` instead of `last` I didn't get any errors but the redirect never happened. It just went to Ghost unchanged, which of course returned an http 404 (not found) status. 

#Run nginx

Run nginx-proxy in Docker (`\` to format command on multiple lines for easier reading):

    $ docker run --name blog-proxy -d -p 80:80 \
        -v /var/run/docker.sock:/tmp/docker.sock:ro \
        -v [host_path_to_template]/nginx.tmpl:/app/nginx.tmpl \
        jwilder/nginx-proxy

* The volume for `docker.sock` is required. If it doesn't exist the container will fail to start.

#Run Ghost

Run [Ghost image](https://hub.docker.com/_/ghost/):

    $ docker run --name ghost-blog -d -P \
        -v [host_path_to_sqlite_db]/ghost.db:/var/lib/ghost/data/ghost.db \
        -v [host_path_to_config]/config.js:/var/lib/ghost/config.js \
        -e VIRTUAL_HOST=[blog_host_domain] \
        ghost

* If you have multiple container instances of Ghost running they will be grouped by `VIRTUAL_HOST` and [load-balanced](http://nginx.org/en/docs/http/load_balancing.html) using a round-robin configuration. 

* Using `-P` (uppercase) allows docker to decide the port number to assign and each instance will receive it's own unique port number. The nginx configuration file will pick up the port numbers for each instance and add them to it's pool for the given `VIRTUAL_HOST`. 
* If you're using an RDBMS like MySql or postgres you can omit the volume mapping for the sqlite db since you'll have your connection string configured in `config.js`.

* If you want to use a theme other than the default Casper theme or if you have your own custom theme then you'll need to add a volume mapping that overwrites the container's `/var/lib/ghost/themes/` directory. Something like this:

<pre>
    -v [host_path_to_themes]/themes/:/var/lib/ghost/themes/
</pre>

 Or build your own Docker image that inherits from the office Ghost image and includes your custom theme. [Here's an example of one I created](https://github.com/developmentalmadness/coder-ghost-docker/blob/master/Dockerfile). Just build the Dockerfile and replace the name of the `ghost` image in the Docker `run` command above with the name of your image.