---
layout: post
title: SQL Server 2005 Unattended Install
date: '2006-06-30 19:41:00'
tags:
- sql_server
- dba
---

As always I try and post about my experiences which cause my biggest headaches. So today's topic is about setting up an unattended install for SQL Server 2005. I have spent the entire day trying to create an unattended install to a Virtual Server installation.

> **Error: Invalid INI file. Make sure the file exists, have access and has the correct entries.**

This one still does not make sense to me. First, I had the INI file in the same directory (Desktop) as my setup .bat file. And I had the command window open to the same directory as well. So I figured it required a fully qualified path. So I figured it was the spaces in the path "C:\Documents and Settings\Mark\Desktop\setupSql05.ini" and I put quotes around it. Still no go. So finally, I just dumped the file in the root and updated my .bat file as follows:

    D:\Servers\Setup.exe /settings "C:\setupSQL05.ini" /qb

And that did the trick!

> **Error: SQL Server Setup could not validate the service accounts**

I'm sure there are a number of reasons why you might see this error. But in my case it was stupidity brought on by fatigue. I created 3 domain accounts: {domain}\SqlServer, {domain}\SqlAgent, and {domain}\SqlBrowserAgent. I set the password to never expire, except on SqlBrowserAgent. It turns out I forgot to change this when I created the account. The nice thing was that I was able to determine the account by checking the setup log file "C:\Program Files\Microsoft SQL Server\90\Setup Bootstrap\LOG\SqlSetupXXXX.cab\{hostname}_SQL.log". I opened it in notepad, did a find for my domain name ( "{domain}\" ) and found the error in the log. Once I opened up the settings for the account in question it was obvious.

Sometimes it just doesn't pay to get out of bed!

> **Error: The feature(s) specified are not valid for any SQL Server products**

Again, the log file came in for a save here. Silly me, I used the documentation to create my INI file! According to BooksOnline for the ADDLOCAL parameter, Notification_Services has a 3 child features: NS_Engine,NS_Client,NS_Rules. So because I wanted to install Notification Services I passed all three to the argument. However, when I got the above error and verified that I had spelled everything correctly (including case) and had no spaces I was stumped. So I checked the error log ({hostname}_SQL_Core(Local).log) and found this:

> **Failed to find feature:NS_Rules : 70002**

So I opened the template.ini file that comes with the installation disk and found that in truth, NS_Rules does not exist. Greatful for install logs I removed the feature from the list and ran install again. Only for the same error to strike again! This time the culprit was SQL_Profiler90, also in the BOL docs I might add.

> **Failed to find feature:SQL_Profiler90 : 70002**

So make sure you don't fall for the same trap as I did!

#Success at last!

Here is my successfull settings INI file (don't forget to add the [PIDKEY] option):


    [Options]
    
    
    
    USERNAME=Admin
    
    COMPANYNAME="MaxPreps, Inc."
    
    
    
    ADDLOCAL=SQL_Engine,SQL_Data_Files,SQL_Replication,SQL_FullText,Notification_Services,NS_Engine,NS_Client,Client_Components,Connectivity,SQL_Tools90,SQLXML
    
    
    INSTANCENAME=MSSQLSERVER
    
    
    
    SQLBROWSERACCOUNT="{domain}\SqlBrowserAgent"
    
    SQLBROWSERPASSWORD=***********
    
    
    
    SQLACCOUNT="{domain}\SqlServer"
    
    SQLPASSWORD=***********
    
    
    
    AGTACCOUNT="{domain}\SqlAgent"
    
    AGTPASSWORD=***********
    
    
    
    SQLBROWSERAUTOSTART=1
    
    SQLAUTOSTART=1
    
    AGTAUTOSTART=1
    
    
    
    SQLCOLLATION=SQL_Latin1_General_CP1_CI_AS
    
    
    
    ERRORREPORTING=0


I hope this helps anyone out there who's struggling. And can I just say, thank goodness for Virtual Server!
