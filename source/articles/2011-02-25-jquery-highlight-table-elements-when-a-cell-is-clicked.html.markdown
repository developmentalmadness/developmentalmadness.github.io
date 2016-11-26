---
layout: post
title: 'jQuery: Highlight table elements when a cell is clicked'
date: '2011-02-25 16:53:00'
tags:
- jquery
- javascript
---

In a recent interview I was given an assignment to be completed before the phone interview. The assignment was to highlight the appropriate cell, column and row elements in an HTML table when the table cell was clicked. I was allowed to use any JavaScript framework I wanted. The result was expected to look exactly like this when a cell was clicked:

[Working demo](http://web.archive.org/web/20111005203039/http://developmentalmadness.com/SampleCode/jQuery/cell-row-column-highlighting.aspx)

<p><table style="width: 800px" id="browsers" border="0" cellspacing="0" cellpadding="0"><thead>     <tr>       <th>Rendering engine</th>        <th>Browser</th>        <th>Platform(s)</th>        <th>Engine version</th>        <th>CSS grade</th>     </tr>   </thead><tbody>     <tr>       <td>Gecko</td>        <td style="background-color: orange">Firefox 1.0</td>        <td>Win 98+ / OSX.2+</td>        <td>1.7</td>        <td>A</td>     </tr>      <tr style="background-color: yellow">       <td>Gecko</td>        <td style="background-color: red">Firefox 1.5</td>        <td>Win 98+ / OSX.2+</td>        <td>1.8</td>        <td>A</td>     </tr>      <tr>       <td>Gecko</td>        <td style="background-color: orange">Firefox 2.0</td>        <td>Win 98+ / OSX.2+</td>        <td>1.8</td>        <td>A</td>     </tr>      <tr>       <td>Gecko</td>        <td style="background-color: orange">Firefox 3.0</td>        <td>Win 2k+ / OSX.3+</td>        <td>1.9</td>        <td>A</td>     </tr>      <tr>       <td>Gecko</td>        <td style="background-color: orange">Camino 1.0</td>        <td>OSX.2+</td>        <td>1.8</td>        <td>A</td>     </tr>   </tbody></table></p>


Those who know me well (as well as those observant enough to notice) know despite the blogging I’ve done on Silverlight/WPF and ASP.NET MVC and my knowledge of the subject matter I really don’t like working much in the UI layer. So much so that I’ve always been more than willing to let those more interested (and capable) to take the reigns and handle as much of the JavaScript code as I could avoid. I’m not saying I can’t write JavaScript, I’m just saying I make sure I can do what I need to get my job done and no more. As a good friend puts it – I’m lazy (about JavaScript anyway).

Back to the interview assignment. I was open about my JavaScript skills (or limitations thereof) with the interviewer and maybe that’s why the assignment involved JavaScript – they wanted to see where I was at. Well, I was able to get it done in a reasonable amount of time. Also since I was impressed with the result and the interviewer liked it as well, I thought I’d share it here.

There’s nothing fancy about it, although this was my first ever attempt at extending jQuery, but I like the result. Here’s the code:

    $(function(){
        $("td").click(function(){
            var cell = $(this);
            var row = cell.parent();
            var col = cell.parents("table").find("td:nth-child(" + (cell.index() + 1) + ")");
            
            // make row yellow
            row.css({backgroundColor: "Yellow"}).resetBackground();
            // make column orange
            col.css({backgroundColor :"Orange"}).resetBackground();
            // make cell red
            cell.css({backgroundColor: "Red"}).resetBackground();
        });
    });
     
    (function($){
        $.fn.resetBackground = function() { 
            $(this).stop().animate({ backgroundColor : "#fff" }, 1500, function(){ 
                $(this).css({ backgroundColor : "" }); 
            });
        };
    }(jQuery));

First, we’re just registering for the ‘click’ event of the ‘td’ element. Then storing references to the cell and row – easy enough. But then the next line took some digging for me to find. ‘Column’ is not an explicit element in an HTML table. Instead, you have a collection of vertically aligned ‘td’ elements (cells). So in order to get a reference to a ‘column’ you need to:

1. Get a reference to the table element – cell.parents(“table”)
* Get the index of the td element that was clicked – $(this).index()
* Use the find() method to get the collection of cells with the same index  - td:nth-child(int)

A couple of caveats, the nth-child selector isn’t zero-based, it’s one-based, so you’ll need to increment #2 by a value of 1. Also, this method does not take the ‘colspan’ attribute into account. But other than that you now have a reference to the cell, row and column that were clicked.

Next, setting the background color is pretty simple using the css() method. But I wanted the demo to be usable – what application would ever just change the color and leave it? What happens when the next cell is clicked? You could reset the whole table, but I thought it would be fun to have the background fade back to white. So using the jQueryUI animate method I set the background color back to white with a timeout of 1500 milliseconds.

Lastly, once I had this working I found a weird behavior. The cells I had previously clicked remained white the next time a cell in the same row was clicked. The column background continued to work and didn’t behave this way, but because the cell’s background property overrides the background property of the row I had to reset the background-color property of the cell after the animation was complete. So that’s why I added a function to completely clear out the background color property of the cell to the complete parameter of the animate method.

Mostly, this is for my own benefit but I hope maybe this helps someone else with their jQuery adventures.
