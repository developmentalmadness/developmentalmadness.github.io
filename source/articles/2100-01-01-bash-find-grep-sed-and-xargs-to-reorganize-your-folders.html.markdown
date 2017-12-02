---
layout: post
title: 'Bash: find, grep, sed, And xargs To Reorganize Your Folders'
published: false
tags:
- bash
---

My home network is very heterogenous: Windows 7/8.1/10, OSX, and various linux distributions (OpenELEC,Synology,Ubuntu,Fedora,...). So I store all shared content on my Synology NAS. I'm in charge of the network, but my wife maintains control of our photography. She loves her Mac hardware so all pictures are imported first to the family iMac. After that I make sure they are copied to our NAS so we can access them from all our other devices. 

Unfortunately, the folder structure when you import using iPhoto means browsing in a file explorer is a huge pain because you only get a couple files in each folder even if they were all taken on the same day. The folder structure is something like this:

    [year]/[month]/[day]/[year][month][day]-[24-hour][minute][second]

We (read: my wife) finally got sick of this and so I needed to fix it. I've made myself live in Bash as much as possible over the last 6 months so I'm getting better, but this was the first time I needed to do something like this. Fortunately, I've fiddled a little with `grep` and `xargs` and so I started looking there. When I found I needed find/replace I was led to `sed`. I had started with `ls -r` until I found `find` was much simpler in this case.

Before I dive into the details, here's the short version of what I did:

#Move Files

Match files containing something like `20160127-205022` in the path:

    find "$PWD" -type f | grep -E "\/[0-9]{8}-[0-9]{6}\/" | sed -e 'p;s:/[0-9]\{8\}-[0-9]\{6\}::g' | xargs -n2 mv

Turns out there was an older variant. I also needed to match `20160127-205022\%e0s+ciwlJ9sDE90l2DWLl`:

    find "$PWD" -type f | grep -E "\/[0-9]{8}-[0-9]{6}\/[0-9a-zA-Z%\+]{22}" | sed -e 'p;s:/[0-9]\{8\}-[0-9]\{6\}/[0-9a-zA-Z%\+]\{22\}::g' | xargs -n2 mv

#Delete Folders

This whole process left empty folders all over after removing all their files. To go through and delete them all I ran this:

    find "$PWD" -type d | grep "\/[0-9]\{8\}-[0-9]\{6\}" | xargs rm -r

#Change Permissions

I've been using `scp` to copy files since I've revoked write permissions on all my shares to prevent damage from a ransomware attack. Unfortunately I just found out permissions aren't copied when using `scp`.

Grant read permissions to the group for all files recursively

    find "$PWD" -type f | xargs -I % chmod g+r "%"

#Explaination

http://www.grymoire.com/Unix/Sed.html

#Other Examples

Create matching folder structure in destination directory:

    find "$PWD" -type f | grep -i -E "\.(mov|avi)$" | sed -e "s:[^/]*\..*$::g" -e "s:Pictures:Movies/Home:g" -e "s: :_:g" | xargs mkdir -p

Copy home video files (quotes around path strings):

    find "$PWD" -type f | grep -i -E "\.(mov|avi)$" | sed -e 's:.*:"&":g' -e "p;s:Pictures:Movies/Home:g" -e "s: :_:g" | xargs -n2 cp

To break it down: `"$PWD"` uses the `PWD` command to inject the path of your working directory. The `-i` argument makes the `grep` regex case-insensitive. `sed` is being used to replace values in string. The `-e` option allows multiple commands. The first regex quotes the entire string. The second actually does 2 things: first the `p;` will print both the input and output of the replacement, then the replace regex changes the path so we have our `SOURCE` and `DEST` for our `cp` command later. The last replace will replace spaces with underscores. Lastly we tell `xargs` to pull two lines for each command and pass them in order to the `cp` command.  
