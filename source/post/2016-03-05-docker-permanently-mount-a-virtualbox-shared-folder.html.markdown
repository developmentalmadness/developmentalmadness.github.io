---
layout: post
title: 'Docker: Permanently Mount a VirtualBox Shared Folder'
date: '2016-03-05 17:54:29'
tags:
- docker
- virtualbox
---

While this technique works for both Windows and OSX, most Windows developers I know don't keep their source code in the `Users` folder on the system drive. Historically there have been too many problems:

* The path used to start with `C:\Documents and Settings\[USER_NAME]\`
* `msbuild` blows up when your path is longer than 256 characters
* There's no convenient `~/` command-line shortcut when typing the path on the command-line.

However, that's the only default path you get when you create a `boot2docker` image for VirtualBox. 

In my [last post](http://www.developmentalmadness.com/2016/02/27/working-with-docker/) I showed how to mount a VirtualBox shared folder but as soon as you restart (*that* never happens on a Windows box) you've lost it and have to create the mount all over again. 

#Mount a shared folder
Just to review, so you don't have to read the last post: 

<ol>
  <li>
    <p>Create a shared folder in VirtualBox:</p>
    <p><img src="https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2016/03_05/virtual-box-shared-folders.png" /></p>
  </li>
  <li>
    <p><code>ssh</code> into your Guest OS (Docker VM):</p>
    <pre>
$ docker-machine ssh defualt</pre>
  </li>
  <li>
    <p>Create a new folder for your mount:</p>
    <pre>$ sudo mkdir -p /mnt/src</pre>
    <p>The <code>-p</code> is just in case <code>/mnt</code> doesn't already exist.</p>
  </li>
  <li>
    <p>Add your new mount:</p>
    <pre>$ sudo mount -t vboxsf -o defaults,uid=`id -u docker`,gid=`id -g docker` src /mnt/src</pre>
    <p><code>id -u docker</code> and <code>id -g docker</code> will use the user id and group id respectively. You could just enter <code>1000</code> and <code>50</code> respectively and you'd be fine. I think the longer version is more clear and safe. 
</p><p>
You should now be able to view the contents of your directory within your Docker VM:</p>
    <pre>$ ls /mnt/src</pre>
  </li>
</ol>

#Make It Permanent

The problem is everything gets erased whenever you restart your VM. What we need is a setup script that won't be erased and will run on startup. It turns out it's pretty easy. Create a file named `bootlocal.sh` at the following location:

    $ sudo touch /mnt/sda1/var/lib/boot2docker/bootlocal.sh

Now add the following to the file (no `sudo` needed):

    mkdir -p /mnt/src
    mount -t vboxsf -o defaults,uid=`id -u docker`,gid=`id -g docker` src /mnt/src

Make sure you save and close the file. That's it! If you `exit` your `ssh` session, then restart your VM:

    $ docker-machine restart default

Once it's finished, log back in and verify it's there:

    $ docker-machine ssh default
    $ ls /mnt/src

You should see the contents of your shared folder.