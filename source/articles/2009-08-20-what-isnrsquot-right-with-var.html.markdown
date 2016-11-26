---
layout: post
title: What isn't RIGHT with var
date: '2009-08-20 23:22:00'
tags:
- anonymous_types
- var
- linq
- intellisense
---

Let me start by saying I have no qualms against using var to declare variables. I use it myself when it suits me. I find the best situations to take advantage of it are:

* When using anonymous types 
* When declaring variables which are instances of an interface 

The first case is really not optional. You can't declare an anonymous type without var. The second, should be used carefully because it can impede readability if used incorrectly. Since you cannot initialize an interface the right side of your declaration might not be clear that your intention is to declare a variable which is an interface implementation. Here's a comparison of good and bad use in this case:

##Bad Example

    public interface IMyInterface { }
    public class ConcreteImplementation : IMyInterface {}
    public class MyClass 
    {
        public ConcreteImplementation ReturnsAnInterfaceImplementation(){}
    }
    
    public class MyApplication()
    {
        public static void Main()
        {
            var myVar = someInstance.ReturnsAnInterfaceImplementation();
            DoSomething(myVar);
        }
    
        public static void DoSomthing(IMyInterface arg) { }
    }

This example is a bit contrived but not entirely invalid. `ReturnsAnInterfaceImplementation` should declare its return type as IMyInterface, but there are many methods which return an object which implements an interface but does not declare the return type as that interface. However, it can happen that the consumer of that method intends to use only the interface. In this case the use of var decreases readability.

##Good Example

    public interface IMyInterface { }
    
    public class MyClass()
    {
        public void DoSomething(IMyInterface arg) { }
    }
    
    public class MyTestFixture()
    {    
        public void MyTest()
        {
            var myVar = new Mock<IMyInterface>();
            MyClass target = new MyClass();
            target.DoSomething(myVar.Object);
            myVar.Verify();
        }
    }

While writing thing, I tried to think of an example where the instance declared using var was an interface and var did not impede readability. Yes, there are plenty of cases where var doesn't hurt readability at all, but with interfaces the only cases is when dealing with runtime generated classes (Please correct me if you think of one). 

The most common case of this is RhinoMocks or Moq or some other mocking framework. So that was what I decided to use as an example. I can think of one other example of this which is `System.ServiceModel.ChannelFactory<T>`.

##It's a matter of preference

I have found that the use of var, outside of anonymous type declaration, is largely preference. There is nothing wrong with using it. Except in the example above it rarely hurts readability and there is no peformance pentaly involved. However, you will find those who are vehemently against it and those who are passionate about defending its use. The debate is almost religious, so I generally avoid it.

##Busting the myth

So why did I write this post? Why if I avoid the debate did I decide to jump into the line of fire? For one reason only - to debunk a false argument. I will reiterate here I have nothing against using var. If I join your project and you're using it as a convention I won't complain. If I'm part of the startup phase of a project and we're discussing conventions and the majority of the team decides to use it I'll concede.

That said, don't try using the argument around me that "it is a shortcut" or "it saves time". Unless you develop using notepad (or some variant thereof) it does not save time. Intellisense has beat it everytime I've made the comparison. There have been draws/ties, I'll admit. But never has var saved me a single keystroke. 

The reason I bring this up is because of a discussion on the CodeProject Lounge Forum. The discussion started yesterday and I jumped in a bit today. It was argued that for long type names which are largely ambiguous except for the last few characters that var wins out. The example given was DataGridViewRow where there are too many classes named `DataGrid`. and even still `DataGridView`

A colleague of mine (who I'm sure will provide his two cents in the comments below) and I actually tested this a few months back. Here is a comparison using the example from today's debate:

Using var:

    var row = new DataGridViewRow();
                          ^--
Without var:

    DataGridViewRow row = new DataGridViewRow();
                ^--           ^--------------

In the above examples, `^` represents the point where Intellisense gives you the right class and `-` represents the characters it types for you. 

In the first example, you have to type 27 characters before you get the right class from Intellisense. And it types 2 characters for you. You end up having to type `();` as well which brings the grand total to 30 for the entire line.

The second example, you type the first 13 keystrokes (including [TAB] to accept the selection), save 2 with Intellisense, then type 10 more bringing you up to 23. Add the last 3 when you type `();` and you're at 26. So var cost me 4 keystrokes. If I had used [SPACEBAR] instead of [TAB] on the left side I could have saved and additional keystroke with Intellisense.

##A request

As a favor to those out there learning, I'd like to make a request. Please don't use var when writing code snippets in blog posts and forum posts. Unless the right side of the declaration explicitly and without ambiguity declares exactly what the type of the variable will be, please don't use it. It hurts readability and hurts those trying to learn what you're trying to convey.

##Conclusion

So while I'll never say there is anything *wrong* with using var, it isn't *right* to say it saves time. When compared against Intellisense it will lose every time. I'll issue a challenge and I would LOVE to be proven wrong because I find out I was wrong I get to learn. Show me some examples of where using var beats Intellisense. Number of characters doesn't count because I've only ever met a single developer who coded using notepad.
