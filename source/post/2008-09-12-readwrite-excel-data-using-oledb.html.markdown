---
layout: post
title: Read/Write Excel data using OleDb
date: '2008-09-12 17:47:00'
---

I haven't worked with Excel much since my early days of writing macros using VBA. That's when I got my first taste of programming - I've been hooked ever since. But that was 8 years ago, and since then the only thing I do with Excel is use it to send a list of my deductions to my accountant or if I get an excel file at work, I just import it using the SSMS import wizard.

But this week I had two projects back-to-back involving Excel files. The first involved writing data from a query to a worksheet. The second involved reading data from a worksheet. I figured it would make a good post to talk about what I learned in the process.

#Communicating with Excel

The first project was an ASP.NET application which was using Excel for charting data. We chose Excel over reporting services because Excel's charting capabilities had what we needed built-in, while RS required custom work (See my post on extending [Reporting Services](/2008/03/sql-server-reporting-services-ssrs/) to include custom charts). The constraints I was under included the prohibition of installing MS Office on the web server (with good reason).

So after some digging around I decided OleDb would be the best option. OleDb drivers for Excel are already installed everywhere and they don't require the overhead of opening Excel in the background and manipulating the file.

Here's how you write to an excel file in ASP.NET:




    protected void m_GetReport_Click ( Object sender, EventArgs e )
    {
        Guid fileId = Guid.NewGuid();
        
        Object[] data = new Object[4]{};
        data[0] = "name";
        data[1] = DateTime.Now;
        data[2] = 332;
    
        
        //some really long text
        data[3] = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Praesent fringilla. "
            + "Vestibulum molestie blandit leo. Nunc interdum, dolor eu faucibus mattis, nulla sapien "
            + "tempus mauris, eget ultrices urna tellus eu ipsum. Curabitur feugiat. In ligula felis, "
            + "tristique vel, imperdiet a, tincidunt sit amet, libero. Pellentesque habitant morbi "
            + "tristique senectus et netus et malesuada fames ac turpis egestas. In hac habitasse platea "
            + "dictumst. Aliquam mi. Aenean ac lacus. Fusce luctus urna nec ante. Fusce sed sapien nec "
    
            + "lorem blandit condimentum. Duis risus neque, aliquam a, condimentum at, commodo quis, "
            + "justo. Nam eros dolor, lacinia quis, sodales in, dictum ut, pede. Sed accumsan lacinia neque. "
            + "Donec non odio vitae tortor volutpat ornare. Aliquam ac quam sit amet mauris porttitor "
            + "tristique. Quisque commodo enim eget pede. Etiam consequat luctus felis. Class aptent "
            + "taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Maecenas "
            + "neque elit, rutrum nec, sollicitudin nec, aliquam vel, enim. Mauris odio. Nam mollis. "
            + "Donec varius, felis eget sollicitudin placerat, sem justo commodo eros, non faucibus "
            + "diam purus vitae magna. Nulla lectus. Vestibulum varius arcu euismod massa. Aenean sit "
            + "amet urna eget nibh accumsan condimentum. Nullam lobortis aliquet justo. Curabitur mattis "
            + "tincidunt sapien. Donec dapibus, neque eget suscipit rutrum, erat lectus pulvinar enim, "
            + "tincidunt molestie elit augue ac urna. Phasellus vel dui at ligula congue accumsan. "
            + "Aliquam sed massa vel justo gravida pharetra. Ut eros quam, laoreet et, ullamcorper sit "
    
            + "amet, fringilla quis, enim. Suspendisse sed metus. Pellentesque eleifend. ";
     
    
            String destination = Server.MapPath( String.Format( "~/xltemp/{0}.xls", fileId ) );
     
    
            try
            {
                File.Copy( Server.MapPath( "~/xlreports/Report.xls" ), destination );
     
                using ( OleDbConnection conn = new OleDbConnection( 
                    String.Format( "provider=Microsoft.Jet.OLEDB.4.0; Data Source='{0}';"
                     + "Extended Properties='Excel 8.0;HDR=YES;'", destination ) ) )
                {
    
                    conn.Open();
     
                    // drop the worksheet if it already exists so we can define it ourselves
                    if(conn.GetSchema("Tables", new String[]{null, null, "Data$", null}).Rows.Count != 0)
                    {
                        using ( OleDbCommand cmd = new OleDbCommand( "DROP TABLE [Data$]", conn ) )
                            cmd.ExecuteNonQuery();
                    }
    
                    
                    // by creating the worksheet from scratch we can explicitly tell Excel 
                    // the data type of each column
                    using ( OleDbCommand cmd = new OleDbCommand( "CREATE TABLE [Data$]([Column1] VARCHAR(255),"
                        +"[Column2] DATE,[Column3] INTEGER,[Column4] LONGTEXT)", conn ) )
                        cmd.ExecuteNonQuery();
                    
                    //insert our data
                    using ( OleDbCommand cmd = new OleDbCommand( "INSERT INTO [Data$] "
                        + "([Column1],[Column2],[Column3],[Column4]) VALUES (?,?,?,?)" ) )
                    {
                        cmd.Connection = conn;
     
                        cmd.Parameters.Add( "@p1", OleDbType.VarChar );
                        cmd.Parameters.Add( "@p2", OleDbType.Date );
                        cmd.Parameters.Add( "@p3", OleDbType.Integer );
                        cmd.Parameters.Add( "@p4", OleDbType.LongVarChar );
     
                        for(int i = 0; i < 5; i++)
                        {
                            cmd.Parameters["@p1"].Value = data[0];
                            cmd.Parameters["@p2"].Value = data[1];
                            cmd.Parameters["@p3"].Value = data[2];
                            cmd.Parameters["@p4"].Value = data[3];
     
    
                            cmd.ExecuteNonQuery();
                        }
                    }
     
                }
                
                //redirect our user to our report handler page so we can give them a 
                //file download box for the excel file
                Response.Redirect( String.Format( 
                    "DownloadReport.ashx?FileID={0}", fileId ) );
            }
            catch ( System.Threading.ThreadAbortException )
            {
                // ignore redirect
            }
            catch ( Exception ex )
            {
                m_ErrorMessage.Text = ex.Message;
                m_ErrorMessage.Visible = true;
     
                if ( File.Exists( destination ) )
                    File.Delete( destination );
            }
    }
     

First, I am making a copy of the Excel file. Since we are working in a multi-threaded environment (ASP.NET) we don't want two users writing to the same file and then downloading it. You'll end up with a race condition where the first user is likely to get a result with the second user's data. So I generate a Guid to be used as the file name to prevent any possible clashes and I copy it to a temp directory which will be cleaned up when we're finished.

Second, something I didn't notice at first was that the 'Extended Properties' portion of the connection string was its own collection of properties. From what I've seen you don't have to quote the separate properties when you're only specifying one (ex. Excel 8.0), but I recommend for clarity that you make sure and quote these even if there is only one.

Third, we want to tell our provider we are working with column headers to specifing 'HDR=YES;'. This way the provider will allow us to use the column names in our command.

Fourth, I had an issue where the output in my integer column wasn't being formatted as an integer. And because I can't tell the user "who cares", I tried to figure out how to get excel to recognize that the column should be numeric. In the end the easiest way to do this was to delete the worksheet and recreate it, specifying the type of each column. So I use the OleDb GetSchema method to query the list of "Tables" for a sheet named "Data$". I looked at MSDN for the order and name of the parameters passed in the String array, but I didn't find them specifically mentioned. But the 3rd one is the sheet name. As you can see later we can use this to filter our column names as well for the sheet we're interested in.

Another interesting tidbit I ran into here was that if there was existing "test data" in the worksheet, that for some reason Excel enters blank lines for those records. So if there were 100 existing records, my data will be inserted starting at row 101. I solved this by just deleting the records in my original file. But I imagine that if you run a delete statement (DELETE FROM [Data$]) either before you write to the file or before you delete (DROP) the worksheet it should take care of it.

Fifth, notice that for some reason you must append the '$' symbol to the end of the worksheet name. I didn't take the time to figure this out as it doesn't seem to matter, other than it is important that you include it if you want it to work.

Sixth, I make it a habit to ALWAYS use parameters when working with SQL statements. While I don't know if Excel is vulnerable to injection attacks, I believe the question is irrelivent. I strongly believe that you should NEVER make it possible for your data to be executed in any context. When it comes to SQL you can accomplish this using parameters and so that is what I recommend.

After writing the file you can do what you like with it. In this example (as I believe is the most common case in this scenario), I want to allow the user to download the file. So here I redirect the user to a Generic Handler (ashx). Here's the code for the handler:


    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web;
    using System.IO;
    using System.Threading;
     
    namespace MyExcelWebApplication
    {
    
        /// <summary>
        /// Summary description for Report
        /// </summary>
        public class Report : IHttpHandler
        {
            private const Int64 m_OneMinute = 60000;
     
            public void ProcessRequest ( HttpContext context )
            {
                context.Response.ContentType = "application/x-excel";
     
                if ( String.IsNullOrEmpty( 
                    context.Request.QueryString["FileID"] ) )
                    return;
     
                String path = context.Server.MapPath( 
                    String.Format( "~/xltemp/{0}.xls", 
                        context.Request.QueryString["FileID"] ) );
     
                context.Response.AddHeader( "content-disposition", 
                    "attachment; filename=Report.xls" );
                
                context.Response.TransmitFile( path );
     
                // if we delete the file right away the transmit 
                // will fail. Give the user time to download the 
                // file, then delete it on a separate thread
                Timer t = new Timer( FileCleanup, path, 
                    Convert.ToInt64( m_OneMinute * 20 ), -1 );
            }
     
            /// <summary>
            /// Callback for timer object. Used to schedule a 
            /// delay before cleanup of temp file
            /// </summary>
            /// <param name="state"></param>
            private static void FileCleanup ( Object state )
            {
                //get the path to the file
                String path = state as String;
     
                //if a string wasn't passed we can't cleanup
                if ( path == null )
                    return;
     
                // delete the file
                File.Delete( path );
            }
     
            public bool IsReusable
            {
    
                get
                {
                    return false;
                }
    
            }
        }
    }
    

Here things are pretty straight forward. We set the content type of the response and add the 'content-disposition' header to "attachment; filename=Report.xls" so our user will get a download prompt with a default filename.

Next we use the Response.TransmitFile method instead of opening a FileStream object and saving it to the response stream. The reason, if you don't already know, is because TransmitFile will bypass the IIS/ASP.NET pipe. So instead of the file being passed in memory, ASP.NET passes the file handle to IIS which can then stream the object without loading it into memory. You should use TransmitFile over streaming whenever possible to reduce the amount of memory being used by IIS and ASP.NET.

Lastly we set a timer event to cleanup the file later. If we try and clean up right away we'll delete the file before the user can actually download it.

#Reading from Excel

The next project I worked on this week involved reading an Excel file and creating a tab-delimited text file from a specified worksheet. This project involved an existing Windows Service which checked a specified directory every 30 seconds. The main method below is GetXLData(). This calls each of the needed methods to read the data and convert it. There's not a whole lot to explain here. I wasn't the principal developer on this project so I broke everything into small reusable blocks that are pretty self documenting. All the same principals discussed above (other than those specific to ASP.NET) apply here as well.



    protected string XLFilePath
    {
        get { return BaseFilePath 
            + ConfigurationManager.AppSettings["XLFilePath"]; }
    }
    protected string XLTextFilePath
    {
        get { return BaseFilePath 
            + ConfigurationManager.AppSettings["XLTextFilePath"]; }
    }
    protected string XLWorksheetName
    {
        get { return ConfigurationManager.AppSettings["XLWorksheetName"]; }
    }
    protected string LogFilePath
    {
        get { return BaseFilePath 
            + ConfigurationManager.AppSettings["LogFile"]; }
    }
    protected string BaseFilePath
    {
        get 
        { 
    #if DEBUG
            return ConfigurationManager.AppSettings["BaseFilePath.Local"];
    #else
            return ConfigurationManager.AppSettings["BaseFilePath"]; 
    #endif
        }
    }
     
    protected override void OnStart(string[] args)
    {
        WriteToLog("Service Started");
        timer.Elapsed += new ElapsedEventHandler(timer_Elapsed);
        timer.Interval = TimeSpan.FromMinutes(RefreshRateMinutes).TotalMilliseconds;
        timer.Start();
    }
     
    void timer_Elapsed(object sender, ElapsedEventArgs e)
    {
        GetXLData();
    }
     
    protected void GetXLData ()
    {
        String header = String.Empty;
        String data = String.Empty;
     
        try
        {
            using ( OleDbConnection conn = new OleDbConnection( 
                String.Format( "provider=Microsoft.Jet.OLEDB.4.0; " +
                    "data source={0};Extended Properties='Excel 8.0;HDR=YES;'", 
                        XLFilePath ) ) )
            {
                DataTable dt = XLGetWorksheetColumns( conn, XLWorksheetName );
                header = XLConvertColumnsToText( dt );
     
                using ( OleDbDataReader rdr = XLGetWorksheetDataReader( 
                    conn, XLWorksheetName ) )
                {
                    if ( rdr != null )
                    {
                        data = XLConvertDataToText( rdr );
                    }
                }
            }
     
            if ( File.Exists( XLTextFilePath ) )
                File.Delete( XLTextFilePath );
     
            using ( StreamWriter stream = File.CreateText( XLTextFilePath ) )
            {
                if ( !String.IsNullOrEmpty( header ) )
                    stream.WriteLine( header );
     
                stream.Write( data );
            }
     
            WriteToLog( "XL file updated." );
        }
        catch ( Exception ex )
        {
            WriteToLog( "GetXLData: " + ex.Message );
        }
    }
     
    protected DataTable XLGetWorksheetColumns ( 
        OleDbConnection conn, String name )
    {
        DataTable schema = new DataTable();
     
        Boolean closeConn = false;
        try
        {
            if ( conn.State != ConnectionState.Open )
            {
                conn.Open();
                closeConn = true;
            }
     
            schema = conn.GetSchema( "Columns", 
                new String[] { null, null, name, null } );
     
        }
        finally
        {
            if ( closeConn 
                && ( conn.State & ConnectionState.Open ) == ConnectionState.Open )
            {
                conn.Close();
            }
        }
     
        return schema;
    }
     
    protected Boolean XLWorksheetExists ( OleDbConnection conn, String name )
    {
        Boolean closeConn = false;
        try
        {
            if ( conn.State != ConnectionState.Open )
            {
                conn.Open();
                closeConn = true;
            }
     
            DataTable worksheets = conn.GetSchema( "Tables", 
                new String[]{null, null, name, null} );
     
            if ( worksheets.Select( String.Format( "TABLE_NAME='{0}'", 
                                        name ) ).Length != 0 )
                return true;
        }
        finally
        {
            if ( closeConn && 
                ( conn.State & ConnectionState.Open ) == ConnectionState.Open )
            {
                conn.Close();
            }
        }
     
        return false;
    }
     
    protected OleDbDataReader XLGetWorksheetDataReader ( 
        OleDbConnection conn, String name )
    {
        if ( conn.State != ConnectionState.Open )
        {
            conn.Open();
        }
     
        if ( !XLWorksheetExists( conn, name ) )
        {
            WriteToLog( String.Format( "XLGetWorksheetDataReader: worksheet "
                + "'{0}'  in '{1}' does not exist.", name, XLFilePath ) );
            return null;
        }
     
        using ( OleDbCommand cmd = new OleDbCommand( 
            String.Format( "SELECT * FROM [{0}]", name ), conn ) )
        {
            return cmd.ExecuteReader();
        }
    }
     
    protected String XLConvertColumnsToText ( DataTable dt )
    {
        StringBuilder output = new StringBuilder();
     
        if ( dt.Rows.Count == 0 )
            return String.Empty;
     
        for ( int row = 0; row < dt.Rows.Count; row++ )
        {
            if ( row != 0 )
                output.Append( "\t" );
     
            output.Append( dt.Rows[row]["COLUMN_NAME"] );
        }
     
        return output.ToString();
    }
     
    protected String XLConvertDataToText ( OleDbDataReader rdr )
    {
        if ( !rdr.HasRows )
            return String.Empty;
     
        StringBuilder output = new StringBuilder();
     
        while ( rdr.Read() )
        {
            for ( int column = 0; column < rdr.FieldCount; column++ )
            {
                if ( column != 0 )
                    output.Append( "\t" );
     
                if ( rdr.IsDBNull( column ) )
                    continue;
     
                output.Append( rdr[column] );
            }
     
            output.Append( "\r\n" );
        }
     
        return output.ToString();
    }
     
    private void WriteToLog(string text)
    {
        TextWriter writer = File.AppendText(LogFilePath);
        writer.WriteLine(string.Format("Date: {0} - {1}", 
            DateTime.Now.ToString("MM/dd/yyyy HH:mm"), text));
        writer.Close();
    }
    protected override void OnStop()
    {
        timer.Stop();
        WriteToLog("Service Stopped");
    }
 
So there it is for all to see. I had been adverse to any use of Excel with ASP.NET before, but now I see that it is not only easy to use but we can now sidestep all of the performance issues involved as well. The workbook can do what it does best and all I have to do from an application perspective is dump the data (or read it out) and leave the rest alone.
