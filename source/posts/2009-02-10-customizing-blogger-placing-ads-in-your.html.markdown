---
layout: post
title: 'Customizing Blogger: Placing Ads In Your Template'
date: '2009-02-10 17:13:00'
---

I've been struggling lately to place ads in my blogger template. The only thing that's really worked well is using the AdSense widget. But I've been wanting to place a banner ad in my template and blogger doesn't have a widget for that. When I have tried in the past, the size of my header has increased, but the ad won't display.

Well, I tried again today and finally got a helpful error message from blogger:

> **Your template could not be parsed as it is not well-formed. Please make sure all XML elements are closed properly.
XML error message: The reference to entity "o" must end with the ';' delimiter.**

Once I read this I realized the templates are having an issue with the ampersand (&) in the src attribute of my iframe element. If my ad code looks like this:

    <iframe src="http://rcm.amazon.com/e/cm?t=development05-20&o=1&p=48&l=ur1&category=kindle&banner=0Y98S4SYN0MXZ8260582&f=ifr" width="728" height="90" scrolling="no" border="0" marginwidth="0" style="border:none;" frameborder="0"></iframe> 

Then I need to modify it like this:

    <iframe src="http://rcm.amazon.com/e/cm?t=development05-20&amp;o=1&p=48&amp;l=ur1&amp;category=kindle&amp;banner=0Y98S4SYN0MXZ8260582&amp;f=ifr" width="728" height="90" scrolling="no" border="0" marginwidth="0" style="border:none;" frameborder="0"></iframe>
