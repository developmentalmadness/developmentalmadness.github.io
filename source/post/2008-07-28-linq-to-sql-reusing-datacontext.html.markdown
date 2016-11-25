---
layout: post
title: 'LINQ to SQL: Reusing DataContext'
date: '2008-07-28 17:57:00'
tags:
- dlinq
- linq_to_sql
- system_data_linq_datacontext
- system_transactions
- transactionscope
---

I have been working on a project which uses a data access layer (DAL) to wrap some LINQ to SQL calls to the database. While I've played with LINQ to SQL a bit, this was my first time working on a production application. So as I wrote some of the business logic I wrapped some updates in a transaction (as any good database dev would do). Here's pretty much what it looked like:

    public void Swap(Product x, Product y)
    {
      x.DisplayIndex += y.DisplayIndex;
      y.DisplayIndex = x.DisplayIndex - y.DisplayIndex;
      x.DisplayIndex -= y.DisplayIndex;
    
      using( System.Transactions.TransactionScope txCtx = new System.Transactions.TransactionScope() ) {
        x.Save();
        y.Save();
    
        txCtx.Complete();
      }
    }
    
Here's what the save method looked like:

    public Product Save(Product product)
    {
      MyAppDataContext context = new MyAppDataContext("connection string");
    
      Product oldProduct = context.Products.Single( p => p.ProductId == product.ProductId);
    
      if(oldProduct == null){
        context.Products.InsertOnSubmit(product);
      } else {
        oldProduct.Name = product.Name;
        oldProduct.Price = product.Price;
        oldProduct.DisplayIndex = product.DisplayIndex;
      }
      context.SubmitChanges();
    
      return product;
    }
    
This worked fine until I moved my changes out to staging. Where I promptly was given an exception:

    System.Transactions.TransactionManagerCommunicationException was unhandled by user code
    Message="Communication with the underlying transaction manager has failed."
    Source="System.Transactions"

As it turns out, my development machine had Network DTC access turned on (Administrative Tools --> Component Services --> Component Services --> Computers --> (right click) --> properties... --> MSDTC --> Security Configuration... --> Network DTC Access

It had been turned on while I had been doing some tinkering with an SSIS project. So because my machine allowed network DTC calls, I had not recieved any errors. But because it was turned off (the default) on the staging web server it caused an error.

The reason for the error is that each call to my Save method used a different DataContext, each with its own Connection object. The first call to Save opened a Connection and saved the changes. Then when the second call did the same thing it tried to enlist the second connection in a transaction with the first. In order to do this DTC was needed. This worked on my machine, because it was enabled, but not on the web server which was disabled.

After talking to the developer who wrote the DAL I tried to think of how I could come up with a way to use the same DataContext. The EnterpriseLibrary already does this, so there should be a solution somewhere. I started looking into Thread Local Storage (TLS) and found this article, indicating the pitfalls of using TLS in ASP.NET. After reading the article I determined that HttpContext.Current.Items was the place to store my DataContext for the lifetime of the page request. The reason is that there are several cases where the thread context will change in the lifetime of a page request (async methods, page_load, application events).

So I decided I needed a DataContextFactory. To accomplish this, I chose to add a partial class to the DAL with a single method GetDataContext(). If you look at the designer file (C# designer.cs, VB.NET designer.vb) for a dbml file you'll find that the DataContext class generated for your dbml file is a partial class. So my partial class looks like this:

    public partial class MyAppDataContext{
      public static MyAppDataContext GetDataContext(){
        if(HttpContext.Current == null)
          return new MyAppDataContext("connection string");
    
        if(HttpContext.Current.Items.Contains("DataContext")){
          return (MyAppDataContext) HttpContext.Current.Items["DataContext"];
        }
    
        MyAppDataContext context = new MyAppDataContext("connection string");
        HttpContext.Current.Items.Add("DataContext", context);
        return context;
      }
    }
    
After, I did this my call to TransactionScope works. Plus, I was able to eliminate the additional database call in my save method because I am now using the same DataContext throughout the entire lifecycle of the page request. The save method now looks like this:

    public Product Save(Product product)
    {
      MyAppDataContext context = new MyAppDataContext("connection string");
    
      if(product.ProductId <= 0){
        context.Products.InsertOnSubmit(product);
      context.SubmitChanges();
    
      return product;
    }

It is important to note that the code for the Save method is auto generated. So this code could be used within the company for either a web application or a winforms app. For this reason, I needed a solution which would work in both situations. Or that would at least allow me to provide an alternate solution in the event the application requires one. Plus, I wasn't really happy about adding a reference to the System.Web assembly in my DAL.

So I created the following interface and provider:

    using System;
    
    namespace DataAccess
    {
        public interface IThreadLocalStorageProvider
        {
            void SaveItem ( String key, Object value );
            Object GetItem ( String key );
            Boolean ContainsItem ( String key );
        }
    
        public class ThreadLocalStorageProviderFactory
        {
            private static IThreadLocalStorageProvider _provider;
    
            public static IThreadLocalStorageProvider Current
            {
                get
                {
                    return _provider;
                }
                set
                {
                    _provider = value;
                }
            }
        }
    }
    
By creating a provider with a static reference to an interface, the application can define during startup how it will provide thread local storage without any changes required to the DAL. So for our web application we came up with this handy little class:

    namespace RioTintoWebSolution
    {
        public class WebThreadLocalStorageProvider : IThreadLocalStorageProvider
        {
            #region IThreadLocalStorageProvider Members
    
            public void SaveItem ( string key, object value )
            {
                HttpContext.Current.Items.Add( key, value );
            }
    
            public object GetItem ( string key )
            {
                return HttpContext.Current.Items[key];
            }
    
            public bool ContainsItem ( string key )
            {
                return HttpContext.Current.Items.Contains( key );
            }
    
            #endregion
        }
    }
    
And in the Appilcation_Start event in global.asax.cs we now do this:

    protected void Application_Start(object sender, EventArgs e)
    {
      ThreadLocalStorageProviderFactory.Current = new WebThreadLocalStorageProvider();
    }
    
And our DataContext factory method looks like this:

    public partial class MyAppDataContext
    {
        public static MyAppDataContext GetDataContext ()
        {
            // if TLS isn't available just return a new DataContext
            if ( ThreadLocalStorageProviderFactory.Current == null )
                return new MyAppDataContext( "connection string" );
    
            MyAppDataContext context = null;
    
            // check to see if DataContext already exists in TLS
            if ( ThreadLocalStorageProviderFactory.Current.ContainsItem( "DataContext" ) )
            {
                // get DataContext
                context = ThreadLocalStorageProviderFactory.Current.GetItem( "DataContext" ) as MyAppDataContext;
    
                // verify DataContext
                if ( context != null )
                    return context;
            }
    
            // if we got here, then just create a new DataContext
            context = new MyAppDataContext( "connection string" );
    
            // cache the DataContext
            ThreadLocalStorageProviderFactory.Current.SaveItem( "DataContext", context );
    
            // return to caller
            return context;
        }
    }
    
And finally, just to be safe I also decided to verify that the DataContext get cleaned up, I added the following to our Appliction_EndRequest event:

    protected void Application_EndRequest(object sender, EventArgs e)
    {
        if ( ThreadLocalStorageProviderFactory.Current.ContainsItem( "DataContext" ) )
        {
            DataContext ctx = ThreadLocalStorageProviderFactory.Current.GetItem( "DataContext" ) as DataContext;
            if ( ctx != null && ctx.Connection.State == ConnectionState.Open )
            {
                ctx.Dispose();
            }
        }
    }
    
Finally, I wanted to confirm that what I was doing wasn't going to bite me. So I searched around the net abit and found this post by Rick Strahl. Rick's solution is more 'generic', but at the same time I prefer the ProviderFactory pattern over the utility class with specialized methods (ie. GetWebRequestScopedDataContext and GetThreadScopedDataContext). Everybody has their preferences, and I'm certainly not trying to disparage Nick in any way. His method, is excellent, and he makes it easy to use multiple different DataContexts within the same thread. The reason I prefer the ProviderFactory is becuase it is more generic, so I don't have to change my method calls when I move my DAL to a winforms app. And I can still add the same features he uses to create more flexibility.
