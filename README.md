# Developmentalmadness.com

Public www for developmentalmadness.com

# Dependencies

- docker-compose >= 1.6
- aws cli

# Setup

`cd` to cloned source directory

    $ git checkout master-source
    $ git clone [git@github.com repo url] build

The nested "build" directory will be a clone of the master branch so that the `middleman build` command output can be committed to the master branch.

Now run:

    $ docker-compose up -d

Once the container starts up:

 * visit http://localhost:8081

# Blogging

[Middleman Blogging](https://middlemanapp.com/basics/blogging/)

# Accessing Middleman CLI

    $ docker-compose exec www bash

Or if you don't want to use an interactive shell:

    $ docker-compose exec www [middleman command]

For example:

    $ docker-compose exec www middleman build

# Publishing to public site (AWS S3 static site)


