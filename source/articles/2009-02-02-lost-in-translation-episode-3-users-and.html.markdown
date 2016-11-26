---
layout: post
title: 'Lost In Translation – Episode 3: Users and Schemas'
date: '2009-02-02 17:30:00'
tags:
- lost_in_translation
- oracle
- sql_server
---

In my last post I mentioned I would be addressing tables next, but as I read through the documentation I realized something. Because Oracle doesn't have the same concept of databases as SQL Server I need to use schemas to segregate my data. In order to create a schema you must create a user. When you create a user in Oracle, a schema is implicitly created. Which means I need to create a user so I can place my tables and other database objects into a schema.

I'll be using scripts in this episode instead of screenshots because scripts are more concise. There are multiple screens to each object and I didn't want to clutter this post with too many screen shots. The scripts here are pretty simple and you should be able to translate them into options in the Enterprise Manager UI.

Create a User
Creating a user isn't particularly difficult: you name the user and select a password, then you assign the user a default tablespace and temp tablespace. The following script accomplishes this for you:

    CREATE USER Northwind
      PROFILE DEFAULT 
      IDENTIFIED BY "password"
      DEFAULT TABLESPACE MyFirstOracleDb 
      TEMPORARY TABLESPACE TEMP 
      QUOTA UNLIMITED ON MyFirstOracleDb 
      ACCOUNT LOCK;

If you use the Oracle Enterprise Manager tool your user will be automatically granted privileges to connect. I've left that out of the script because I am simply creating a schema for my database objects.

QUOTA is a way of allocating space limits to a user. If you forget this you won't be able to create any tables or other objects in this schema because by default the user gets allocated nothing and cannot do anything until an allocation limit is specified.

You'll also notice that my CREATE USER statement ends with “ACCOUNT LOCK”. Again, right now I'm creating a user for the schema, I don't plan on allowing this user to login. I'm not sure what the recommended practice here is, but I did read that when you want to delete a user you have to delete the schema and all associated objects with it. So I plan on placing all my objects into schemas which are not associated with an active user. This will allow me to manage users without worrying about affecting my database objects.

An important thing to note is that you need to be careful with quoted identifiers. If you're using the “Show SQL” button in Enterprise Manager you'll notice that all object names are quoted. The trouble you'll run into here is that if you create an object using a quoted identifier you're always required to use quotes when referencing that object. To quote from the Oracle documentation “Schema Object Names and Qualifiers”:

A quoted identifier begins and ends with double quotation marks ("). If you name a schema object using a quoted identifier, then you must use the double quotation marks whenever you refer to that object.

So if your create user script looks like this:

    CREATE USER "Northwind"
      PROFILE DEFAULT
      IDENTIFIED BY "password"
      DEFAULT TABLESPACE MyFirstOracleDb 
      TEMPORARY TABLESPACE "TEMP" 
      QUOTA UNLIMITED ON MyFirstOracleDb 
      ACCOUNT LOCK;

Then your CREATE TABLE script must look like this:

    CREATE TABLE "Northwind".Customer ( 
      CustomerID INTEGER NOT NULL , 
      CustomerName VARCHAR2(50) NOT NULL , 
      CONSTRAINT PK_CUSTOMER PRIMARY KEY (CustomerID) VALIDATE 
    ) ORGANIZATION INDEX TABLESPACE MyFirstOracleDb;
    
And if your CREATE TABLE script looks like this:

    CREATE TABLE "Northwind"."Customer" ( 
      CustomerID INTEGER NOT NULL , 
      CustomerName VARCHAR2(50) NOT NULL , 
      CONSTRAINT PK_CUSTOMER PRIMARY KEY (CustomerID) VALIDATE 
    ) ORGANIZATION INDEX TABLESPACE MyFirstOracleDb;

Then your SELECT, INSERT, UPDATE and DELETE statements will look like this:

    SELECT * FROM "Northwind"."Customer"
    INSERT INTO "Northwind"."Customer" ....
    UPDATE "Northwind"."Customer"....
    DELETE FROM "Northwind"."Customer" ...

Plus, when you use quoted identifiers your object names are case-sensitive. So “northwind” and “NORTHWIND” would both cause errors in your SQL scripts.

When you create your objects in Enterprise Manager they won't require quoted identifiers and they'll be case-insensitive. So you're safe there, just be careful when using Enterprise Manager as a learning tool for writing scripts.


#Create a table

I'm not going into go into detail about tables until my next post. For now lets just create a simple table so we can grant our user access to that table. Otherwise our user won't have permission to do anything but connect. So far, Oracle seems to be really good at not doing anything unless you explicitly tell it too. This can bite you, but as far as security goes it is certainly the right way to do it.

    CREATE TABLE Northwind.Customer (
      CustomerID INTEGER NOT NULL,
      CustomerName VARCHAR2(50) NOT NULL,
      CONSTRAINT PK_Customer PRIMARY KEY (CustomerID) VALIDATE
    ) ORGANIZATION INDEX TABLESPACE MyFirstOracleDb;

#Create a role

Since as a general practice it is best to assign privileges to roles and not users, we're going to go ahead and create a role and grant it permission to access our table:

    CREATE ROLE NorthwindPublic NOT IDENTIFIED;
 
    GRANT SELECT ON Northwind.Customer TO NorthwindPublic;

#Create a application user

Now with a few small differences from our first user we'll create a user which can connect to our database:

    CREATE USER NorthwindUser
        PROFILE DEFAULT
        IDENTIFIED BY "password"
        DEFAULT TABLESPACE MyFirstOracleDb
        TEMPORARY TABLESPACE TEMP
        ACCOUNT UNLOCK;
     
    GRANT CONNECT TO NorthwindUser;
    GRANT NorthwindPublic TO NorthwindUser;

Here we've got an unlocked user, with no quota that can connect to our database and read data from our Customer table. If we want to give the user the ability to modify data we can update the role we created.

#Connecting to the database

To connect with our new user, fire up SQL Developer from START –> Programs –> Oracle –> Application Development –> SQL Developer. Then select File –> New… –> Database Connection and enter your information like in the screenshot below:

![](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2009/02_02/Oracle_NewConnection_thumb.png)

Click connect, then File –> New… –> SQL File. Click OK, then OK again to open a new script file. Type the following in the script window:

    SELECT * FROM Northwind.Customer;

Hit F5 and you'll get a “select connection” prompt. Select the connection we just created and hit “OK”. There won't be any data, but you should get a success message. Go ahead and play with this for now and I'll have more on creating tables followed by DML statements in Oracle in the next episode.
