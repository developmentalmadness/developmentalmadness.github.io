---
layout: post
title: Data API Unification Myths
published: false
---

Trying to write a unified data API for dynamodb ("ORM" for lack of a better word) will be a leaky abstraction, especially when more than one language/platform (scala,javascript, and possibily go, and c). The impetus for doing so is to avoid coupling to the AWS platform, or at least to DynamoDB. I believe that there is no way to reliably do this, even for a single language. 

#Portability

In order for any ORM to effectively enable portability between providers it must adhere to the lowest-common-denominator. This is already difficult to do in the RMDBS world where there are well-known and accepted standards. In actuality it is still rarely effective unless all targets are known in advance and clients are equally tested across all providers. 

To provide this capability in the NoSql world would not necessarily be impossible but impractical to say the least.

#Abstraction

Even well designed ORM libraries leak provider implementation details. There is always that one feature needed by a project that is specific to a single provider. It may be needed to reduce costs or improve performance or to implement a feature. Regardless of the reason the moment you do your solution is no longer portable.

#Code Reuse

D-R-Y principles are certainly valuable, but they can also create a false sense of productivity. This requires gatekeepers and versioning. Not initially a problem, but the more services that depend upon the maintenance of a resource the more the costs of backwards-compatibility increase. 

#Solutions
##Monolith

One way to solve the problem would be to create a "Repository" service which doesn't leak the provider details. However, unless there is a single team responsible for it then it doesn't provide the benefit of a single access pattern. Worse, moving the "Repository" to the server will start to make the whole system like a big COM+ architecture.

##Bounded Contexts and Event Sourcing

I think the best way to meet goals of portability and consistent abstractions is to limit them instead of try and completely hide them. 

###Bounded Contexts
Bounded Contexts limit access to your core domain data because it means only your service is accessing it so the data access requirements are limited to support only the use cases within the Bounded Context. With fewer data access requirements portability becomes cheaper and it becomes a Just-In-Time issue instead of a Just-In-Case.

###Event Sourcing
If other consumers have additional needs they have the ability to subscribe to the Event Stream and build their own de-normalized models optimized for their use case. This completely de-couples the data access use cases of the consumer from your Bounded Context. The queries built from the Event Steam can be stored in a data store that is optimized to the specific query (ad hoc, graph, inverted index). To further simplify data access requirements you can subscribe to your own Event Stream to create your own de-normalized models as well.


