---
layout: post
title: 'security: There''s a password in my repository!'
date: '2016-02-18 22:46:26'
tags:
- security
---

##TLDR - Environment Variables

Where possible you won't see me do this anymore:

    url = "jdbc:postgresql://127.0.0.1:5432/postgres?user=postgres&password=12345"

Or this:

    <connectionStrings>
      <add name="my-db" connectionString="server=.;database=my-app-db;uid=my-app-user;pwd=12345;" />
    </connectionStrings>

Instead you'll see varying uses of this:

    url = "${DB_URL}/postgres?user=${DB_USER}&password=${DB_PWD}"

Where if I can I'll use an environment variable in place of even a "fake" password. 

If you see some form of:

    $DB_URL

Or 

    %DB_URL%

It's probably an environment variable and I'll probably call it out in an explanation - which will probably link here and is probably why you're reading this.

##How?

These are pretty easy to do and each platform has a means of creating and reading them. I'll list the ones I know and use here over time since some platforms do make it difficult (I'm looking at you OSX).

**OSX**

I'm using OSX 10.11 - This is what works for me: Open up `~/.bash_profile` and add:

    export DB_URL=jdbc:postgresql://127.0.0.1:5432
    export DB_USER=postgres
    export DB_PWD=XXXXX

Save it, then restart your command line, IDE or whichever program needs it.

**Windows**

This is pretty universal across Windows versions:

* Depending on your Windows version, from Windows Explorer right-click `My Computer` or `This PC` and then click "Properties"

* Click "Advanced System Settings" tab

* Click "Environment Variables"

* Either add or edit a new System or User environment variable with the name you're going to use for your application.

##Why?

We've all done it - checked a password into a repository. Maybe not a public one (yet) but it will continue to happen, [even to the best of us](http://arstechnica.com/security/2015/03/ubers-epic-db-blunder-is-hardly-an-exception-github-is-awash-in-passwords/) as long as we continue to store them in our config files. 

It's easy...YAGNI...you're getting your project started, it's just a local password...you'll change it later...much later :P

Most places I work these days replace sensitive keys as part of a build process, but the passwords are still stored in the config file. It isn't a stretch to imagine a someone putting a production key to a database or cloud account of some kind into a config file - and accidentally checking it in.

The root of the problem is that we shouldn't be editing any kind of sensitive key in files that exist anywhere in the source tree - ever!

The simplest way I see to solve this is to use environment variables. Every project can use them in any language on any platform and they will never exist in the source tree. 

##Unite!

But the biggest problem is bloggers and forum users. I've long felt that when we post online quick and dirty examples that ignore best security practices we perpetuate the problem. Those who are just learning won't know any better unless we show them. I used to see a lot of SQL examples posted which where vulnerable to SQL injection attacks. Not so much anymore. If we stop creating examples where the password is stored somewhere in the source tree we'll stop seeing credentials stored directly in Github!