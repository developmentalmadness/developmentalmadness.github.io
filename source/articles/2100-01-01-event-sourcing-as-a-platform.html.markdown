---
layout: post
title: Event Sourcing As A Service
published: false
---

Stupid title, yes. But I just coined my own XaaX acronym: ESaaS!

#In-Place Updates

Traditionally data is stored and queries from the same location. Data is modeled where rows represent entities and value objects, and columns or properties model attributes. This is universally accepted across data platforms: RDBMS and NoSQL solutions alike. An example of this defined as an Avro schema might look like this:

File Schema

* Name
* Path
* Size
* MimeType
* Status [Available, Archived, Deleted]
* LastModifiedDate
* LastModifiedBy
* Encrypted
* Compressed

http://martinfowler.com/bliki/BoundedContext.html

#Event Stream

#Benefits

##Data Lake

