---
layout: post
title: 'Linux: Scheduled Jobs With crontab'
date: '2016-03-10 17:05:32'
tags:
- linux
- bash
- amazon-web-services-aws
- elastic-cloud-compute-ec2
- crontab
- simple-storage-service-s3
---

Today I learned about `crontab`, which for those of us coming from the [Windows](https://en.wikipedia.org/wiki/Microsoft_Windows) world is the equivalent of the [Windows Task Scheduler](https://en.wikipedia.org/wiki/Windows_Task_Scheduler). If I had known how easy it was to use I would have started using it a long time ago.

[HowToGeek has a great detailed write-up](http://www.howtogeek.com/101288/how-to-schedule-tasks-on-linux-an-introduction-to-crontab-files/) on it including plenty of examples of using the [cron](https://en.wikipedia.org/wiki/Cron) pattern. What I wanted to share was how to use [I/O Redirection](https://en.wikipedia.org/wiki/Redirection_(computing)) to update the file instead of using the crontab editor (`crontab -e`) as described in the HowToGeek article.

I wanted to setup a really simple file backup to [Amazon S3](https://en.wikipedia.org/wiki/Amazon_S3) on an [Amazon EC2](https://en.wikipedia.org/wiki/Amazon_Elastic_Compute_Cloud) instance. I also wanted to make sure I didn't have to set it up more than once. So I needed something that would work well as an [EC2 User Data script](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html#instance-launch-user-data-step):

First, copy crontab to a temp file named 'cron-temp' (arbitrary name):

    $ crontab -l > cron-temp

Next, use the append output-redirector `>>` to write a string to the temp file named 'cron-temp'. If I wanted to overwrite the file completely I could use `>` instead:

    $ echo '[minutes] [hours] [days] [months] [day-of-week] [bash command or script file]' >> cron-temp

In my case I wanted to run the script at the top of every hour so the script actually looked like this see the HowToGeek article for details on cron patterns:

    $ echo '0 * * * * aws s3 cp [local file path] s3://[s3-bucket-path]' >> cron-temp

Now that we've updated the temp file replace crontab file with contents of the temp file:

    $ crontab cron-temp

Finally, delete the temp file:

    $ rm cron-temp
    
