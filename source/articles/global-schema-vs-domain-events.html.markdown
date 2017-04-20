---
layout: post
title: Global Schema vs Domain Events
published: false
---

I think there will be value in providing a global aggregate of the data, especially so that business managers can look at the data and query it easily w/o having to figure out how to cleanse and aggregate the raw data. Especially on a new platform like Spark instead of an RDBMS. However, I have a couple of concerns about modelling the data up front:

1.	**[Data lake](https://en.wikipedia.org/wiki/Data_lake) vs [data warehouse](https://en.wikipedia.org/wiki/Data_warehouse):** The data lake is at least a level below a warehouse where there will be a lot of unstructured and semi-structured data. Data should be [schema on read](https://www.techopedia.com/definition/30153/schema-on-read) and not [schema on write](https://www.techopedia.com/definition/30899/schema-on-write). A global schema can be then aggregated from the raw data into a data warehouse if it’s needed. But the idea of the data lake is to allow a more agile approach to data analytics where instead of trying to model a schema that meets everyone’s needs you can provide simpler, more targeted schemas.

*	**Tightly coupled deployments:** a global data structure is likely to also couple deployments where schema changes need to be coordinated between systems and the data infrastructure. Avro’s schema evolution may provide means to mitigate this, but I think removing it altogether would be better. That said, either way I think there will be a need for services to be able to tell the Kafka schema registry about schema changes – serializing the schema with each message (eg. container files) will be too much overhead.

*	**Loss of context**

  *	**Bounded Context** – “person” and “customer” objects (to use a couple generic modelling examples) have different meaning across different domains like Sales, Marketing, and Support. (see: http://martinfowler.com/bliki/BoundedContext.html, also: https://www.infoq.com/minibooks/domain-driven-design-quickly page 69). Merging the data into a single global entity can run into square peg/round hole problems.

  *	**Merge conflicts** – if two services make a change to the same field, you may need complex rules to merge them. 

  *	**Lossy data** – with a global in order to determine what changed you need to compare deltas. Without the context of the transaction that caused the change you have to guess what the change was. 

  *	**Analytic/calculation errors** – as a result of “lossy data” you either have to guess what the change means or there has to be a high-level of collaboration between the teams to reduce errors where a delta is misinterpreted. Not much of a problem when the delta only involves a single, scalar value with low-cardinality which doesn’t cross transaction boundaries. But when changes involve multiple values, any of which may be high-cardinality and may also cross transaction boundaries it becomes very difficult to prevent mistakes.

I agree with the idea of constraining topics to a single entity, just not a single message type. Not sure if they should be split up further by bounded context though, that will require some thought and discussion.

I think the exhaust from the different systems should be [domain events](http://www.martinfowler.com/eaaDev/DomainEvent.html). While it can take some time to wrap your head around them they provide valuable context, schemas can evolve at a granular level without affecting other systems, and are really useful in integration scenarios because you can filter them for only the data you’re interested in and can be easily aggregated to whatever data model is needed in any data store. They also make it easy to throw out an aggregated schema and rebuild a new one, or maintain multiple schemas independently. The caveat would be that a successful implementation of domain events still requires a careful analysis: they should be viewed as a public API (or at least an internal API public to our systems), with everything that entails.
