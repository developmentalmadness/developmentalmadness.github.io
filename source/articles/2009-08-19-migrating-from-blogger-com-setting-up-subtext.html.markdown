---
layout: post
title: 'Migrating from Blogger.com: Setting up Subtext'
date: '2009-08-19 23:00:00'
tags:
- subtext
---

I'm really liking Subtext, so far I'm not regretting my choice to use it as my blog engine. It has been pretty simple to setup and there has been plenty of support from the community in the form of blog posts describing everything I've needed.

The most enjoyable part of it all was when Subtext didn't support what I needed it was very easy to add what I needed. 

##Setting up Subtext

You can download the deployment files or get the source code here. To deploy, you'll need to get the database connection string setup correctly for your hosting provider. This includes setting up a SQL login with db_owner permissions (you can revoke db_owner after the site is setup). Once you do, update the connection string in your web.config and then upload the files. Once the files have all been uploaded, just connect to the site and a wizard will walk you through setting up your blog and it will create the database for you.

##Using GoDaddy for hosting?

The following post was invaluable for troubleshooting problems on GoDaddy. GoDaddy runs your site under Medium Trust and this post helped me solve everyone of the problems I ran into getting things setup and running.

##Exporting to BlogML

Subtext allows you to import all your old blog posts, provided you can export them to the BlogML format. Unfortunately, Blogger doesn't really support an export of any kind to speak of. There are a few utilities out there written for you to download, install and make the conversion. But the easiest way I found was to use Blogger2BlogML. Just type in the URL of your blog and it will convert your content to BlogML and provide you with a file to download. It's fast, easy and there's nothing to install.

There's one catch here, I was disappointed to find out that Subtext doesn't use the posturl attribute in the BlogML schema. Instead Subtext generates its own slug for each post you import like this:

    newEntry.EntryName = Entries.AutoGenerateFriendlyUrl(post.PostName, newEntry.Id);

But if you don't mind patching things yourself you can make the following change to the SubtextBlogMlProvider.cs file:

    if (!string.IsNullOrEmpty(post.PostUrl))
    {
        Uri uri = new Uri(post.PostUrl);
        String fileName = uri.Segments[uri.Segments.Length - 1];
        newEntry.EntryName = Path.GetFileNameWithoutExtension(fileName);
    }
    else if (!string.IsNullOrEmpty(post.PostName))
        newEntry.EntryName = Entries.AutoGenerateFriendlyUrl(post.PostName, newEntry.Id);

You can also vote here for this patch to be included in Subtext.

Some other issues that came up when I imported:

* DateUpdated and DateSyndicated are set to the current date: I can see cases where this would be the desired behavior, but it would seem to me that most often you would use the import feature when you are setting up a new blog. In this case I wanted to keep my archive dates. 

* There were some HTML encoding issues because Blogger2BlogML doesn't wrap the content of each post in a `<!CDATA[ ]]>` section. 

However, these were both easily fixed by running the following SQL script:

    UPDATE subtext_Content SET DateUpdated = DateAdded, 
    DateSyndicated = DateAdded

    UPDATE subtext_FeedBack SET Body = REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(4000), Body), '&lt;br /&gt;', '<br />'), '&lt;BR/&gt;', '<br />'), '&amp;', '&'), '&#39;', '''')

As a disclaimer, if your posts are longer than 4000 characters you'll get your text truncated, so you'll want to use a different technique. But this worked fine for me.

##Redirecting from Blogger

Absolutely, the best way to do this is if you are using a custom domain name on blogger. This means you don't have to do a redirect at all â€“ you just point your DNS to your new hosting provider and you're pretty much done. The caveat here is that blogger uses a different URL format than Subtext.

* Blogger: http://yoursubdomain.blogspot.com/{year}/{month}/{slug}.html 
* Subtext: http://www.yourcustomdomain.com/archive/{year}/{month}/{day}/{slug}.aspx 

To redirect from blogger I had to revert my template to the Blogger classic template:

Then I added the following script to the `<head>` element:

    var bloggerUrl = document.location.href;
    var customUrl = bloggerUrl.replace(/www.developmentalmadness.com/, "www.developmentalmadness.com");
    document.location.href = customUrl;

I could have written a more involved script, but javascript is not my strength here. And Subtext already had support for what I needed to do. To support SEO friendly URLs Subtext uses a set of HttpHandler elements that accept a RegEx pattern and route the matched URL to the configured HttpHandler or ascx control. For example, to support the above Subtext URL format there is an entry in web.config that looks like this:

    <HttpHandler pattern="(?:/archive/\d{4}/\d{2}/\d{2}/[-_,+\.\w]+\.aspx)$" controls="viewpost.ascx,Comments.ascx,PostComment.ascx"/>

So I just added the following and instantly was able to support the Blogger format:

    <HttpHandler pattern="(?:/\d{4}/\d{2}/[-_,+\.\w]+\.html)$" controls="viewpost.ascx,Comments.ascx,PostComment.ascx"/>

##Avoid it if you can

I should have mentioned this above, but an important thing to note at this point is that this method is not SEO friendly. First of all, the redirect script above does a 302 direct using javascript so search engines will not follow the redirect. Second of all, using javascript to automatically redirect from Blogger to another site is likely to get your blog deleted from Blogger. Which means all the links pointing to your Blogger blog from external sites will then be broken. If you can, try and contact the webmasters of those sites pointing to your Blogger URL and ask them to fix the links.

Frankly, I should have started using a custom URL for my blogger account years ago but I can just chalk it up to lessons learned. 

A better alternative would have been to use a custom domain on Blogger before I invested so much effort in SEO and getting my blog noticed. But it really wasn't until I started really using my blog and getting more traffic that I realized that Blogger just didn't meet my needs. And I had been just too lazy (and cheap?) to purchase and setup a custom domain on blogger. In fact, if you are on blogger and haven't done it, do it now. I'll wait - it doesn't take long. Just buy a new domain (you can get one from Blogger) and then set it up on Blogger (it's very painless). Then in the future when you decide to get your blog noticed or migrate to a different blog engine you'll thank me.