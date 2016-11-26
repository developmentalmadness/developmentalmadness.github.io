---
layout: post
title: Recovery iPhone Recovery Password From Backup
date: '2016-04-28 15:25:19'
tags:
- iphone
---

My wife forgot her restrictions pin on her iPhone and wouldn't let me reset the phone because she didn't want to loose **anything**. I found multiple tools that would help with this but they wanted $$ and I knew this was something I could figure out. 

Well all hail open source! Because I found [pinfinder](https://github.com/gwatts/pinfinder) on Github. A nifty little go program that will scan your unencrypted backups and pull your pin. 

If you've encrypted all your backups, just run a new non-encrypted one and then delete it afterwards.

Just download the [latest release](https://github.com/gwatts/pinfinder/releases) for your platform, extract the archive and run it from the terminal:

    $ pinfinder

That's it!