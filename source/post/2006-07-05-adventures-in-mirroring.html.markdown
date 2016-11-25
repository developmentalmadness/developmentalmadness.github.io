---
layout: post
title: Adventures in Mirroring
date: '2006-07-05 19:38:00'
tags:
- database_mirroring
- sql_server
---

SQL Server 2005 has introduced an exciting new feature - data mirroring. And the timing couldn't be better. This summer as we upgrade our infrastructure we're working to increase our uptime and start doing some things right. Since we don't have a DBA, I get the responsibility of improving the database availability and performance. Well mirroring is just what the doctor ordered. But as usual (is it just me?) I've hit a snag trying to get it set up and running, and got an error that either no one else is getting or no one else has posted. So as usual I am posting the specifics of my problem, and the solution in the hope of saving someone from the same problems I had.

As a note for anyone who is searching for specific instructions on setting up mirroring; this post touches mostly on a specific series of problems. However, I do touch lightly on the steps required to configure your servers. With that in mind, read on.

Because I work from home and there weren't enough development machines at the office I could work on remotely I used Virtual Sever to setup a domain on my home network to duplicate the configuration we would be using in production. I created 2 virtual servers - one was configured as a domain controller on a new domain with SQL 2005 installed, the second had only SQL Server 2005. My plan was for the latter to be the principal, the domain controller to be the mirror and my development machine to be the witness. (I understand that putting SQL server on the domain controller is a bad idea, but I've only got so much ram to be used for each virtual machine and they've all got to be running concurrently). I created a domain account for each SQL Server service and each instance was running under the same account as the other instances. For example, MSSQLSERVER was running under the same account on both new machines.

Then I made a backup of the database and restored it to the mirror with NORECOVERY. As a note, I got the following error later on, but as most are likely to get this error at this stage in their configuration I figured I'd go ahead and mention it. When I issued the SET PARTNER command from the principal server I got the following error from SSMS:

> **The remote copy of database "Advancement" has not been rolled forward to a point in time that is encompassed in the local copy of the database log.**

I found on a post (sorry, I forgot to save the URL) that this is a confirmed bug and while it's annoying the fix is simple. Just follow the directions in the error message. This is one of those times that you don't need to go searching for the solution, the error message is actually helpful. So just issue a BACKUP LOG at the principal followed by a RESTORE LOG....NORECOVERY at the mirror and run the SET PARTNER command again at the principal and you'll be fine.

However, my first time through I got hit with a different problem. When I ran SET PARTNER on the mirror, everything was dandy, but when I connected to the principal and ran the same command I got the following:

SQL Server Management Studio:

> **The ALTER DATABASE command could not be sent to the remote server instance 'TCP://HOSTNAME.FULLYQUALIFIEDDOMAIN:5022'. The database mirroring configuration was not changed. Verify that the server is connected, and try again.**

Event Log (principal):

> **Database mirroring connection error 4 'An error occurred while receiving data: '10054(An existing connection was forcibly closed by the remote host.)'.' for 'TCP://HOSTNAME.FULLYQUALIFIEDDOMAIN:5022'**

I forgot to mention that I used unattended setup on both these machines, so their SQL Server configurations were identical.

After hours of frustration I decided to install an additional instance of SQL server and run mirroring on the same server. This worked, so I was satisfied that there was a problem with the server I had planned on using as my mirror. So I attempted to configure it as the witness. This time when I ran the SET WITNESS command on the principal I got the same error from SSMS but a different, but similar message in the error log:

Event Log (principal):

> **Database mirroring connection error 4 'An error occurred while receiving data: '64(The specified network name is no longer available.)'.' for 'TCP:HOSTNAME.FULLYQUALIFIEDDOMAIN:5022'.**


According to most of the posts I found trying to investigate the problem this is a permissions error, but as I mentioned both servers were running under the same domain account. Nevertheless, I gave the domain account sysadmin priviledges on both servers and this did not correct the issue. I was able to telnet to the port 5022 (TELNET HOSTNAME 5022). I ran "netstat -a" on the target server and verified that the server was listening on port 5022. I checked the event log and verified that SQL Server was listening on port 5022. I downloaded TDIMon from sysinternals and tried to see if there were any TCP errors and nothing stood out to me. (Let me note here that I am not a networking professional and so when I say I didn't see any errors I mean that TDIMon indicated "SUCCESS" in the results column).


After a day of fighting this I couldn't find any other suggestions anywhere and I was about to post a question to a SQL Server newsgroup. But on a final hunch it occured to me that there was one thing configured differently on the target server (I'm ignoring the obvious that it was configured as a domain controller). I had setup each machine on my network with a primary and secondary DNS. The primary was the domain controller and the secondary was my router. However I had not done this on the domain controller. I had configured it with only a primary DNS, pointing to the router. I had assumed (naively) that it knew about itself. So I when in and configured the network adapter with itself as the secondary DNS. Then I went back to SSMS and ran the SET WITNESS command on the principal. Success!!!


Because of the network configuration with SQL Server installed on a domain controller this is not likely to be an issue for most. However, I think I have established that, unlike most have stated on other posts, these errors can actually indicate a network error. And in the event that the mirror or the witness cannot see the principal you are likely to see one of these errors. So make sure and verify your network layer in addition to ruling out a permissions error.


Good luck!