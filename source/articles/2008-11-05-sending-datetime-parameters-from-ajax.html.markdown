---
layout: post
title: Sending DateTime Parameters from AJAX to WCF Operations (methods)
date: '2008-11-05 18:37:00'
tags:
- extjs
- system_datetime
- wcf
- ajax
---

Yesterday I got stuck on a problem with a DateTime parameter I was attempting to submit to a WCF operation (method). I was trying to call call the operation using POST and the format was JSON. I was getting the value from the javascript Date object like this:

    var eventDate = new Date();
    var json = { date : "/Date(" + eventDate.getTime() + ")/" };
    // value of date would be "/Date(65746416843)/"

(yes that number is completely off the top of my head)

But after the POST operation the date on the server side was 7 hours ahead. I knew it was because I am live in the MST time zone (-7), but I couldn't find how to get WCF to parse the date with the time zone adjustment.

Here's what I finally figured out, since I was using the ExtJs library I was able to do this:

    var json = { date: "/Date(" + eventDate.getTime() + eventDate.getGMTOffset() + ")/" };

The result was json.date was "/Date(65465463546-0700)/". By appending the GMT offset WCF correctly parsed the date as it was entered.

If you're not using a javascript library you can use the javascript method getTimezoneOffset(). It will return the offset in number of minutes, so you will need to divide the result by 60 and format the string to get the correct format for your date string before you submit it to WCF.

Here's a link to the documentation, look under "Advanced information" and then "Date time wire format". http://msdn.microsoft.com/en-us/library/bb412170.aspx