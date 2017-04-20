# Developmentalmadness.com

Public www for developmentalmadness.com

# Dependencies

- docker-compose >= 1.6

# Setup

`cd` to cloned source directory

    $ git checkout master-source
    $ docker-compose run --rm --service-ports node-custodian

Once the container starts up:

    $ bundle install
    $ bundle exec middleman

# Blogging

[Middleman Blogging](https://middlemanapp.com/basics/blogging/)
