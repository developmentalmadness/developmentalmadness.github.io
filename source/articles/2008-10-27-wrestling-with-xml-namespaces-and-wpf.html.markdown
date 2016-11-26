---
layout: post
title: Wrestling with XML Namespaces and WPF
date: '2008-10-27 17:39:00'
tags:
- wpf
- data_binding
- namespace
- xmldocument
- xmldataprovider
---

I have been using XML for internal data formats for many years. Mostly for the purpose of transforming data using XSLT. So while I've been working with XML for a long time, I have never had the need to work with namespaces other than those that were standard with XSLT.

But this weekend I had my first real run-in with namespaces and I figure I'll share a bit of what I learned here.

I am planning on using Amazon Web Service's S3 service to store what I'm hoping will be a large number of images for a startup I'm working on. In order to initially manage my buckets (and because I'm trying to dabble a bit with WPF) I'm writing a small application to allow me to create and manage S3 buckets.

I've downloaded the .NET library for S3 and so far it has been pretty slick for creating buckets and objects. But the ACL methods for managing permissions don't really try to do much for you, so you've got to work the the raw XML yourself. Here's an example of an ACL response:

    <AccessControlPolicy>
      <Owner>
        <ID>a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9</ID>
        <DisplayName>chriscustomer</DisplayName>
      </Owner>
      <AccessControlList>
        <Grant>
          <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
            <ID>a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9</ID>
            <DisplayName>chriscustomer</DisplayName>
          </Grantee>
          <Permission>FULL_CONTROL</Permission>
        </Grant>
        <Grant>
          <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
            <ID>79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be</ID>
            <DisplayName>Frank</DisplayName>
          </Grantee>
          <Permission>WRITE</Permission>
        </Grant>
        <Grant>
          <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
            <ID>79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be</ID>
            <DisplayName>Frank</DisplayName>
          </Grantee>
          <Permission>READ_ACP</Permission>
        </Grant>
        <Grant>
          <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
            <ID>e019164ebb0724ff67188e243eae9ccbebdde523717cc312255d9a82498e394a</ID>
            <DisplayName>Jose</DisplayName>
          </Grantee>
          <Permission>WRITE</Permission>
        </Grant>
        <Grant>
          <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
            <ID>e019164ebb0724ff67188e243eae9ccbebdde523717cc312255d9a82498e394a</ID>
            <DisplayName>Jose</DisplayName>
          </Grantee>
          <Permission>READ_ACP</Permission>
        </Grant>
        <Grant>
          <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Group">
            <URI>http://acs.amazonaws.com/groups/global/AllUsers</URI>
          </Grantee>
          <Permission>READ</Permission>
        </Grant>
      </AccessControlList>
    </AccessControlPolicy>
     
    
I'm still pretty new to WPF so it took some wrangling to get everything to databind the way I wanted. I wanted to display the owner at the top of the form and then list the permissions using a ListView. So I wanted the data bound to the window object and then allow child controls to inherit from the Window's DataContext.

The frustrating point was that it seems as if every single WPF example is written using data that's embedded directly in the XAML. This does nothing to help me understand as I don't write many applications where the data is static. So first I did some reading up on data binding to help me to better understand the concepts behind it:
http://msdn.microsoft.com/en-us/library/ms750612.aspx
Then after searching around I found a few helpful examples. First, an example of declaring namespaces in XAML along with an XmlDataProvider:
http://www.codeproject.com/KB/WPF/Picasaweb_Album_Viewer.aspx
This was nice since the article is about working with Google's Picasa, so it also involved using namespaces defined by an external web service, so it exactly correlated with what I was trying to do. After reading through that article I came up with this:

    
    <Window x:Class="AWSS3Manager.Windows.Permissions"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Permissions" Height="310" Width="484">
        <Window.Resources>
            <XmlNamespaceMappingCollection x:Key="AWSNamespaces">
                <XmlNamespaceMapping Uri="http://s3.amazonaws.com/doc/2006-03-01/" Prefix="aws" />
                <XmlNamespaceMapping Uri="http://www.w3.org/2001/XMLSchema-instance" Prefix="xsi" />
            </XmlNamespaceMappingCollection>
            <XmlDataProvider x:Key="m_Data" XPath="/aws:AccessControlPolicy" 
                             XmlNamespaceManager="{StaticResource AWSNamespaces}" />
        </Window.Resources>
        <Window.DataContext>
            <Binding Source="{StaticResource m_Data}" />
        </Window.DataContext>
        
        .... XAML goes here ....
        
    </Window>
    

I bind the XmlDataProvider like this: 

 
    XmlDocument data = new XmlDocument();
    //data.LoadXml(response.Object.Data);
    data.LoadXml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        + "<AccessControlPolicy xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">"
        + "<Owner><ID>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</ID>"
        + "<DisplayName>developmentalmadness</DisplayName>"
        + "</Owner><AccessControlList><Grant>"
        + "<Grantee xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"CanonicalUser\">"
        + "<ID>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</ID>"
        + "<DisplayName>developmentalmadness</DisplayName></Grantee>"
        + "<Permission>FULL_CONTROL</Permission></Grant>"
        + "</AccessControlList></AccessControlPolicy>");
     
    XmlDataProvider m_Data = this.FindResource("m_Data") as XmlDataProvider;
    if (m_Data == null)
        return;
     
    m_Data.Document = data;
     
    

Now I'm able to use XAML to bind the owner to a TextBlock like this:

            <TextBlock Grid.Column="1" Grid.Row="0" 
                       Text="{Binding XPath=aws:Owner/aws:DisplayName}" />
     
    

And a ListView like this:

            <ListView Grid.Column="0" Grid.Row="2" Grid.ColumnSpan="2" Height="217" 
                      Name="m_ACLList" ItemsSource="{Binding XPath=aws:AccessControlList/aws:Grant}">
                <ListView.View>
                    <GridView>
                        <GridViewColumn Header="Name" Width="310" 
                            DisplayMemberBinding="{Binding XPath=aws:Grantee/aws:DisplayName}" />
                        <GridViewColumn Header="Permission" Width="150" 
                            DisplayMemberBinding="{Binding XPath=aws:Permission}" />
                    </GridView>
                </ListView.View>
            </ListView>
     
    

The trick is that without the namespace declarations the binding will not work. This isn't so much WPF that requires this as System.Xml.XmlDocument. Which brings us to my second point. Now that I am able to bind to an XmlDocument object I need to be able to add items to the document. It didn't occur to me that this would be as difficult as it was. Here's the XAML my event handler depends on:

            <StackPanel Grid.Column="0" Grid.Row="1" Grid.ColumnSpan="2" Orientation="Horizontal">
                <TextBlock>Type:</TextBlock>
                <ComboBox Name="m_AclType" Width="75">
                    <ComboBoxItem>Anonymous</ComboBoxItem>
                    <ComboBoxItem>Email</ComboBoxItem>
                </ComboBox>
                
                <TextBlock>Value:</TextBlock>
                <TextBox Name="m_AclValue" Width="145"></TextBox>
                
                <TextBlock>Permission:</TextBlock>
                <ComboBox Name="m_AclPermission" Width="100">
                    <ComboBoxItem>READ</ComboBoxItem>
                    <ComboBoxItem>WRITE</ComboBoxItem>
                    <ComboBoxItem>READ_ACP</ComboBoxItem>
                    <ComboBoxItem>WRITE_ACP</ComboBoxItem>
                    <ComboBoxItem>FULL_CONTROL</ComboBoxItem>
                </ComboBox>
                
                <Button Name="m_AddAcl" Click="m_AddAcl_Click">Add</Button>
            </StackPanel>
            
 


And here's the event handler:

    private void m_AddAcl_Click(object sender, RoutedEventArgs e)
    {
        XmlNamespaceMappingCollection manager = this.FindResource("AWSNamespaces") 
            as XmlNamespaceMappingCollection;
        if (manager == null)
            return;
     
        XmlDataProvider m_Data = this.FindResource("m_Data") as XmlDataProvider;
        if (m_Data == null)
            return;
     
        XmlDocument data = m_Data.Document;
        XmlNode acl = data.SelectSingleNode(
            "/aws:AccessControlPolicy/aws:AccessControlList", 
            manager);
     
        XmlElement grant = data.CreateElement("Grant");
        
        XmlElement grantee = data.CreateElement("Grantee");
        XmlAttribute type = data.CreateAttribute("xsi:type", 
            "http://www.w3.org/2001/XMLSchema-instance");
        XmlElement detail = null;
     
        switch (m_AclType.SelectionBoxItem as String)
        {
            case "Email":
                type.Value = "EmailAddress";
                detail = data.CreateElement("EmailAddress");
                detail.InnerText = m_AclValue.Text;
                break;
            case "Anonymous":
                type.Value = "Anonymous";
                detail = data.CreateElement("Uri");
                detail.InnerText = "http://acs.amazonaws.com/groups/global/AllUsers";
                break;
        }
     
        grantee.Attributes.Append(type);
        grantee.AppendChild(detail);
        grant.AppendChild(grantee);
     
        XmlElement permission = data.CreateElement("Permission");
        permission.InnerText = m_AclPermission.SelectionBoxItem as String;
        grant.AppendChild(permission);
     
        acl.AppendChild(grant);
    }
     


The problem is that new items wouldn't show up in the ListView after this ran. After a while of trying to figure this out I finally noticed that the "Grant" element had a blank xmlns attribute, like this:

    <?xml version="1.0" encoding="UTF-8"?>
    <AccessControlPolicy xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
        <Owner>
            <ID>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</ID>
            <DisplayName>developmentalmadness</DisplayName>
        </Owner>
        <AccessControlList>
            <Grant>
                <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
                    <ID>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</ID>
                    <DisplayName>developmentalmadness</DisplayName>
                </Grantee>
                <Permission>FULL_CONTROL</Permission>
            </Grant>
            <Grant xmlns="">
                <Grantee xsi:type="EmailAddress" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                    <EmailAddress>user@domain.com</EmailAddress>
                </Grantee>
                <Permission>FULL_CONTROL</Permission>
            </Grant>
        </AccessControlList>
    </AccessControlPolicy>
     


The first Grant element is from the web service, but the second one was added by my event handler. It turns out that when using namespaces with XmlDocument you need to be explicit about it. By leaving out the NamespaceURI when creating a new element I was effectively changing the namespace by setting it to null.

Finding out what to do about this was especially frustrating because all I was finding was solutions to parse the XML and strip the attributes. Other posts just seemed to say, "If you don't want a namespace in the document, don't put any there". Which isn't really helpful when I don't control the format of the document.

Finally, I found this post:

http://stackoverflow.com/questions/135000/how-to-prevent-blank-xmlns-attributes-in-output-from-nets-xmldocument

After reading this I added a value for namespaceURI for each call to the CreateElement() method and this issue was fixed as well, here's the updated event handler:

 
    private void m_AddAcl_Click(object sender, RoutedEventArgs e)
    {
        XmlNamespaceMappingCollection manager = this.FindResource("AWSNamespaces") 
            as XmlNamespaceMappingCollection;
        
        if (manager == null)
            return;
     
        XmlDataProvider m_Data = this.FindResource("m_Data") as XmlDataProvider;
        if (m_Data == null)
            return;
     
        XmlDocument data = m_Data.Document;
        XmlNode acl = data.SelectSingleNode(
            "/aws:AccessControlPolicy/aws:AccessControlList", 
            manager);
     
        // prevent empty xmlns attribute (xmlns="") rendering by 
        // assigning NamespaceUri for all elements
        String uri = data.DocumentElement.NamespaceURI;
        XmlElement grant = data.CreateElement("Grant", uri);
        
        XmlElement grantee = data.CreateElement("Grantee", uri);
        XmlAttribute type = data.CreateAttribute("xsi:type", 
            "http://www.w3.org/2001/XMLSchema-instance");
        XmlElement detail = null;
     
        switch (m_AclType.SelectionBoxItem as String)
        {
            case "Email":
                type.Value = "EmailAddress";
                detail = data.CreateElement("EmailAddress", uri);
                detail.InnerText = m_AclValue.Text;
                break;
            case "Anonymous":
                type.Value = "Anonymous";
                detail = data.CreateElement("Uri", uri);
                detail.InnerText = "http://acs.amazonaws.com/groups/global/AllUsers";
                break;
        }
     
        grantee.Attributes.Append(type);
        grantee.AppendChild(detail);
        grant.AppendChild(grantee);
     
        XmlElement permission = data.CreateElement("Permission", uri);
        permission.InnerText = m_AclPermission.SelectionBoxItem as String;
        grant.AppendChild(permission);
     
        acl.AppendChild(grant);
    }
    

Now I have a window, bound to an XmlDocument which contains namespace declarations, was loaded at runtime, and when the document changes the UI is updated.
