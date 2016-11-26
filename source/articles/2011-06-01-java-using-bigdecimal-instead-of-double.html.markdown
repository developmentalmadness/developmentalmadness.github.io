---
layout: post
title: 'Java: using BigDecimal instead of double'
date: '2011-06-01 16:02:00'
tags:
- lost_in_translation
- java
- types
- bigdecimal
---

For the last two months I've been using Linux and Java exclusively. For the times I still need to do .NET development, my laptop is setup to dual-boot into Windows 7. But since I'm learning a lot, I really want to try and catalog my experience of transitioning from Windows/.NET developer to Linux/Java developer.

Am I giving up on .NET and Windows? No, but because I've been moved to a Java project deployed on Linux I decided to jump in with both feet. I'm enjoying how much I'm learning and hopefully as I get back in the habit of blogging, I'll include stuff I'm doing with .NET as well.

However, I first started playing with .NET during it's beta stage and have been using it on a daily basis since v1.1. So, at least for the time being, I'm likely to include comparisons with .NET when I post about Java in as much as I see it will benefit .NET developers who are making the same transition I am. Who knows, maybe my perspective will also be interesting to some Java developers as well.

#Primitive Java Types
I've been working on a test harness that publishes rates and at the moment all it does is publish a rate and check to see if the same value comes out the other end. I have a instance of a log4j Logger that I'm using to output debug info to the console as I develop this and I was noticing that when I would add two doubles together the results were imprecise. For example, the following:


    private void doubleOutput(){
            double rate = 1.37000;
            double adjustment = 0.00001;
            try {
                while(System.in.available() == 0){
                    rate += adjustment;
                    log.debug("The new rate is: " + rate);
                    pause(500);
                }
            } catch (IOException e) {
                log.error("IOException: " + e);
            }
        }

would give the these results:

    2011-06-01 10:56:42,011 DEBUG [Main] The new rate is: 1.3700100000000002
    2011-06-01 10:56:42,512 DEBUG [Main] The new rate is: 1.3700200000000002
    2011-06-01 10:56:43,012 DEBUG [Main] The new rate is: 1.3700300000000003
    2011-06-01 10:56:43,513 DEBUG [Main] The new rate is: 1.3700400000000004
    2011-06-01 10:56:44,013 DEBUG [Main] The new rate is: 1.3700500000000004

It's been a while since I've really looked into the issue. In .NET the de facto standard for monetary calculations is the decimal type (System.Decimal). System.Float and System.Double are binary floating types and will result in rounding errors. So in this sense, Java is the same: the double types on both platforms are binary floating types implemented according to the IEEE 754 standard.

So what is the equivalent of System.Decimal in Java?

#BigDecimal

The Java equivalent of System.Decimal is java.math.BigDecimal. Here's the equivalent of the above method, using BigDecimal:

    private   void  roundingTests(){
           BigDecimal rate = new BigDecimal("1.37000");
           BigDecimal adjustment = new BigDecimal("0.00001");
           try {
               while(System.in.available() == 0){
                   rate = rate.add(adjustment);
                   log.debug("The new rate is: " + rate.doubleValue());
                   pause(500);
               }
           }  catch  (IOException e) {
               log.error( "IOException: "  + e);
           }
       }

Which will give you this output:

    2011-06-01 11:19:24,715 DEBUG [Main] The new rate is: 1.37001
    2011-06-01 11:19:25,216 DEBUG [Main] The new rate is: 1.37002
    2011-06-01 11:19:25,716 DEBUG [Main] The new rate is: 1.37003
    2011-06-01 11:19:26,217 DEBUG [Main] The new rate is: 1.37004

This is more what I was expecting. However, BigDecimal has some important differences with System.Decimal. First of all, and what took me the longest to catch on to, is that BigDecimal is immutable. Just like System.String in .NET. So how does this affect you? Look at the first line inside the loop above. What do you notice? Instead of using the standard addition operator, there's an "add" method. Also, I'm assigning the result back to the "rate" variable, just like if I were doing string manipulations.

If you modify the above sample and remove the assignment, and leave just the "add" operation the result you'll see in the console is that the rate is always "1.37000".

The second thing to note is the constructor. Notice how I am passing in a string representation of the values 1.37000 and 0.0001. The reason is (I'm pretty sure about this) because if I were to pass in the values without the quotes I would be passing in double values and my results would be as follows:

    2011-06-01 11:26:20,639 DEBUG [Main] The new rate is: 1.3700100000000002
    2011-06-01 11:26:21,141 DEBUG [Main] The new rate is: 1.37002
    2011-06-01 11:26:21,641 DEBUG [Main] The new rate is: 1.37003
    2011-06-01 11:26:22,142 DEBUG [Main] The new rate is: 1.3700400000000001
    2011-06-01 11:26:22,642 DEBUG [Main] The new rate is: 1.3700500000000002

All of a sudden I'm back to my original problem. So I pass in my string representation to prevent my values from behaving like binary floating types.

#Performance and Accuracy

A note about performance. Something I didn't know about System.Decimal (or at least it never occurred to me) was that it is an 128 bit value, capable of storing up to 29 significant digits. System.Double is 64 bits. java.lang.BigDecimal however is represented internally as an array of integers (java.lang.BigInteger) which has no size limit. So the size of it depends upon how large the number is. My assumption is that this also applies to accuracy such that there is no limit on the number of significant digits. I had been wondering why there was just BigDecimal and no Decimal class, my guess is that because it uses BigInteger internally and it really can be BIG, it makes sense to call it BigDecimal and with that, there's really no need for just Decimal since not only can it be really big, but it will also contract (I'm not saying it actually trims the internal array, just that smaller values will result in less memory consumption) for smaller values.

Either way there are implications on performance due to the implementations. If performance is really a concern then there are alternatives, but for most applications BigDecimal (and System.Decimal) should be just fine.

**Update 6/2/11:** Looking around some more today I noticed that if you don't want to use BigDecimal if you're just passing values around, but want to use it just when you're doing calculations you can use the static method `BigDecimal.valueOf(double);` According to javadocs this is the equivelent of `new BigDecimal(Double.toString(double));` Either way, as far as I can tell you can do this without running into rounding errors. If you're still worried about possible rounding errors you can use the BigDecimal instance method setScale which allows you to set the scale you want and optionally the RoundingMode. So when doing calculations your API can use "double" while you can use BigDecimal internally. In .NET you could do the same using the explicit `IConvertable.ToDecimal(IFormatProvider)` on an instace of `System.Double` (ex: `((IConvertable)rate).ToDecimal(null);` ) and the static `Decimal.ToDouble(Decimal)` to convert back and forth between Double and Decimal.

References
For more information on System.Decimal see: http://csharpindepth.com/Articles/General/Decimal.aspx, http://msdn.microsoft.com/en-us/library/system.decimal.aspx

For more information on java.math.BigDecimal see: http://firstclassthoughts.co.uk/java/traps/big_decimal_traps.html, http://download.oracle.com/javase/1.4.2/docs/api/java/math/BigInteger.html

