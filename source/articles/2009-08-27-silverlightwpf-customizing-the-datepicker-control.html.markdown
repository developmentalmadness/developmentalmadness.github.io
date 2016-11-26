---
layout: post
title: 'Silverlight/WPF: Customizing the DatePicker Control'
date: '2009-08-27 18:34:00'
tags:
- silverlight
- wpf
- custom-template
- datepicker
---

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/iTouchDatePicker.zip)

I'm working on a Silverlight scheduling application and wanted to make the `DatePicker` control from the Silverlight Toolkit look like the program icon on my iPod Touch. The calendar looks icon like a day calendar and dynamically displays the current date.

![](http://dvm-public-assets.s3.amazonaws.com/images/2009/08_27/iTouchIcons_thumb.jpg)

I got the idea when I was looking at the calendar icon on the right-hand side of the `DatePicker` control. It was actually one of those accidental ideas. The control's icon looks like a day calendar and displays the number '15' well the day I was looking at it happened to be the 15th, so I thought it was actually displaying the day of the selected date (in the unselected case the current date). 

![](http://dvm-public-assets.s3.amazonaws.com/images/2009/08_27/DatePickerDefault_thumb.png)

Of course when I changed the date the icon didn't update, so I started digging in.

DISCLAIMER: I am not much of an artist so when I say, "like the iPod Touch" I mean, "similar colors and arrangement". Here is what the end result looks like:

![](http://dvm-public-assets.s3.amazonaws.com/images/2009/08_27/iTouchStyledDatePicker_thumb.png)

In the original control the icon on the right is a `Button` control. What we're going to do here is remove the main TextBox of the control, increase the size of the button on the right and add a `TextBlock` for the Month/Year in the format "mmm YY" and then the larger portion of the button below will represent the day in the format "DD". Then we'll bind each text block to the date of the control.

##Editing the DatePicker Template
This section of this post is mostly immaterial to our dicussion. But I added it because I wanted to include a bit of a HowTo on editing an existing template. If you just want the code and an explaination of it skip to the next section and continue reading.

First we need to open a new project and get a copy of the default template for the `DatePicker` control. If you are using Blend 3 this will be easy. If not, I'll give you the code here in a minute. 

After you create a new project, make sure you have a reference to the `System.Windows.Controls` library in your project. If you have it installed it will be in one of the following paths:

    C:\Program Files\Microsoft SDKs\Silverlight\v3.0\Libraries\Client\System.Windows.Controls.dll
    C:\Program Files (x86)\Microsoft SDKs\Silverlight\v3.0\Libraries\Client\System.Windows.Controls.dll

Next you can drag the `DatePicker` control from the Assets tool bar on the left (Blend 3). Just click the search button ">>" or browse the "Controls" category. 
￼

Or just add lines 4 and 10 from the following to your Xaml file:

    <UserControl
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:controls="clr-namespace:System.Windows.Controls;assembly=System.Windows.Controls"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        x:Class="iTouchDatePicker.MainPage"
        Width="640" Height="480" mc:Ignorable="d">

            <Grid x:Name="LayoutRoot" Background="White">
                <controls:DatePicker Width="150" Height="25" />
            </Grid>
    </UserControl>

Now, if you are using Blend 3, right-click the control on the design service and select Edit Template > Edit a copy... type in "iTouchDatePickerStyle" and select "Application" for the "Define in" option. This will make a copy of the DatePicker template in your App.Xaml file.

At this point we have an exact copy of the original template. For most templating customizations this is overkill if all you are trying to do is change simple look and feel properties. But what we are trying to do here is actually replace pieces of the template so we can add custom parts to our control and remove other pieces entirely. But when we are done here the cool part is we will have done this entirely in Xaml without any custom code.

The advantage of this technique is we don't have to define our own custom animation storyboards or gradient colors and design so we save a lot of time developing our custom style. You can skip this if you want to replace the template entirely. However, for a complex control like `DatePicker` I recommend going thru this step initially to study the template. Specifically, you want to look for any named elements. For example, `DatePicker` has a `Popup` element named (surprise) "Popup":

    <Popup x:Name="Popup"/>

The control's class implementation looks for this control and modifies it to create the calendar drop down when you click on the control's button. Custom control development conventions for Silverlight and WPF dictate that when an expected element is missing logic should continue without an error. At best this just means you're losing functionality from the control. But depending on who developed the control it could conceivably cause errors if the control wasn't properly developed.

##Our Custom Template

Now here's the template for our custom style:

    <Style x:Key="iTouchDatePickerStyle" TargetType="controls:DatePicker">
       <Setter Property="IsTabStop" Value="False"/>
       <Setter Property="Background" Value="#FFFFFFFF"/>
       <Setter Property="Padding" Value="2"/>
       <Setter Property="SelectionBackground" Value="#FF444444"/>
       <Setter Property="BorderBrush">
           <Setter.Value>
               <LinearGradientBrush EndPoint=".5,0" StartPoint=".5,1">
                   <GradientStop Color="#FF617584" Offset="0"/>
                   <GradientStop Color="#FF718597" Offset="0.375"/>
                   <GradientStop Color="#FF8399A9" Offset="0.375"/>
                   <GradientStop Color="#FFA3AEB9" Offset="1"/>
               </LinearGradientBrush>
           </Setter.Value>
       </Setter>
       <Setter Property="BorderThickness" Value="1"/>
       <Setter Property="Template">
           <Setter.Value>
               <ControlTemplate TargetType="controls:DatePicker">
                   <Grid x:Name="Root">
                       <Grid.Resources>
                           <SolidColorBrush x:Key="DisabledBrush" Color="#8CFFFFFF"/>
                               <ControlTemplate x:Key="DropDownButtonTemplate" TargetType="Button">
                                   <Grid>
                                       <VisualStateManager.VisualStateGroups>
                                           <VisualStateGroup x:Name="CommonStates">
                                               <VisualStateGroup.Transitions>
                                                   <VisualTransition GeneratedDuration="0"/>
                                                   <VisualTransition GeneratedDuration="0:0:0.1" To="MouseOver"/>
                                                   <VisualTransition GeneratedDuration="0:0:0.1" To="Pressed"/>
                                               </VisualStateGroup.Transitions>
                                               <VisualState x:Name="Normal"/>
                                               <VisualState x:Name="MouseOver">
                                                   <Storyboard>
                                                       <ColorAnimation Duration="0" Storyboard.TargetName="Background" Storyboard.TargetProperty="(Border.Background).(SolidColorBrush.Color)" To="#FF448DCA"/>
                                                       <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="BackgroundGradient" Storyboard.TargetProperty="(Border.Background).(GradientBrush.GradientStops)[3].(GradientStop.Color)">
                                                           <SplineColorKeyFrame KeyTime="0" Value="#7FFFFFFF"/>
                                                       </ColorAnimationUsingKeyFrames>
                                                       <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="BackgroundGradient" Storyboard.TargetProperty="(Border.Background).(GradientBrush.GradientStops)[2].(GradientStop.Color)">
                                                           <SplineColorKeyFrame KeyTime="0" Value="#CCFFFFFF"/>
                                                       </ColorAnimationUsingKeyFrames>
                                                       <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="BackgroundGradient" Storyboard.TargetProperty="(Border.Background).(GradientBrush.GradientStops)[1].(GradientStop.Color)">
                                                           <SplineColorKeyFrame KeyTime="0" Value="#F2FFFFFF"/>
                                                       </ColorAnimationUsingKeyFrames>
                                                   </Storyboard>
                                               </VisualState>
                                               <VisualState x:Name="Pressed">
                                                   <Storyboard>
                                                       <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="Background" Storyboard.TargetProperty="(Border.Background).(SolidColorBrush.Color)">
                                                           <SplineColorKeyFrame KeyTime="0" Value="#FF448DCA"/>
                                                       </ColorAnimationUsingKeyFrames>
                                                       <DoubleAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="Highlight" Storyboard.TargetProperty="(UIElement.Opacity)">
                                                           <SplineDoubleKeyFrame KeyTime="0" Value="1"/>
                                                       </DoubleAnimationUsingKeyFrames>
                                                       <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="BackgroundGradient" Storyboard.TargetProperty="(Border.Background).(GradientBrush.GradientStops)[1].(GradientStop.Color)">
                                                           <SplineColorKeyFrame KeyTime="0" Value="#EAFFFFFF"/>
                                                       </ColorAnimationUsingKeyFrames>
                                                       <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="BackgroundGradient" Storyboard.TargetProperty="(Border.Background).(GradientBrush.GradientStops)[2].(GradientStop.Color)">
                                                         <SplineColorKeyFrame KeyTime="0" Value="#C6FFFFFF"/>
                                                     </ColorAnimationUsingKeyFrames>
                                                     <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="BackgroundGradient" Storyboard.TargetProperty="(Border.Background).(GradientBrush.GradientStops)[3].(GradientStop.Color)">
                                                         <SplineColorKeyFrame KeyTime="0" Value="#6BFFFFFF"/>
                                                     </ColorAnimationUsingKeyFrames>
                                                     <ColorAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="BackgroundGradient" Storyboard.TargetProperty="(Border.Background).(GradientBrush.GradientStops)[0].(GradientStop.Color)">
                                                         <SplineColorKeyFrame KeyTime="0" Value="#F4FFFFFF"/>
                                                     </ColorAnimationUsingKeyFrames>
                                                 </Storyboard>
                                             </VisualState>
                                             <VisualState x:Name="Disabled">
                                                 <Storyboard>
                                                     <DoubleAnimationUsingKeyFrames BeginTime="0" Duration="00:00:00.001" Storyboard.TargetName="DisabledVisual" Storyboard.TargetProperty="(UIElement.Opacity)">
                                                         <SplineDoubleKeyFrame KeyTime="0" Value="1"/>
                                                     </DoubleAnimationUsingKeyFrames>
                                                 </Storyboard>
                                             </VisualState>
                                         </VisualStateGroup>
                                     </VisualStateManager.VisualStateGroups>
                                     <Grid Height="48" HorizontalAlignment="Center" Margin="0" VerticalAlignment="Center" Width="49" Background="#11FFFFFF">
                                         <Grid.ColumnDefinitions>
                                             <ColumnDefinition Width="6*"/>
                                             <ColumnDefinition Width="19*"/>
                                             <ColumnDefinition Width="19*"/>
                                             <ColumnDefinition Width="19*"/>
                                         </Grid.ColumnDefinitions>
                                         <Grid.RowDefinitions>
                                             <RowDefinition Height="6*"/>
                                             <RowDefinition Height="20*"/>
                                             <RowDefinition Height="20*"/>
                                             <RowDefinition Height="20*"/>
                                         </Grid.RowDefinitions>
                                         <Border x:Name="Highlight" Margin="-1" Opacity="0" Grid.ColumnSpan="4" Grid.Row="0" Grid.RowSpan="4" BorderBrush="#FF6DBDD1" BorderThickness="1" CornerRadius="0,0,1,1"/>
                                         <Border x:Name="Background" Margin="0,-1,0,0" Opacity="1" Grid.ColumnSpan="4" Grid.Row="1" Grid.RowSpan="3" Background="#FF1F3B53" BorderBrush="#FFFFFFFF" BorderThickness="1" CornerRadius=".5"/>
                                         <Border x:Name="BackgroundGradient" Margin="0,-1,0,0" Opacity="1" Grid.ColumnSpan="4" Grid.Row="1" Grid.RowSpan="3" BorderBrush="#BF000000" BorderThickness="1" CornerRadius=".5">
                                             <Border.Background>
                                                 <LinearGradientBrush EndPoint=".7,1" StartPoint=".7,0">
                                                     <GradientStop Color="#FFFFFFFF" Offset="0"/>
                                                     <GradientStop Color="#F9FFFFFF" Offset="0.375"/>
                                                     <GradientStop Color="#E5FFFFFF" Offset="0.625"/>
                                                     <GradientStop Color="#C6FFFFFF" Offset="1"/>
                                                 </LinearGradientBrush>
                                             </Border.Background>
                                         </Border>
                                         <Rectangle StrokeThickness="1" Grid.ColumnSpan="4" Grid.RowSpan="2" Margin="0,0,0,2">
                                             <Rectangle.Stroke>
                                                 <LinearGradientBrush EndPoint="0.48,-1" StartPoint="0.48,1.25">
                                                     <GradientStop Color="#FF494949"/>
                                                     <GradientStop Color="#FF9F9F9F" Offset="1"/>
                                                 </LinearGradientBrush>
                                             </Rectangle.Stroke>
                                             <Rectangle.Fill>
                                                 <LinearGradientBrush EndPoint="0.3,-1.1" StartPoint="0.46,1.6">
                                                     <GradientStop Color="#FFBD4A40"/>
                                                     <GradientStop Color="#FFEAAFAF" Offset="1"/>
                                                 </LinearGradientBrush>
                                             </Rectangle.Fill>
                                         </Rectangle>
                                         <TextBlock
                                             Text="Sept '08"
                                             HorizontalAlignment="Center" 
                                             VerticalAlignment="Center" 
                                             Margin="0,0,0,3"
                                             Grid.Column="0" 
                                             Grid.ColumnSpan="4" 
                                             Grid.Row="0" 
                                             Grid.RowSpan="2" 
                                             />
                                         <TextBlock
                                             Text="04"
                                             HorizontalAlignment="Center" 
                                             VerticalAlignment="Bottom" 
                                             FontSize="26" Margin="0,0,0,-3" 
                                             Grid.Column="0" 
                                             Grid.ColumnSpan="4" 
                                             Grid.Row="2" 
                                             Grid.RowSpan="2" />
                                         
                                         <Border x:Name="DisabledVisual" Opacity="0" Grid.ColumnSpan="4" Grid.Row="0" Grid.RowSpan="4" BorderBrush="#B2FFFFFF" BorderThickness="1" CornerRadius="0,0,.5,.5"/>
                                     </Grid>
                                 </Grid>
                             </ControlTemplate>
                         </Grid.Resources>
                         <Grid.ColumnDefinitions>
                             <ColumnDefinition Width="*"/>
                             <ColumnDefinition Width="Auto"/>
                         </Grid.ColumnDefinitions>
                         <VisualStateManager.VisualStateGroups>
                             <VisualStateGroup x:Name="CommonStates">
                                 <VisualState x:Name="Normal"/>
                                 <VisualState x:Name="Disabled">
                                     <Storyboard>
                                         <DoubleAnimation Duration="0" Storyboard.TargetName="DisabledVisual" Storyboard.TargetProperty="Opacity" To="1"/>
                                     </Storyboard>
                                 </VisualState>
                             </VisualStateGroup>
                         </VisualStateManager.VisualStateGroups>
                         <Button 
                             x:Name="Button" 
                             Margin="2,0,2,0" 
                             Width="50" 
                             BorderBrush="{TemplateBinding BorderBrush}" 
                             BorderThickness="{TemplateBinding BorderThickness}" 
                             Foreground="{TemplateBinding Foreground}" 
                             Template="{StaticResource DropDownButtonTemplate}" 
                             Content="{TemplateBinding SelectedDate}"
                             Grid.Column="1" />
                         <Grid x:Name="DisabledVisual" IsHitTestVisible="False" Opacity="0" Grid.ColumnSpan="2">
                             <Grid.ColumnDefinitions>
                                 <ColumnDefinition Width="*"/>
                                 <ColumnDefinition Width="Auto"/>
                             </Grid.ColumnDefinitions>
                             <Rectangle Fill="#8CFFFFFF" RadiusX="1" RadiusY="1"/>
                             <Rectangle Fill="#8CFFFFFF" RadiusX="1" RadiusY="1" Height="18" Margin="2,0,2,0" Width="19" Grid.Column="1"/>
                         </Grid>
                         <Popup x:Name="Popup"/>
                     </Grid>
                 </ControlTemplate>
             </Setter.Value>
         </Setter>
     </Style>

If you followed the steps from the previous section, just replace the style created by those steps with the code here. If you skipped those steps or are following along in Visual Studio, just paste this code into your App.xaml file inside your `Application.Resources` element. Then make sure to add the following namespace declaration from line 4 below to your App.xaml file as well:

     <Application
         xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
         xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
         xmlns:controls="clr-namespace:System.Windows.Controls;assembly=System.Windows.Controls" 
         x:Class="iTouchDatePicker.App">

Now our style is complete (mwahaha!). Save App.xaml and return to the xaml file for our User Control so we can apply the changes to our `DatePicker` control. Change the `DatePicker` control to look like this:

    <controls:DatePicker Style="{StaticResource iTouchDatePickerStyle}" />

Now we should see our custom style applied in the designer window, but we still need to get binding setup or the user will never be able to see anything other than the values which are hard-coded into our template.

##Adding Bindings

I cannot take credit for figuring this part out. I was able to figure out a solution, but it involved a custom implementation which inherited from the original `DatePicker` control class. The credit for figuring out how to do this entirely in Xaml goes to Shawn Oster, Silverlight Program Manager. He worked out how to get the binding to work with the original developer of the the `DatePicker` control (I don't know his name or I'd also credit him). But anyway, to add the bindings you want to modify lines 118 and 128 above as follows:

Line 118 (the month and year):

    DataContext="{Binding Path=Content, RelativeSource={RelativeSource TemplatedParent}}"
    Text="{Binding Converter={StaticResource DateTimeFormatter}, ConverterParameter=MMM yy }"

Line 128 (the day):

    DataContext="{Binding Path=Content, RelativeSource={RelativeSource TemplatedParent}}"
    Text="{Binding Converter={StaticResource DateTimeFormatter}, ConverterParameter=dd }"

Ok, I know I said "entirely in xaml", and I am using a converter here to format the date. But I'm going to declare the use of converters "not cheating" when it comes to creating a solution entirely in xaml. Argue your point with me if you disagree, I'd be interested to hear it and would love to learn something new. But aside from arguing the point, here's the code for the converter:

    using System;
    using System.Windows.Data;
    using System.Globalization;
     
    namespace iTouchDatePicker
    {
        public class DateTimeConverter : IValueConverter
        {
            public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
            {
                DateTime? selectedDate = value as DateTime?;
     
                if (selectedDate != null)
                {
                    string dateTimeFormat = parameter as string;
                    return selectedDate.Value.ToString(dateTimeFormat);
                }
     
                return string.Empty;
            }
     
            public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
            {
                throw new NotImplementedException();
            }
        }
    }

Now just add a static resource (lines 5 and 8) for your converter to your app.xaml as well:


     <Application
         xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
         xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
         xmlns:controls="clr-namespace:System.Windows.Controls;assembly=System.Windows.Controls" 
         xmlns:iTouch="clr-namespace:iTouchDatePicker"
         x:Class="iTouchDatePicker.App">
         <Application.Resources>
             <iTouch:DateTimeConverter x:Key="DateTimeFormatter" />

~~But wait! Those of you using Blend 3 are seeing an "Invalid Xaml" error for our bindings! Yes, so do I. I've tried getting an answer about this, but I haven't ever gotten one. It would seem the parsing engine for Blend 3 doesn't like this binding. However, it actually works. When we're finished, if you run our project when it loads into a web browser it actually works. When this gets in the way of my design in Blend, I just revert my template back to hard-coded text instead of the bindings so I can use the Blend designer. Not ideal, but I haven't been able to figure anything out. If you do, let me know.~~

**UPDATE 10/12/2009**: Thanks to mitkodi for providing the workaround for the "Invalid Xaml" error in Blend. The problem was using both a converter and a `RelativeSource` binding in the same Binding expression. By breaking them up and assigning the `ReleativeSource` to `DataContext` and the Converter to the Text attribute the issue is fixed and you can now work with the control in Blend. 


The last piece is to just bind a value to our `DatePicker`. So, first lets set our `DataContext` to the current `DateTime`:

    using System;
    using System.Windows;
    using System.Windows.Controls;
 
    namespace iTouchDatePicker
    {
        public partial class MainPage : UserControl
        {
            public MainPage()
            {
                // Required to initialize variables
                InitializeComponent();

                this.DataContext = DateTime.Now;
            }
        }
    }

Add line 14 above to your `UserControl`'s code-behind. Then update the `DatePicker` control (line 10) with `SelectedDate="{Binding}"` like below:


    <UserControl
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:controls="clr-namespace:System.Windows.Controls;assembly=System.Windows.Controls"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:sys="clr-namespace:System;assembly=mscorlib"
        x:Class="iTouchDatePicker.MainPage"
        Width="640" Height="480" mc:Ignorable="d">
        <Grid x:Name="LayoutRoot" Background="White">
            <controls:DatePicker HorizontalAlignment="Left" VerticalAlignment="Top" 
            Style="{StaticResource iTouchDatePickerStyle}" SelectedDate="{Binding}" />
        </Grid>
    </UserControl>

Now build and run the project and there you have it! I hope you enjoy, I'd love to see any improvements anyone makes.

[Source Code](http://dvm-public-assets.s3.amazonaws.com/silverlight/iTouchDatePicker.zip)
