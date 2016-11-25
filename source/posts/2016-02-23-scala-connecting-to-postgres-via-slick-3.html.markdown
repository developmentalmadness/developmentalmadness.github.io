---
layout: post
title: 'scala: Connecting to Postgres via Slick 3'
date: '2016-02-23 20:16:05'
tags:
- postgresql
- docker
- scala
- typesafe-slick
---

Got [Slick](http://slick.typesafe.com/) working with [Postgres](http://www.postgresql.org/) this morning and I thought I'd just write it up before I forget. I'm assuming you already know how to create a new [scala](http://www.scala-lang.org/) project that uses [sbt](http://www.scala-sbt.org/) for build and dependencies.

##Environment Variables

For this post you'll need the following environment variables setup:

    DB_PG_URL="jdbc:postgresql://192.168.99.100:5432"
    DB_PG_USER=postgres
    DB_PG_PWD=12345

[I've explained why here](/2016/02/18/security-theres-a-password-in-my-repository/). And here's more information about [Docker and environment variables](https://docs.docker.com/engine/reference/run/#env-environment-variables).

The above IP address `192.168.99.100` will depend on your setup. If you're running an installation of postgres (localhost or remote) you'll use the IP or hostname you use to reach that instance. If you're following along, using [Docker](https://www.docker.com/) you'll need the IP address returned from `docker-machine` (assuming either OSX or Windows):

    $ docker-machine ls
    
    NAME      ACTIVE   DRIVER       STATE     URL                         SWARM
    default   *        virtualbox   Running   tcp://192.168.99.100:2376   

Whatever the IP returned for URL is what you'll use in the environment var `DB_PG_URL`.

The remaining Docker commands assume you have a VM named `default`. If not you'll need to substitute `default` with the name of your VM - or create a VM named `default`.

Also, to avoid the need to include separate instructions based on your VM host OS the remaining commands assume you are running a terminal session inside your Docker host, like this:

    $ docker-machine ssh default

Once you run that command your terminal/console window context will be *inside* your Docker host.

##Postgres setup

If you don't have postgres installed already, then go do that. Or if you have Docker installed, then you can just execute the following Docker `run` command and you're already done! Here's the official page for the [Docker postgres image](https://hub.docker.com/_/postgres/).

    $ docker run --name pg-scratchpad -e POSTGRES_PASSWORD=$DB_PG_PWD -p 5432:5432 -v /var/lib/postgresql/data -d postgres

If you're still new to Docker the short explanation is that the command will start an installation of postgres in a new container (`run`) over port 5432 (`-p`) with a persistent volume (`-v`) running in the background (`-d`).

That `-e POSTGRES_PASSWORD=$DB_PG_PWD` is a password I've stored as an environment variable. 

##Creating some data

You'll need to connect to postgres somehow. If you're using a local install of postgres then you'll want to run `psql` from the command line. For those of us running Docker try this:

    docker run -it --link pg-scratchpad:postgres --rm postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

We're creating a second container here and linking it to our `pg-scratchpad` container where our database instance is running. `-it` sets up an interactive shell that is using the link between containers and running the `psql` command. This will give us a client where we can setup our database. The above command came from the documentation for the [Docker postgres image](https://hub.docker.com/_/postgres/).

Like any ORM, Slick let's you define your model in code or config and it will create it for you. But for my purposes I wanted to work under the assumption I had an existing database. So we'll create a simple schema, put some data in it and use Slick to query the table.

So run the following commands in your psql session (`#` is just the command prompt - don't type it, but do make sure to terminate each command with a semi-colon (`;`)):

    # CREATE TABLE records (
      id INT NOT NULL,
      value VARCHAR(64) NOT NULL
    );

    # INSERT INTO records (id, value) VALUES (1, 'booyah!');

If you run a query you should get some data back. As long as you do you're set:

    # SELECT * FROM records;

Your results should look like this:

     id |     value      
    ----+----------------
      1 | booyah!
    (1 row)

#sbt setup

Your `build.sbt` file should include the following dependencies:

    libraryDependencies ++= List(
    // ... your other dependencies
      "com.typesafe.slick" %% "slick" % "3.0.0",
      "org.postgresql" % "postgresql" % "9.4-1201-jdbc41",
      "com.zaxxer" % "HikariCP" % "2.4.1"
    )

**NOTE:** HikariCP is a "non-optional" dependency for Slick.

I'm not sure what `HikariCP` is for but I get a runtime error if it isn't there. As for `slick` and `postgresql`, the former is a Functional ORM which supports streaming and back-pressure and the latter is the postgresql client library and drivers Slick needs to connect to your database instance.

##Configuration

Create an `application.conf` file under `src/main/resources` in your source tree. Here's how you'll configure it:

    pg-postgres = {
      url = ${DB_PG_URL}/postgres
      user = ${DB_PG_USER}
      password = ${DB_PG_PWD}
      driver = org.postgresql.Driver
    }


##Case class mapping

Add a new scala class to your project and call it `Tables.scala`. The name is arbitrary although it does follow the convention used by the Slick Code Generator. 

    import slick.driver.PostgresDriver.api._

    case class record(id: Int, value: String)
    
    class Records(tag: Tag) extends Table[record](tag, "records") {
      def id = column[Int]("id")
      def value = column[String]("value")
      def * = (id, value) <> (record.tupled, record.unapply)
    }

Here we've mapped a case class and class structure to match our database table. Most of this is pretty self-explanatory except for the `def * = ...`. That function allows Slick to map back and forth between our case class `record` and the database.

##Running a query

Now add a new scala class to your project and call it `MyApp.scala`. Enter the following `object` definition:

    import slick.driver.PostgresDriver.api._
    import scala.concurrent.Await
    import scala.concurrent.duration.Duration

    object MyApp extends App {
      val query = TableQuery[Records]
      val db = Database.forConfig("pg-postgres")
      try{
        Await.result(db.run(DBIO.seq(
          query.result.map(println)
        )), Duration.Inf)
      } finally db.close
    }
    
Now run MyApp and you should see something like the following:

    Vector(record(1,booyah!))

This doesn't cover querying or anything else of the sort, but now that you're started you've finished the hard part ;).

##Slick Code Generator

As an bonus, it could be valuable to see what gets generated by different table structures.  Add the following dependency to your `build.sbt`:

      "com.typesafe.slick" %% "slick-codegen" % "3.0.2" % "provided"

Now from the command line execute `sbt console` to drop into the scala REPL. Then enter the following:

First create a variable for each of your environment variables:
    
    scala> val url = System.getenv("DB_PG_URL") + "/postgres"
    url: String = jdbc:postgresql://192.168.99.100:5432/postgres
    
    scala> val user = System.getenv("DB_PG_USER")
    user: String = postgres
    
    scala> val pwd = System.getenv("DB_PG_PWD")
    pwd: String = 1qaz2wsx
    
Then call the Slick Code Generator like this:

    scala> slick.codegen.SourceCodeGenerator.main(Array("slick.driver.PostgresDriver", "org.postgresql.Driver", url, "src/main/scala", "com.dvMENTALmadness", user, pwd))

The first two arguments are the slick and postgres drivers respectively. Next, pass in your `url` variable to point to your database instance. Then `src/main/scala` is the relative path from my sources root where I want my `Tables.scala` file created and `com.dvMENTALmadness` is my package name. Lastly pass in the `user` and `pwd` variables so the code generator can authenticate with postgres.

Once the script runs you should find (assuming you're using the above paramters) a new file: `src/main/scala/com/dvMENTALmadness/Tables.scala` created and the content should look something like this:

    package com.dvMENTALmadness
    // AUTO-GENERATED Slick data model
    /** Stand-alone Slick data model for immediate use */
    object Tables extends {
      val profile = slick.driver.PostgresDriver
    } with Tables
    
    /** Slick data model trait for extension, choice of backend or usage in the cake pattern. (Make sure to initialize this late.) */
    trait Tables {
      val profile: slick.driver.JdbcProfile
      import profile.api._
      import slick.model.ForeignKeyAction
      // NOTE: GetResult mappers for plain SQL are only generated for tables where Slick knows how to map the types of all columns.
      import slick.jdbc.{GetResult => GR}
    
      /** DDL for all tables. Call .create to execute. */
      lazy val schema = Record.schema
      @deprecated("Use .schema instead of .ddl", "3.0")
      def ddl = schema
    
      /** Entity class storing rows of table Record
       *  @param id Database column id SqlType(int4)
       *  @param value Database column value SqlType(varchar), Length(64,true) */
      case class RecordRow(id: Int, value: String)
      /** GetResult implicit for fetching RecordRow objects using plain SQL queries */
      implicit def GetResultRecordRow(implicit e0: GR[Int], e1: GR[String]): GR[RecordRow] = GR{
        prs => import prs._
        RecordRow.tupled((<<[Int], <<[String]))
      }
      /** Table description of table record. Objects of this class serve as prototypes for rows in queries. */
      class Record(_tableTag: Tag) extends Table[RecordRow](_tableTag, "record") {
        def * = (id, value) <> (RecordRow.tupled, RecordRow.unapply)
        /** Maps whole row to an option. Useful for outer joins. */
        def ? = (Rep.Some(id), Rep.Some(value)).shaped.<>({r=>import r._; _1.map(_=> RecordRow.tupled((_1.get, _2.get)))}, (_:Any) =>  throw new Exception("Inserting into ? projection not supported."))
    
        /** Database column id SqlType(int4) */
        val id: Rep[Int] = column[Int]("id")
        /** Database column value SqlType(varchar), Length(64,true) */
        val value: Rep[String] = column[String]("value", O.Length(64,varying=true))
      }
      /** Collection-like TableQuery object for table Record */
      lazy val Record = new TableQuery(tag => new Record(tag))
    }
    
Play around with it, create multiple tables, add joins then re-run the generator and see what you get - it should be instructive. Your query will change slightly to look like this instead:

    Tables.Record.result.map(println)

But your result should be the same. Enjoy!
