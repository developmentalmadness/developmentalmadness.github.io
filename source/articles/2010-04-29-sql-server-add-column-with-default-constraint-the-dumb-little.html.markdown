---
layout: post
title: 'SQL Server add column with DEFAULT CONSTRAINT: The Dumb Little Things'
date: '2010-04-29 15:20:00'
tags:
- sql_server
- t-sql
- ddl
---

Sometimes you think you know and then when you go and open your big mouth and make a fool of yourself. 

<img src="https://s3-us-west-2.amazonaws.com/dvm-public-assets/images/2010/04_29/dumb-and-dumber-400.jpg" style="border-right-width:0px;display:inline;border-top-width:0px;border-bottom-width:0px;border-left-width:0px" title="Dumb happens" border="0" align="right" width="400" height="300" />

I generally script all my database changes by hand. Not 100%, if it’s a big change I’ll right-click the object and use the script menu command to generate a script I can paste into my script editor. But often if I’m creating new objects I’ll write the script by hand from scratch.

Last week I needed to add a column to three separate tables and the column was not nullable. So as I have done so many times in the past, I proceeded to drop all dependent objects, create a temp table with the new table structure, copy the data, drop the old table, rename the temp table and proceed to recreate all dependent objects (triggers, constraints, indexes). The script for each table was pretty long.

But yesterday the deployment script I wrote wouldn’t run in the QA environment. And someone asked why I didn’t just use the ALTER TABLE [tablename] ADD [column] syntax and do it all in one line.

My response was the column wasn’t nullable. The answer was, “use a default constraint”. To which I responded that default constraints don’t add the default data to existing rows, only on new inserts. Hence I couldn’t use that technique.

I was so sure, I went back to my desk to write a script to prove I was right. I wrote the following script:

    CREATE TABLE ColumnTest (
        Id INT IDENTITY(1,1),
        Name VARCHAR(10)
    )
     
    INSERT INTO ColumnTest(Name) VALUES ('Mark')
    INSERT INTO ColumnTest(Name) VALUES ('eSteve')
    INSERT INTO ColumnTest(Name) VALUES ('Tyler')
    INSERT INTO ColumnTest(Name) VALUES ('Jason')
    INSERT INTO ColumnTest(Name) VALUES ('Chad')
    INSERT INTO ColumnTest(Name) VALUES ('Mike')
    INSERT INTO ColumnTest(Name) VALUES ('Nick')
     
    ALTER TABLE ColumnTest ADD AreaCode CHAR(3) DEFAULT('801')
     
    SELECT * FROM ColumnTest
     
    DROP TABLE ColumnTest

The result of the SELECT proved that the column “AreaCode” was null. But then I noticed I hadn’t set the column to “NOT NULL”. So I modified the script like this:

    CREATE TABLE ColumnTest (
        Id INT IDENTITY(1,1),
        Name VARCHAR(10)
        
    )
     
    INSERT INTO ColumnTest(Name) VALUES ('Mark')
    INSERT INTO ColumnTest(Name) VALUES ('eSteve')
    INSERT INTO ColumnTest(Name) VALUES ('Tyler')
    INSERT INTO ColumnTest(Name) VALUES ('Jason')
    INSERT INTO ColumnTest(Name) VALUES ('Chad')
    INSERT INTO ColumnTest(Name) VALUES ('Mike')
    INSERT INTO ColumnTest(Name) VALUES ('Nick')
     
    ALTER TABLE ColumnTest ADD [State] CHAR(2) NOT NULL DEFAULT('UT')
    ALTER TABLE ColumnTest ADD AreaCode CHAR(3) DEFAULT('801')
     
    SELECT * FROM ColumnTest
     
    DROP TABLE ColumnTest

Boy was I surprised! I can’t believe I never knew this. Could you imagine the time I could have saved. I hate adding not nullable columns!

My theory is that this was not always the case and that somewhere along the line (2005, 2008) this was added because of the pain involved in adding columns which could not be null.

Anyway, it was a humbling experience and not one I’ll forget.
