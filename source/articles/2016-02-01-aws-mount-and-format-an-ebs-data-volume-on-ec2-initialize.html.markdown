---
layout: post
title: 'AWS: Mount and Format an EBS Data Volume on EC2 Initialize'
date: '2016-02-01 17:26:12'
tags:
- amazon-web-services-aws
- elastic-block-storage-ebs
- elastic-cloud-compute-ec2
---

The [developer guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) for [AWS](https://en.wikipedia.org/wiki/Amazon_Web_Services) [EC2](https://en.wikipedia.org/wiki/Amazon_Elastic_Compute_Cloud) has a section titled [Making an Amazon EBS Volume Available for Use](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html). It describes how to make an [EBS](https://en.wikipedia.org/wiki/Amazon_Elastic_Block_Store) volume available after you've attached it to your EC2 instance and connected over [SSH](https://en.wikipedia.org/wiki/Secure_Shell). But if you're using [Auto-Scaling Groups](https://aws.amazon.com/autoscaling/), [CloudFormation](https://aws.amazon.com/cloudformation/), or you don't want to have to connect and manually format the volume there's a way to skip the manual steps. If you just put the following into the [User Data](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html?tag=duckduckgo-d-20) setting for your instance it will automatically run the script upon initialization:

    #!/bin/bash
    mkfs -t ext4 [device_name]
    mkdir [mount_point]
    mount [device_name] [mount_point]

If you want the device mounted after any reboot you can also append the following line to the User Data script above:

    echo "[device_name]    [mount_point]    ext4    defaults,nofail    0    2" >> /etc/fstab 

The `>>` operator will append the output of `echo` to the specified file - in this case `/etc/fstab` ([Ubuntu docs](https://help.ubuntu.com/community/Fstab)).

The explanation for all the commands and parameters above can be found in the developer guide, but you should be able to use these commands anywhere you can specify User Data for an EC2 instance.

#Permissions

I used this technique to setup an EC2 instance I am using for [EC2 Container Service (ECS)](https://aws.amazon.com/ecs/) and tried to find out what permissions I would need to set (read: `chown`) on my volume so my container could write to it. I was concerned when I saw everything was owned by `root`. However, I found that docker has root access so I never had to change permissions. YMMV and I'd love any feedback on this, but for the moment I'll just say that for ECS you won't need to worry about file permissions outside of your container instances. 
    