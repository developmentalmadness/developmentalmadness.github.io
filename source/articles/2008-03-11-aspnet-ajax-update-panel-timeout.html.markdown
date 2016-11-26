---
layout: post
title: ASP.NET AJAX - Update Panel Timeout
date: '2008-03-11 19:16:00'
tags:
- asp_net_ajax
- asp_updatepanel
---

When using the `asp:UpdatePanel` server control for asyncronous communication with the web server the default timeout is 90 seconds. For some processes this may not be long enough.

For example, I am currently working on a reporting application and at the moment I have to query a table with over 36 million records. Some queries take longer than 90 seconds. But unfortunately I had trouble finding out how to extend this.

It turns out that this is a page-level setting. The `asp:ScriptManager` server control has a property named `AsyncPostBackTimeout`. Set this value to the number of seconds you need to resonably run the process in question and you'll be fine.

    <asp:scriptmanager id="scriptManager1" runat="server" enablepartialrendering="true" asyncpostbacktimeout="1000"></asp:ScriptManager>