---
layout: post
title: In Place List Editing With WPF
date: '2008-12-24 18:33:00'
tags:
- wpf
---

I've been working in WPF for the last month and learning some pretty cool stuff. I really like it. But then I spend a couple days trying to something that would take me 2 minutes in an ASP.NET Web Form and I want to swallow a bullet. I know there is just a learning curve and the more I use it and I'll be able to do it just as quickly. But as much as I love learning new stuff there are days I really long for less new technology to learn.

I had a list of items displaying quite nicely in a ListBox. Here's the XAML:

    <ListBox Name="m_MyList" 
        ItemsSource="{Binding MyDataItems}" 
        SelectedItem="{Binding Mode=TwoWay, 
            Path=MySelectedDataItem}">
        <ListBox.ItemTemplate>
            <DataTemplate>
                <Grid>
                    <TextBlock Text="{Binding Name}" />
                </Grid>
            </DataTemplate>
        </ListBox.ItemTemplate>
    </ListBox>
    

But I wanted to replace the template with an edit template when the user selected an item. To make things more complex, my view was a UserControl which was used in 3 different "Modes" (Load, Apply, Save - Load/Apply are very similar but require different behavior). For Load I wanted the edit template only if "New Item" (MyObject.IsNew == true) were selected. For Apply I didn't want the edit template at all and for Save I wanted the edit template for everything.

I started out with a Style using a Trigger to replace the control template. Basically, I had a Style with TargetType={x:Type TextBox} like this:

    <Control.Resources>
     
        <Style x:Key="TextBoxBaseStyle" 
               TargetType="{x:Type TextBox}">
            <Setter Property="Height" Value="25"></Setter>
            <Setter Property="VerticalContentAlignment" Value="Center"></Setter>
        </Style>
     
        <Style
            x:Key="BasicTextBox"
            TargetType="{x:Type TextBox}"
            BasedOn="{StaticResource TextBoxBaseStyle}">
     
            <Style.Triggers>
                <DataTrigger Binding="{Binding RelativeSource={RelativeSource 
                            Mode=FindAncestor,
                            AncestorType={x:Type ListBoxItem}}, 
                        Path=IsSelected}" 
                    Value="True">
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="{x:Type TextBox}">
                                <TextBox Text="{TemplateBinding Text}" />
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </DataTrigger>
                <DataTrigger Binding="{Binding RelativeSource={RelativeSource 
                            Mode=FindAncestor,
                            AncestorType={x:Type ListBoxItem}}, 
                        Path=IsSelected}" 
                    Value="False">
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="{x:Type TextBox}">
                                <TextBlock Text="{TemplateBinding Text}"/>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                    <Setter Property="Focusable" Value="false"/>
                </DataTrigger>
            </Style.Triggers>
        </Style>
        
    </Control.Resources>
     
    <ListBox Name="m_MyList" 
        ItemsSource="{Binding MyDataItems}" 
        SelectedItem="{Binding Mode=TwoWay, 
            Path=MySelectedDataItem}">
        <ListBox.ItemTemplate>
            <DataTemplate>
                <Grid>
                    <TextBox Text="{Binding Name}" 
                        Style="{StaticResource BasicTextBox}" />
                </Grid>
            </DataTemplate>
        </ListBox.ItemTemplate>
    </ListBox>
    

But the data binding was broken. My source wasn't being updated. I don't know exactly why, but my theroy is that my trigger for edit was replacing the template for a TextBox with another TextBox - essentially a nested TextBox. Somehow this killed two-way binding.

I tried several other things, including replacing the style of the TextBox from the SelectionChanged event. Which would have worked if it hadn't been so complicated to fingure out. In the end here's what I came up with and I like this the best (that is when comparing to other possible 'working' solutions).:

    <Control.Resources>
        
        <!-- selected item template -->
        <DataTemplate x:Key="SelectedTemplate">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="75" />
                    <ColumnDefinition Width="*" />
                </Grid.ColumnDefinitions>
                <Grid.RowDefinitions>
                    <RowDefinition />
                    <RowDefinition />
                </Grid.RowDefinitions>
     
                <TextBlock Grid.Column="0" Grid.Row="0" Text="Name: " />
                <TextBox Grid.Column="1" Grid.Row="0" Text="{Binding Name}" />
     
                <TextBlock Grid.Column="0" Grid.Row="1" Text="Description: " />
                <TextBox Grid.Column="1" Grid.Row="1" Text="{Binding Description}" />
            </Grid>
        </DataTemplate>
     
        <!-- unselected item template -->
        <DataTemplate x:Key="DefaultTemplate">
            <TextBlock Text="{Binding Path=Name}" />
        </DataTemplate>
        
        <!-- ListBox ItemContainerStyle -->
        <Style TargetType="{x:Type ListBoxItem}" x:Key="ContainerStyle">
            <Setter Property="ContentTemplate" 
                Value="{StaticResource DefaultTemplate}" />
            <Style.Triggers>
                <MultiDataTrigger>
                    <MultiDataTrigger.Conditions>
                        <Condition Binding="{Binding IsNewRecord}" Value="True" />
                        <Condition Binding="{Binding 
                                RelativeSource={RelativeSource Mode=FindAncestor,
                                    AncestorType={x:Type UserControl}}, 
                                Path=DataContext.State}" 
                            Value="{x:Static ui:MyModelState.Load}" />
                        <Condition Binding="{Binding RelativeSource={RelativeSource Self}, 
                            Path=IsSelected}" Value="True" />
                    </MultiDataTrigger.Conditions>
                    <Setter Property="ContentTemplate" 
                        Value="{StaticResource SelectedTemplate}" />
                </MultiDataTrigger>
                <MultiDataTrigger>
                    <MultiDataTrigger.Conditions>
                        <Condition Binding="{Binding 
                            RelativeSource={RelativeSource Mode=FindAncestor,
                                AncestorType={x:Type UserControl}}, 
                            Path=DataContext.State}" 
                            Value="{x:Static ui:MyModelState.Save}" />
                        <Condition Binding="{Binding 
                            RelativeSource={RelativeSource Self}, 
                            Path=IsSelected}" 
                            Value="True" />
                    </MultiDataTrigger.Conditions>
                    <Setter Property="ContentTemplate" 
                        Value="{StaticResource SelectedTemplate}" />
                </MultiDataTrigger>
            </Style.Triggers>
        </Style>
    </Control.Resources>
     
    

So first, I have two DataTemplate elements an edit template named "SelectedTemplate" and a read only template named "DefaultTemplate". Then I have a Style element which targets ListBoxItem named "ContainerStyle". "ContainerStyle" sets the ContentTemplate to "DefaultTemplate". Then based on two different Triggers (MultiDataTrigger) it determines when to apply the edit template.

A couple of things I learned here. First, my Triggers are trying to target my data binding properties and my control properties at the same time. I found that I couldn't do this with a standard Trigger element. So you'll see the last Condition element of each MultiDataTrigger is referencing the IsSelected property of the ListBoxItem like this:

    <Condition Binding="{Binding RelativeSource={RelativeSource Self}, 
        Path=IsSelected}" Value="True" />
    

Then the second tricky part (for me anyways) was figuring out how to access a property of the Control's DataContext (this would apply if we were talking about Window as well). I wasn't sure how to approach this for a couple reasons: DataContext is of type Object and my ListBox was bound to a property on the DataContext, not the DataContext itself.

As it turns out these weren't really any problem, I just had to find the correct RelativeSource arguments:

    <Condition Binding="{Binding 
        RelativeSource={RelativeSource Mode=FindAncestor,
            AncestorType={x:Type UserControl}}, 
        Path=DataContext.State}" 
        Value="{x:Static ui:MyModelState.Save}" />
    

It turns out it is pretty simple, use FindAncestor to query for the UserControl (or Window if that is your situation). Then your Path can reference the UserControl's DataContext property. No casting is needed (that was a pleasant surprise) and I could reference the "State" property (a custom property of the object I assigned to the DataContext). "State" is an enum value, so hence the x:Static and the "ui" namespace in "ui:MyModelState.Save".

So, I'm liking WPF again, because I was able to do this without writing "any" code. I put "any" in quotes because I did cheat a little by adding an "IsNew" property to my custom Type. IsNew returns true if the ID is "0", otherwise it returns false. I did this because there didn't seem to be any way to use a range condition or a "not" condition. But other than that I used 100% XAML for this solution.
