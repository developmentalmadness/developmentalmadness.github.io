---
layout: post
title: 'Docker: running npm install'
date: '2016-06-13 21:30:28'
tags:
- docker
- nodejs
- npm
---

Just spent most of the day trying to get `npm install` to work within a shared volume (`-v`). I've installed Docker Toolbox on Windows and I'm building a Docker image that will be shared with team members running on both Windows and OSX. This image is for development, not deployment. 

I really like the idea that a project should include a `compose.yml`. New team members should be able to simply `git clone ...`, `docker compose up` and then fire up their preferred IDE and then they're off to the races!

Anyway, long story short if all the npm modules you're depending on cooperate you should be able to run npm as follows:

    npm install --no-bin-links

And that should work for now. I read a thread that the Bash for Windows team is being consulted on this by the Docker for Windows Beta team - hopefully this won't be a problem for long!