---
layout: post
title: 'Lost in Translation – Episode 2: Tablespaces'
date: '2009-01-29 17:38:00'
tags:
- lost_in_translation
- oracle
- tablespaces
- sql_server
---

In Episode 1 I addressed database instances but I'd like to correct a technicality. I compared SQL Server instances with Oracle Database instances. While this is pretty much correct, I'd like to add that technically this isn't correct. At least not according to Oracle's documentation. If you look on your installation disk for the docs directory I recommend reading the **2 Day DBA** document. So far I'm finding it very valuable.

Here's a quote from the Chapter 2 overview:

> After you create a database, either during installation or as a 
standalone operation, you do not need to create another. Each Oracle 
instance works with a single database only. Rather than requiring that 
you to create multiple databases to accommodate different 
applications, Oracle Database uses a single database, and 
accommodates multiple applications by enabling you to separate data 
into different schemas within the single database.

According to the docs, an instance of Oracle is the same as a database. This is really all about semantics here, because I still view my original viewpoint as correct. But I also want to make sure what I post here is correct. To reference my language analogy from the first episode, two words or phrases from different languages can be considered direct translations, but there can often be cases where there is a better translation. That doesn't make the translation incorrect. That's the case here and it will be in other comparisons I make. I see it as a many to many relationship between terms in language as well as RDBMS vendors.

#Tablespaces

From reading the documentation I would translate the term Tablespace in Oracle as a SQL Server database. To quote from the documentation:

A database is divided into logical storage units called tablespaces, which group 
together related logical structures (such as tables, views, and other database objects).

Which sounds like the definition of a database to me. An Oracle instance comes with a set of default tablespaces installed. EXAMPLE, SYSTEM, SYSAUX, TEMP, UNDOTBS1 and USERS.

* EXAMPLE is an optional tablespace. Example is analogous to Northwind and is used by samples and the documentation to provide guidance and a source for demos.
* SYSTEM is Oracle's version of SQL Server's master database. It is a master catalog of the objects in the database.
* SYSAUX is a compliment to System and is used to reduce the demand on System by offloading some of its data into a separate data file, which could be placed on separate physical drive to increase system performance.
* TEMP is basically the same as SQL Server.
* UNDOTBS1 is related to undo files, which are like SQL Server transaction logs. I'm not real clear on how this tablespace is used with undo files yet, I'm just pretty much rehashing the documentation here.
* USERS is a user tablespace. If you create a database object and don't have your own tablespace or don't specify which tablespace your object will be stored in then it will be stored in USERS. SQL Server doesn't have an equivalent here. SQL Server requires you to create a user database for your data and when you create an object, unless you use a fully-qualified object name the object you create will be placed in whichever database you're connected to.

Each of the built-in tablespaces has its own data file and each user tablespace you create will contain one or more data file.

Just to touch on the system tables in SQL Server for a second, SQL Server also has two other system databases named “model” and “msdb”:

* **model** is actually attached to an instance of SQL Server and there is no equivalent tablespace in Oracle. However, Oracle does have a different way of accomplishing the same thing. The DBCA has templates you can use, both default and user defined which can be used to create a new Oracle Database Instance.  This is generally the purpose of SQL Server's model database, to act as a template for new user databases.
* **msdb** is where objects like scheduled jobs are stored. I don't know the exact correlation with Oracle, I imagine these are either in SYS or SYSAUX. But since I don't know what is stored in the specific system tables in Oracle, I can't make the comparison at this time.

#Creating Tablespaces

Creating a new tablespace using the Oracle Enterprise Manager is much like it is in SQL Server, the options are very similar and once you locate the tools for creating a tablespace the rest should come naturally, assuming of course you're familiar with how this is done in SQL Server.

If you're logged into Enterprise Manager, click on the “Server” link located in the top nav bar. Then click on “Tablespaces” under the “Storage” heading.

![](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2009/01_29/OracleTablespaces_thumb.jpg)

To create a new tablespace, click “Create” located just above the list of tablespaces.

![](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2009/01_29/Oracle_CreateTablespace_thumb%5B1%5D.jpg)

One the next screen, name the tablespace and accept the default settings. But before saving the settings, you need to add a data file:

![](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2009/01_29/Oracle_CreateTablespaceGeneral_thumb%5B2%5D.jpg)

After clicking the “Add” button, fill out the file name, check the AUTOEXTEND option and set the amount the file will grow by each time you exceed the currently allocated file space. Unfortunately, Oracle doesn't have a option to grow by percent, which is what I always select in SQL Server. Once you're selected the options, click “Continue”.

![](https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2009/01_29/OracleEM_AddDatafile_thumb.jpg)

Before saving these changes, click “Show SQL” at the bottom right. You can skip this step, of course, but I usually script my own DDL in SQL Server and so I want to learn the syntax by looking at what is generated by Enterprise Manager. Here's what you'll see:

    CREATE SMALLFILE TABLESPACE "MYFIRSTORACLEDB" DATAFILE 'C:\APP\MARK\ORADATA\ORACLE11\DataFile1' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED LOGGINGEXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO DEFAULT NOCOMPRESS

To return to “Create Tablespace”, just click “Return”. Now click “OK” and you're set. You've created your tablespace.

#Conclusion

Now you can either script a tablespace or use the GUI to create one. Either way, you've done the equivalent of creating a SQL Server database file by creating your own Oracle tablespace. Next episode, we'll look into creating tables. I don't know about you, but already I feel like things have cleared up considerably and I'm much farther along. Once we've created our database objects we'll look into connecting to our database from a client application and writing DML statements against our schema. Then we can look at other database objects like views, procedures, functions, triggers. These are obviously the same as SQL Server, but will of course have their own syntax and that's what we'll focus on at that point.
