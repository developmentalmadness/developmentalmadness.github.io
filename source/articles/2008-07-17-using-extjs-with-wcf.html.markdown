---
layout: post
title: Using ExtJs with WCF
date: '2008-07-17 18:09:00'
tags:
- extjs
- wcf
---

Been wanting to get to this part of development for a while now and since I struggled a bit to get this working I thought it would make a good post. With the release of the .NET Framework 3.5 WCF seems to be growing in popularity (or maybe it's just me), but since WCF seems to be the replacement for WebSerivices I figure I need to get to know it.

In my [last post on WCF](/2008/05/08/intro-to-wcf-for-ajax/) I didn't use any client, other than just pointing the browser window at the service address for an operation with no parameters and a return type of "text/plain". Now that I've done some work with a client, I've found this was not very helpful other than proving that the service was up and could serve up text. I hope this will prove more helpful.

#Setting up the service

Let's start by getting a service up and running that we can access from our web page. First, create a new ASP.NET Web Application project in VS 2008. Then add a new "AJAX-enabled WCF Service" item to your project. I'll name mine Ajax.svc.

I don't know about VB.NET (I don't have it installed on my machine), but I found that the item template wasn't listed with the web templates in the "Add new item" dialog box. You can find the item template in the root category "Visual C#", but since I usually use the categories to filter out the long list of items it took me a while to find it.

Once you've created the svc item you'll have 2 new files in your project:

* Ajax.svc - this is the target for the service. When you reference operations from your client you'll use the path ~/{path to parent folder}/Ajax.svc
* Ajax.svc.cs - this is where you'll write the service definition. Think of this file as your "code behind" file and define the actual service implementation here. As an aside you can define an interface with the service definition with the attributes applied. You could then have different implementations of the service which all adhere to the defined contract. But we'll just keep things to a minimum here.

You'll also notice, if you look at the project references that you have a couple new references added to your project:

* System.Runtime.Serialization
* System.ServiceModel
* System.ServiceModel.Web

#Creating the service definition

In my first WCF post we created a typical "Hello World" service, which took no inputs and returned plain/text output. Here I'd like to accept several parameters and return a custom object. I'd also like to have an operation which will return a collection of objects. This way I hope to document a few of the tricks required to create a more real-world example.

#Multiple params/simple return value

The first example uses multiple inputs and returns a single, scalar value. Add the following to the Ajax class in your Ajax.svc.cs file:

        [System.ServiceModel.OperationContract]
        [System.ServiceModel.Web.WebInvoke(
            BodyStyle=System.ServiceModel.Web.WebMessageBodyStyle.WrappedRequest,
            RequestFormat=System.ServiceModel.Web.WebMessageFormat.Json,
            ResponseFormat=System.ServiceModel.Web.WebMessageFormat.Json,
            UriTemplate="/Add")]
        public int Add(int a, int b)
        {
            return a + b;
        }

Sorry for not using namespace shortcuts here, but when I'm looking at a howto nothing bugs me more than having to track down the proper namespaces. You shouldn't have to worry about these as the item template for your web service should automatically add the using statements at the head of the file for you.

The method must be public and must have the System.ServiceModel.OperationContract attribute to be exposed as part of the service. We'll focus here on the System.ServiceModel.WebInvoke attribute. You have the option of using the System.ServiceModel.WebGet attribute as well, but I wanted to use WebInvoke here to point out that WebGet will limit you to simple types (int, string, etc) and the http GET method. Using WebInvoke allows you to define parameters using complex, custom types and allows you to use both GET and POST. You can also explicitly limit the operation to just one of http method using the "Method" argument of the WebInvoke attribute.

* **BodyStyle (System.ServiceModel.Web.WebMessageBodyStyle)** - You can specify Bare, WrappedRequest, WrappedResponse or Wrapped. The key here is the number and type of your input/output. Bare is used for one or zero simple types. So if your input has no parameters or a single, simple type AND your return value is either "void" or a simple type then you can use Bare. If you only need to wrap one of either the request or response then use the WebMessageBodyStyle specific to what you need (ie. multiple and/or complex params = WrappedRequest; complex return type = WrappedResponse). If you need to wrap both the response AND the request, then "Wrapped" will take care of that.
* **RequestFormat/ResponseFormat (System.ServiceModel.Web.WebMessageFormat)** - You really have two options, Json or Xml. If you want to return plain text this will essentially set the request.ContentType for you to whatever you select. I believe the default is probably Xml, but I haven't verified that. Incorrectly using this parameter will result in an error message similar to the following: Operation 'Add' of contract 'Ajax' specifies multiple request body parameters to be serialized without any wrapper elements. At most one body parameter can be serialized without wrapper elements. Either remove the extra body parameters or set the BodyStyle property on the WebGetAttribute/WebInvokeAttribute to Wrapped.
* **Method (System.String)** - The default is POST, but you can also set this to GET as long as your RequestFormat can be "Bare".
* **UriTemplate (System.String)** - This is what the name of the operation will be when it is exposed with the service. It doesn't have to match the name of the class method. When you reference the operation it will be in the format ~/{path to parent folder}/{service name}.svc/{UriTemplate}. Also, if you want to map your parameters to querystring /post parameters you can do that here as well like this: Add?a={a}&b={b}. And the parameters will map to your method signature. If you are going to use UriTemplate, then you will also want to change replace the <enablewebscript/> behavior in your web.config file with <webhttp/>. Otherwise you'll get this error: Endpoints using 'UriTemplate' cannot be used with 'System.ServiceModel.Description.WebScriptEnablingBehavior'.

#Complex Types

Next, let's add a complex type we can use to meet the goals I stated at the beginning of this post:

    [System.Runtime.Serialization.DataContract]
    public class Person
    {
        public Person(String first, String last, Int32 age)
        {
            FirstName = first;
            LastName = last;
            Age = age;
        }
    
        [System.Runtime.Serialization.DataMember]
        public String FirstName { get; set; }
        [System.Runtime.Serialization.DataMember]
        public String LastName { get; set; }
        [System.Runtime.Serialization.DataMember]
        public Int32 Age { get; set; }
    }
    
Nothing fancy here, just annotate the class as DataContract and each property to be exposed as DataMember. However, I'd like to mention a small, but important point here. If the class implements System.Runtime.Serialization.ISerializable you don't need to annotate your class with DataContract and DataMember. Just make sure the class properly implements the ISerializable.GetObjectData method and has a constructor with the same signature as GetObjectData.

If you try mixing DataContract with Serializable you'll get an System.Runtime.Serialization.InvalidDataContractException error message like this:

> Type 'ExtJsWCF.Person' cannot be ISerializable and have DataContractAttribute attribute.

Now, back to our remaining service operations. Go ahead and add the following to our Ajax service class definition:

        [OperationContract]
        [WebInvoke(
            BodyStyle = WebMessageBodyStyle.Wrapped,
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json,
            UriTemplate = "/GetPerson")]
        public Person GetPerson(String first, String last, Int32 age)
        {
            return new Person(first, last, age);
        }
    
        [OperationContract]
        [WebInvoke(
            BodyStyle = WebMessageBodyStyle.Wrapped,
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json,
            UriTemplate = "/GetRelatives")]
        public IList<Person> GetRelatives(Person person)
        {
            System.Collections.Generic.List<Person> people = new System.Collections.Generic.List<Person>();
    
            people.Add(new Person("Joe", person.LastName, 41));
            people.Add(new Person("John", person.LastName, 33));
            people.Add(new Person("Jane", person.LastName, 30));
    
            return people;
        }
    
        [OperationContract]
        [WebInvoke(
            BodyStyle = WebMessageBodyStyle.Wrapped,
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json,
            UriTemplate = "/SaveRelatives")]
        public Boolean SaveRelatives(Person[] people)
        {
            return true;
        }
    

At this point we should be able to compile our service. Now we're ready for our client.

#Setting up the client (ExtJs)

At this point I'm going to go into specifics about ExtJs. Much of what I'll address should be applicable to most clients, but I'll leave those specifics to you.

If you haven't already, you'll want to download the [ExtJs sdk](http://www.extjs.com/products/extjs/download.php). I am using 2.1. Once you've unzipped the archive, you can copy the following files and directories to the root of our application:

* /ext-all.js
* /adapter/
* /resources/

Now open Default.aspx and add the following to the `<head>` element:

     <link href="extjs/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
     <script src="extjs/adapter/ext/ext-base.js" type="text/javascript"></script>
     <script src="extjs/ext-all.js" type="text/javascript"></script>
    
     <style>
         .myForm {
             margin: 3em;
         }
         .myResponse
         {
          color: Red;
          font-weight: bold;
         }
     </style>
     <script type="text/javascript">
         var mask;
    
         Ext.onReady(function(){
             Ext.get('btnSum').on('click', addValues);
             Ext.get('btnGetPerson').on('click', getPerson);
             Ext.get('btnGetFamily').on('click', getFamily);
          
             mask = new Ext.LoadMask(Ext.getBody(), {
                 msg: "Loading..."
             });
          
         });
      
         function addValues()
         {
             mask.show();
          
             var aVal = Ext.get('txtA').dom.value;
             var bVal = Ext.get('txtB').dom.value;
          
             var params = { a : aVal, b : bVal };
          
             Ext.lib.Ajax.defaultPostHeader = 'application/json';
          
             Ext.Ajax.request({
                 url: '/Ajax.svc/Add',
                 method: 'POST',
                 params : Ext.encode(params),
                 success: function(response,options){
                     mask.hide();
                     Ext.get('txtResult').dom.value = response.responseText;
                     Ext.get('additionResponse').dom.innerHTML = response.responseText;
                 },
                 failure: function(response,options){
                     mask.hide();
                     Ext.MessageBox.alert('Failed', 'Unable to add values');
                 }
             });
         }
      
         function getPerson()
         {
             //status display
             mask.show();
          
             //get form values
             var fVal = Ext.get('txtFirst').dom.value;
             var lVal = Ext.get('txtLast').dom.value;
             var aVal = Ext.get('txtAge').dom.value;
          
             //create Json object
             var params = { first: fVal, last: lVal, age: aVal };
          
             //change post header from application-x-urlencoded
             Ext.lib.Ajax.defaultPostHeader = 'application/json';
          
             //create request
             Ext.Ajax.request({
                 url: '/Ajax.svc/GetPerson',
                 params: Ext.encode(params),
                 method: 'POST',
                 success: function(response,options){
                     // response callback
                  
                     //update status display
                     mask.hide();
                  
                     // display literal output from response
                     Ext.get('getPersonResponse').dom.innerHTML = response.responseText;
                  
                     // decode text into Json object
                     var data = Ext.decode(response.responseText);
                  
                     // display data from object
                     Ext.MessageBox.alert('First: ' + data.GetPersonResult.FirstName
                         + '<br>Last: ' + data.GetPersonResult.LastName
                         + '<br>Age: ' + data.GetPersonResult.Age);
                 },
                 failure: function(response,options){
                     mask.hide();
                     Ext.MessageBox.alert('Failed', 'Unable to get person');
                 }
             });
         }
    
      
         function getFamily()
         {
             //status display
             mask.show();
          
             //get form values
             var fVal = Ext.get('txtFirst').dom.value;
             var lVal = Ext.get('txtLast').dom.value;
             var aVal = Ext.get('txtAge').dom.value;
          
             //create Json object
             var params = { person: { FirstName: fVal, LastName: lVal, Age: aVal } };
          
             //change post header from application-x-urlencoded
             Ext.lib.Ajax.defaultPostHeader = 'application/json';
          
             //create request
             Ext.Ajax.request({
                 url: '/Ajax.svc/GetRelatives',
                 params: Ext.encode(params),
                 method: 'POST',
                 success: function(response,options){
                     // response callback
                  
                     //update status display
                     mask.hide();
                  
                     // display literal output from response
                     Ext.get('getPeopleResponse').dom.innerHTML = response.responseText;
                  
                     // decode text into Json object
                     var data = Ext.decode(response.responseText);
                  
                     // display data from object
                     var store = new Ext.data.JsonStore({
                         data : data,
                         root : 'GetRelativesResult',
                         fields: [
                             {name: 'FirstName'},
                             {name: 'LastName'},
                             {name: 'Age'}
                         ]
                     });
                  
                     Ext.get('persongrid').dom.innerHTML = '';
                  
                     var family = new Ext.grid.GridPanel({
                         store : store,
                         colums : [
                             {id: 'FirstName', header: 'Name', dataIndex: 'FirstName'},
                             {id: 'LastName', header: 'Last Name', dataIndex: 'LastName'},
                             {id: 'Age', header: 'Age', dataIndex: 'Age'}
                         ],
                         title : 'Family',
                         autoHeight: true
                     });
                  
                     family.render('persongrid');
                 },
                 failure: function(response,options){
                     mask.hide();
                     Ext.MessageBox.alert('Failed', 'Unable to get family');
                 }
             });
         }
    
     </script>
    
An add this to the <body> element of the page:

     <div>
         <div id="addition" class="myForm">
             <div>A: <input id="txtA" type="text" size="3" maxlength="3" /></div>
             <div>
                 B: <input id="txtB" type="text" size="3" maxlength="3" />
                 <input id="btnSum" type="button" value="sum" />
             </div>
             <div>Answer: <input id="txtResult" type="text" size="5" /></div>
             <div>Http Response text:<div id="additionResponse" class="myResponse"></div></div>
         </div>
      
         <div id="personform" class="myForm">
             <div>First Name: <input id="txtFirst" type="text" /></div>
             <div>Last Name: <input id="txtLast" type="text" /></div>
             <div>
                 Age: <input id="txtAge" type="text" maxlength="2" size="3" />
                 <input type="button" id="btnGetPerson" value="Get" />
                 <input type="button" id="btnGetFamily" value="Get Family" />
             </div>
             <div>Http Response text:<div id="getPersonResponse" class="myResponse"></div></div>
         </div>
      
         <div class="myForm">
             <div id="persongrid"></div>
             <div>Http Response text:<div id="getPeopleResponse" class="myResponse"></div></div>
         </div>
     </div>
    

Now load the page in your browser and give it a whirl!

Here's what you'll notice as you play with the page:

* The Json in the request body needs to be encoded by placing quotes around each identifier as well as any string values.
* The response from the Add method is just plain text, no quotes, no Json notation.
* When the response is wrapped the root name of the object is the name of the WCF operation plus the text "Result". Make sure and account for that when working with the objects. I'm still looking for a way to control that value, but for now I'm just using the javascript String.Replace function like this: `new String(response.responseText).replace(/MethodNameResult/, "whatIWantHere");`
* The Json response comes across the wire encoded, so you'll need to decode the object to work with it.
* Date values are serialized by the service as `"/Date(1235468858)/"` where 1235468858 is the number of ticks from January 1, 1970. The problem with this is in order for this date to work (at least with ExtJs) it needs to be "/new Date(1235468858)/". To achive this you can use a regex to insert it. Here's what I'm using: `var exp = response.responseText.replace(new RegExp('(^|[^\\\\])\\"\\\\/Date\\((-?[0-9]+(-[0-9]+)?)\\)\\\\/\\"', 'g'), "$1new Date($2)");`
* When sending an array to the service from the client an important thing to know is that sending just the array isn't enough. It seems natural just to send the array. But if you were to send the encoded array, you'll get the following error: **OperationFormatter encountered an invalid Message body. Expected to find an attribute with name 'type' and value 'object'. Found value 'array'.** Make sure that you encode your array as a property of a Json object, like this: Ext.encode({parameterName: myArray});.

#Conclusion

This post is a result of hours of frustration and digging, so I hope it helps someone save some time and avoid the traps I ran into.
