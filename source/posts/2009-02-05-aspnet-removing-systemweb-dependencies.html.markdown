---
layout: post
title: 'ASP.NET: Removing System.Web Dependencies'
date: '2009-02-05 17:21:00'
tags:
- net_framework_3_5
- asp_net
---

As a general rule I prefer to avoid referencing System.Web in my library classes. But if it can't be avoided it's still a good idea to avoid the use of HttpContext.Current. It must be nice to live in a perfect world you say? Yes, there are times that even this cannot be avoided. Or can it?

Yes, it is possible by wrapping HttpContext.Current with a helper library which exposes only the methods required by your library. But there are times when even this is an arduous task at best. So what's a guy to do?

#System.Web.Abstractions
Well, it just got easier. If you haven't been following the development of the [ASP.NET MVC](http://www.asp.net/mvc) project you probably haven't heard about the System.Web.Abstractions assembly.

ASP.NET MVC has been built from the ground up with testability in mind, and they have created abstract classes for all the ASP.NET intrinsic objects: HttpContext, HttpRequest, HttpResponse, etc. These classes are named [HttpContextBase](http://msdn.microsoft.com/en-us/library/system.web.httpcontextbase.aspx), [HttpRequestBase](http://msdn.microsoft.com/en-us/library/system.web.httprequestbase.aspx), [HttpResponseBase](http://msdn.microsoft.com/en-us/library/system.web.httpresponsebase.aspx) respectively.

What would be nice is if the ASP.NET intrinsic objects actually inherited from these abstract classes. I think that this will happen eventually. In fact System.Web.Abstractions is no longer just an MVC library, it shipped with [.NET 3.5 SP 1](http://msdn.microsoft.com/en-us/vstudio/cc533448.aspx) and the [Dynamic Data libraries for ASP.NET](http://www.asp.net/dynamicdata/) are using it as well. I think the only reason this hasn't happened yet is timing. I wouldn't be surprised to find this change make it into the .NET 4.0 Framework.

Until that time how do we get the benefit of these wonderful abstractions so our code can be more testable and reduce unnecessary dependencies on System.Web?

#HttpContextWrapper et al

Also part of System.Web.Abstractions are a set of wrapper classes, which are concrete implementations of the new System.Web abstract base classes. They're named (gasp) HttpContextWrapper, HttpRequestWrapper, HttpResponseWrapper, etc.

Each of these wrapper classes exposes a constructor which accepts an argument which corresponds to the intrinsic object it wraps. So you can create a new instance like so:

    HttpContextWrapper context = new HttpContextWrapper(HttpContext.Current);

It's just that easy. So how do we take advantage of these classes to achieve our goals?

Depending on your needs there are a few different ways you could implement this. If your classes are being used as instance variables by client applications then it could be very easy to add an argument to your constructor:

    public class MyClass
    {    
        private HttpContextBase m_context;
        public MyClass(HttpContextBase context)
        {
            m_context = context;
        }
    }

You could then use it like this from your web application:

    MyClass foo = new MyClass(new HttpContextWrapper(HttpContext.Current));

Or you could use the factory pattern

    public class HttpContextFactory
    {
        private static HttpContextBase m_context;
        public static HttpContextBase Current
        {
            get
            {
                if(m_context != null)
                    return m_context;
     
                if(HttpContext.Current == null)
                    throw new InvalidOperationException("HttpContext is not available");
     
                return new HttpContextWrapper(HttpContext.Current);
            }
        }
     
        public static void SetCurrentContext(HttpContextBase context)
        {
            m_context = context;
        }
    }

This implementation removes the burden on the client app to pass the context to your objects. The only time you'll need to use the SetCurrentContext method is in your unit tests, the rest of the time you can just forget HttpContextFactory is even there.

#Conclusion

Other variations on this could use dependency injection or inversion of control, but no matter how you implement it you no longer are dependent on your library being run in an IIS process.
