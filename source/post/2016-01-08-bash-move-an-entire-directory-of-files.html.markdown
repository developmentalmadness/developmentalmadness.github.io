---
layout: post
title: 'Bash: Move an Entire Directory of Files'
date: '2016-01-08 16:02:00'
tags:
- linux
- bash
- xargs
- grep
---

I recently wanted to nest all the files in a folder one level deeper. Which meant I needed to move all the files except for the nested folder I created. This will move all files, excluding the directory `new-folder`: 

    ls|grep -v new-folder|xargs -I % mv % new-folder/

If you want to move only files and exclude all folders

    ls -p|grep -v /|xargs -I % mv % new-folder/

And if you're only moving folders and excluding files then run this:

    ls -d */|grep -v new-folder/|xargs -I % mv % new-folder

#Explaination

Let's start with a directory and put some files in it:

    $ mkdir my-folder
    $ cd my-folder
    $ touch f1.txt
    $ touch f2.txt
    $ touch f3.txt
    $ touch f1.html
    $ touch f2.html
    $ touch f3.html
    $ mkdir folder1
    $ mkdir folder2

**NOTE:** For those new to the bash shell I am using `$` to represent each command prompt. It is assumed you will not enter it as part of any commands in this post. The symbol will make it more clear which lines are commands and help delimit lists of commands. 

Now let's create the nested folder where we want to move our content:

    $ mkdir new-folder

First, let's break down the command starting with `ls`:

    $ ls
    f1.html		f1.txt		f2.html		f2.txt		f3.html		f3.txt		folder1	folder2	new-folder

Next we would want to exclude our target directory `new-folder` so we'll pipe `|` the output to `grep` (I'll get back to the `-p` option later):

    $ ls|grep -v new-folder
    f1.html
    f1.txt
    f2.html
    f2.txt
    f3.html
    f3.txt
    folder1
    folder2

The `-v` option of `grep` excludes a file so we can see that we get the entire list of files in the directory except our target.

##xargs

By reading `man xargs` we see the description as:

> The xargs utility reads space, tab, newline and end-of-file delimited strings from the standard input and executes utility with the strings as arguments.

So it will read our newline delimited string, take each item and pass it as an argument to whichever command-line utility we specify.
    
The `-I` option allows us to specify a string that we can use to specify where in our command string to put each item from standard input. Not all characters immediately work as a placeholder, so let's experiment a little:

    $ ls|grep -v new-folder|xargs -I % echo new-folder/%

Gives us:

    new-folder/f1.html
    new-folder/f1.txt
    new-folder/f2.html
    new-folder/f2.txt
    new-folder/f3.html
    new-folder/f3.txt
    new-folder/folder1
    new-folder/folder2

But if we change `%` to `#`:

    $ ls|grep -v new-folder|xargs -I # echo new-folder/#

We get:

    xargs: option requires an argument -- I
    usage: xargs [-0opt] [-E eofstr] [-I replstr [-R replacements]] [-J replstr]
                 [-L number] [-n number [-x]] [-P maxprocs] [-s size]
                 [utility [argument ...]]

So it's easier to find a couple single character symbols so you can choose whichever is the most clear for the given situation. However, if you really want to use a specific character or even multiple characters you can quote your replacement string/symbol like this:

    $ ls|grep -v new-folder|xargs -I '#' echo new-folder/'#'

Or this: 

    $ ls|grep -v new-folder|xargs -I '{}' echo new-folder/'{}'

Will give you the same result as `%`.

This also points out how to build your command string. Notice that the quotes only go around our replacement character. In fact whatever you specify immediately after `-I` is exactly what you should use in your command string.

##Directories vs. Files

The `ls` command has a few options to let us distinguish between files and directories. For our purposes we will look at the `-p` option to filter out directories and the `-d` option to filter out files.

Here's the output of `ls -p`:

    f1.html		f1.txt		f2.html		f2.txt		f3.html		f3.txt		folder1/	folder2/	new-folder/

Which appends `/` to each directory. This means we can filter it with `grep` like this:

    $ ls -p|grep -v /

And our output will be:

    f1.html
    f1.txt
    f2.html
    f2.txt
    f3.html
    f3.txt

 Which is now ready to be piped to `xargs`. Now we'll use the `-d` option as follows:

    $ ls -d */

Which will output:

    folder1/	folder2/	new-folder/

We just need to filter out `new-folder` using `grep`:

    $ ls -d */|grep -v new-folder

And now we get:

    folder1/
    folder2/

At this point you should have everything you need to execute commands against folders of objects. You can get much more sophisticated with the use of `grep` of course but I'll leave that as an exercise for the reader.