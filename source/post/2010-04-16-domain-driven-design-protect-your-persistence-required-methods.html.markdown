---
layout: post
title: 'Domain-Driven Design: Protect your persistence required methods'
date: '2010-04-16 14:29:00'
tags:
- ddd
- domain-driven-design
- explicit-interface-implementation
---

I've been reading up on Domain-Driven Design (DDD) lately and I've checked out Jimmy Nilsson's book [Applying Domain-Driven Design and Patterns: With Examples in C# and .NET](http://my.safaribooksonline.com/0321268202). I was reading Ch 5, "Moving Further with Domain-Driven Design" and Jimmy is talking about reconstituting your entity from persistence.

Specifically, he's talking about the situation where your entity has read-only fields that must be provided by your persistence layer, but that you don't want to make public. For example, the entity's ID field. This is definitely a read-only field, but you have to set it at some point when querying the data from your data store.

In recent projects I have provided a separate constructor and documented it (read: comments) as "reserved for persistence only". Also, in some cases, instead of providing a set property method for the ID I have created a method which allows the Id to be set. Something like SetIdFromPersistence() to make it clear that Id is intended as a read-only field.

    public class Customer {
        ///<summary>
        /// This is reserved for use by the repository
        ///</summary>
        public Customer(int id, string name){
        
        }
        
        ///<summary>
        /// This is open for public use to create a new customer
        ///</summary>
        public Customer(string name){
        
        }
        
        public int Id { get; private set; }
        
        ///<summary>
        /// This is reserved for use by the repository,
        /// Id is read-only and using this inappropriately 
        /// could result in data corruption issues.
        ///</summary>
        public void SetIdFromRepository(int id){
            Id = id;
        }
    }

This is because, my persistence layer and my model are in separate assemblies. I've considered using reflection to allow me to make the setters and ctors I've provided private. But I've never really liked this. So I've just tried to make it clear what the use cases are for these methods.

But then something Jimmy said triggered and idea for me and I want to see what everyone else thinks.

#Explicit Interface Implementation

I haven't run into many developers who've heard of this, but you may have noticed this when using some of Visual Studio 2008's code editing tools (I don't know if this exists in previous versions of VS, I only discovered it in v. 2008). But if you're editing a class which implements an interface and you select the interface with your cursor you'll see that below the interface is an "auto correct" icon/sprite. If you click it or hit ALT+SHIFT+F10 you'll get a couple options:

* Implement interface ‘ISomeInterface'
* Explicitly implement interface ‘ISomeInterface'

If you select the first option, you'll get public method/property stubs created in your class for you with the correct method signatures. If you click the second option you'll see something similar, but you may have to look closer to see the difference (go ahead, I'll wait)… Ok, you back? Did you notice the difference? Here's what you should have seen. Given the following interface:

    public interface IMyInterface {
        void MyMethod(int id);
        int MyProperty { get; set; }
    }

The first option would generate the following implementation:

    public MyClass : IMyInterface {
        public void MyMethod(int id){
            throw new NotImplementedException();
        }
        
        public int MyProperty{
            get{ 
                throw new NotImplementedException();
            }
            set{
                throw new NotImplementedException();
            }
        }
    }

And the second option (explicit) would generate this implementation:

    public MyClass : IMyInterface {
        void IMyInterface.MyMethod(int id){
            throw new NotImplementedException();
        }
        
        int IMyInterface.MyProperty{
            get{ 
                throw new NotImplementedException();
            }
            set{
                throw new NotImplementedException();
            }
        }
    }

Notice the differences in the second implementation? Let me help:

* Not public members
* each member name is prefixed with IMyInterface

These members are only visible when the class is explicitly used/cast as IMyInterface. Here's two examples:

    public void SomeMethod(IMyInterface obj){
        obj.MyMethod(2);
    }
     
    public void SomeMethod2(MyClass obj){
        int x = ((IMyInterface)obj).MyProperty;
    }

So the explicit members will never show up in the public interface. I first ran into this years ago, when I was working with a FCL class which I knew implemented a specific interface, but when I tried calling a member of the interface I couldn't compile the application. An example of this is IConvertable on the Int32 type:

    int i = 33;
    i.ToInt32();                    //compile error
    ((IConvertable)i).ToInt32();    //compiles

**CREDIT**: I couldn't remember any FCL examples of this, so I had to search and found the above example on Brad Abram's blog.

The guidlines for this can also be found on the same post by Brad:

* Do use explicit members to hide implementation details
* Do use explicit members to approximate private interface implementations.

For reference, here are some links on Explicit Interface Implementation:

* [Explicit Interface Implementation (C# Programming Guide)](http://msdn.microsoft.com/en-us/library/ms173157(VS.80).aspx)
* [Explicit Interface Implementation Tutorial](http://msdn.microsoft.com/en-us/library/aa288461(VS.71).aspx)

#Exposing Private Members

Now back to our discussion on preventing the methods needed by our persistence layer from being called by consumers of our entities.

Explicit interfaces can be used to hide members that aren't intended to be called directly by consumers of the object, eg. "Not intended for public use".

Can you use this method to prevent consumers from calling your methods at all? No. The interface will be public so you can use it from your persistence layer and it will need to follow your entities around. Most likely it will be a public interface located in the same assembly as your model. However, marking the members as private doesn't keep consumers from calling them using reflection. This is the solution Jimmy uses to access the private members in his example. He might use something different later on, I get the impression he might use another technique once I read further into the book.

But this technique will be more efficient and more clean than using reflection. Also, if you are running in a medium-trust environment where calling private members is blocked this technique will still work.

**CAVEAT**: When I read Brad Abram's post I noticed a comment below indicating that if you use this technique with a struct instead of a class you will encounter boxing/unboxing issues. This is an important consideration to keep in mind. Does boxing cost more than using reflection? I don't know, I'll leave that exercise to the user.
