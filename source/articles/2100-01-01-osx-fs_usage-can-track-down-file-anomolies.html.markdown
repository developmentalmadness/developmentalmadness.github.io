---
layout: post
title: 'OSX: fs_usage can track down file anomolies'
published: false
tags:
- osx
- troubleshooting
---

I'd been seeing some file weirdness of late and I was getting a little worried. So I headed on over to my local stack exchange site and [I was directed](http://apple.stackexchange.com/questions/226072/strange-files-named-xey4o-keep-appearing) to the very useful `fs_usage` utility. 

After the following simple terminal command I started to try and figure out what program I was using that was generating this file:

    sudo fs_usage | grep ":xEy4O"

The `fs_usage` utility will sit and run continuously until you break out using `CTRL+C`. It will output file system events and you can of course then filter the output using `grep` as I have done above.

Excluding some noise due to having Finder and a couple other programs open I was able to focus on the following output:

    $ sudo fs_usage | grep ":xEy4O"
    09:12:47  open      :xEy4O         0.000020   bash        
    09:14:27  open      :xEy4O         0.000020   bash        
    09:15:59  open      :xEy4O         0.000297   bash    

Turns out the offender was a portion of an application secret key entry I had placed in my `.bash_profile` while I was learning about using the Akka application framework.
