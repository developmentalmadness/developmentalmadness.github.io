---
layout: post
title: 'Xaml: Binding to the current DataContext'
date: '2009-08-27 00:13:00'
tags:
- silverlight
- wpf
- prism
- xaml
---

Sometimes instead of binding to a property of the current DataContext you want to bind to the actual DataContext itself. For example, I am using DelegateCommand<T> from Composite Application Library and needed to bind a command to perform an action on the current item in a ListBox.

    <UserControl x:Name="ViewRoot">
        <ListBox ItemSource="{Binding Path=MyCollection}">
            <Button Content="Delete" cmd:Click.Command="{Binding ElementName=ViewRoot, Path=DataContext.Delete}
                cmd:Click.CommandParameter={??????} />
        </ListBox>
    </UserControl>

I just wasn't sure what to put here. Every example I've read binds to a property of the current `DataContext`, but how do I bind to the context itself. Here's the definition of my command:

    public class MyViewModel {
        public DelegateCommand<MyObject> Delete { get; private set; }
    
        public MyViewModel() {
            Delete = new DelegateCommand<MyObject>(this.DeleteExecute,
                            this.DeleteCanExecute);
        }
    
        private void DeleteExecute(MyObject item) {
            item.Delete();
        }
 
        private void DeleteCanExecute(MyObject item) {
            true;
        }
    }

So how do you set `cmd:Click.CommandParameter` so that it passes the current instance of `MyObject` to the `DeleteExecute` and `DeleteCanExecute` methods? It turns out you can pass an empty Binding expression (or an expression without setting a value for `Path`) just like this:

    <Button ... cmd.Click.CommandParameter="{Binding}" />

This wasn't obvious to me - I was thinking there was some sort of notation. I tried a couple different variations of setting `Path` to something like `DataContext` or . (like XPath), but couldn't find anything else. Then I was looking up something else and found this post. Under the first bullet the sample workaround shows the same syntax as above. Once I tried it that worked. Hope this helps.