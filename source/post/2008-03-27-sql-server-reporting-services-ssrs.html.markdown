---
layout: post
title: 'SQL Server Reporting Services (SSRS): Databinding with CustomReportItem implementation'
date: '2008-03-27 19:04:00'
tags:
- customreportitem
- ssrs
- sql_server_reporting_services
- cri
---

For my current project, I've been attempting something that would seem simple to do, but can't be done in Sql Server Reporting Services (SSRS). I am trying to draw 2 simple rectangles on the grid of a scatter (XY) chart. The reason for doing this is to visually indicate good and bad regions of data. But when the report is rendered (at least using the Html viewer) the rectanges I draw above the chart have moved. This is because items cannot overlap in the web viewer.

I have come to find that I can create a CustomReportItem based on any image I can draw or retrieve (Gdi+ or any other method of creating an image like the file system or a remote url). So I started looking at the alternative charting options I had available to me through my client's software licenses.

My options were charting solutions by ComponentArts and Infragistics (UltraChart). As it stands the ComponentArts documentation was dismal and I am still waiting to hear back about a message I posted on their forum over a week ago. With Infragistics I found the documentation much better. When I needed help I got an immediate response.

So I am using Infragistics for my charting needs. The solution involves creating a custom report item which allows the user to define a set of properties which I then use to design the chart. I am actually using the Web version of UltraChart, which is not supported, but works well. I could have used the WinForms version, but it doesn't seem to make any difference and I didn't have it installed at the time I began my discovery.

The next problem I encountered was creating the CustomReportItem. Again, like the ComponentArts library, the documentation was pitiful. But here are the links I did find to nonetheless. This was difficult to track down :

Rdl definitions: http://download.microsoft.com/download/c/2/0/c2091a26-d7bf-4464-8535-dbc31fb45d3c/rdlNov05.pdf . When you are working on your designer class, this will make sure the xml output is correct (hint: pay attention to all the 1-N, 0-1, 1 designations to know what's required and what's optional).

Custom Report Item docs: http://msdn2.microsoft.com/en-us/library/ms345224.aspx . For whatever reason I didn't find this when I first started searching. It never came up in google. I found it later when I was looking for information on a specific class.

MSDN Magazine: http://msdn2.microsoft.com/en-us/magazine/cc188686.aspx . A pretty good learning example, but didn't have everything I need. Also, there was no direct link to the source code. You have to download the source for the entire issue and extract it locally. The source can be found here: http://download.microsoft.com/download/f/2/7/f279e71e-efb0-4155-873d-5554a0608523/MSDNMag2006_10.exe

A data bound example of drawing polygons by Chris Hays: http://blogs.msdn.com/chrishays/archive/2005/10/04/CustomReportItemSample.aspx . The code was difficult to follow and there weren't many comments. This didn't help me until the end when I understood more of what was going on. Also, you have to register with the group before you can download the code.

The last problem I had to solve was how to bind a dataset to my custom report item. The only thing that really helped me here was the Rdl documentation. The problem was that the code which was relevant to performing this operation was uncommented and wasn't explained anywhere in the documentation or samples. So here's my own databinding snippets with comments and explaination.

A) In the CustomReportItemDesigner class (your custom class which inherits from it as a base), override the InitializeNewComponent() method like this:




    public override void InitializeNewComponent()
    {
     base.InitializeNewComponent();
    
     CustomData = new CustomData();
    
     //at least one grouping is required for both rows and columns
    
     //initialize row grouping
     CustomData.DataRowGroupings = new DataRowGroupings();
     CustomData.DataRowGroupings.DataGroupings = new List<DataGrouping>(1);
     CustomData.DataRowGroupings.DataGroupings.Add(new DataGrouping());
     CustomData.DataRowGroupings.DataGroupings[0].Grouping = new Grouping();
     CustomData.DataRowGroupings.DataGroupings[0].Grouping.Name = Name + "_Row";
     CustomData.DataRowGroupings.DataGroupings[0].Grouping.GroupExpressions = new GroupExpressions();
     CustomData.DataRowGroupings.DataGroupings[0].Grouping.GroupExpressions.Add(new Expression());
    
     // initialize a Static column grouping
     CustomData.DataColumnGroupings = new DataColumnGroupings();
     CustomData.DataColumnGroupings.DataGroupings = new List<DataGrouping>(1);
     CustomData.DataColumnGroupings.DataGroupings.Add(new DataGrouping());
     CustomData.DataColumnGroupings.DataGroupings[0].Static = true;
    
     //initialize data row with empty values for designer
     CustomData.DataRows = new List<DataRow>(1);
     CustomData.DataRows.Add(new DataRow());
     CustomData.DataRows[0].Add(new DataCell());
    
     //define the fields you will store (these will be populated with expressions by custom designer properties you define)
     CustomData.DataRows[0][0].Add(new DataValue("X", String.Empty));
     CustomData.DataRows[0][0].Add(new DataValue("Y", String.Empty));
    }

B) Define a custom designer property to set the expression for your data row group.

        [Browsable(true), Category("Data")]
        public string LabelValue
        {
            get
            {
                if (CustomData.DataRowGroupings.DataGroupings.Count > 0)
                {
                    return GetGroupLabel(CustomData.DataRowGroupings.DataGroupings[0].Grouping);
                }
                else
                    return "Point Label";
            }
            set
            {
                CustomData.DataRowGroupings.DataGroupings[0].Grouping.GroupExpressions[0].String = value;
            }
        }

        private string GetGroupLabel(Grouping group)
        {
            if (group.GroupExpressions != null && group.GroupExpressions.Count > 0)
                return group.GroupExpressions[0].String;

            return null;
        }

C) Define custom designer properties to set the expressions for the DataValuesCollection (only showing one property here to keep things shorter)

    public string XValue
    {
     get
     {
      if (CustomData.DataRows.Count > 0 && CustomData.DataRows[0].Count > 0)
       return GetDataValue(CustomData.DataRows[0][0], "X");
      else
       return "X Coordinate";
     }
     set
     {
      SetDataValue(CustomData.DataRows[0][0], "X", value);
     }
    }
    
    
    private string GetDataValue(DataCell cell, string name)
    {
     foreach (DataValue value in cell)
      if (value.Name == name)
       return value.Value;
     return null;
    }
    
    private void SetDataValue(DataCell cell, string name, string expression)
    {
     foreach (DataValue value in cell)
      if (value.Name == name)
      {
       value.Value = expression;
       return;
      }
     DataValue datavalue = new DataValue(name, expression);
     cell.Add(datavalue);
    }

D) Make sure your designer provides a property to set the data set name (CustomData.DataSetName).

E) Your CustomReportItem class can then read the data like this:


    private void ReadCustomData()
    {
     DataMemberCollection members = m_CRI.CustomData.DataRowGroupings[0];
     DataCellCollection rows = m_CRI.CustomData.DataCells;
    
     //get the position of each field in the data value collection
     int xpos = -1, ypos = -1;
    
     for (int field = 0; field < rows[0, 0].DataValues.Count; field++)
     {
      switch (rows[0, 0].DataValues[field].Name)
      {
       case "X":
        xpos = field;
        break;
       case "Y":
        ypos = field;
        break;
      }
     }
    
     //populate the series for the chart data
     for (int row = 0; row < rows.RowCount; row++)
     {
      DataValueCollection values = rows[row, 0].DataValues;
    
      String label = members[row].GroupValues[0].ToString();
    
      double x = Convert.ToDouble(values[xpos].Value);
      double y = Convert.ToDouble(values[ypos].Value);
     }
    }

I haven't posted the full code here but I plan on doing so in the future. I also plan on dressing this post up and making a codeproject article out of it.
