#### Cost Object
Costcenter, internal order, WBS or sales order where the costs should be charged to. If unclear, please ask the responsible controller of the given costobject for permission

* **Inherited from domain:** Is only vissible if the Cost Object is inherited from domain. 
* **Solution:** Choose a solution, if the project is used for one of the strategic Solutions of SAP.
* **Revenue Relevance:** Indicating if the project is directly or indirectly creating revenue. You can choose between two types
 * ***enabling:*** Project that is used to enable other (generating) products to provide their service (p.e. Service provided to internal customers, like converged cloud or development system)  
 * ***generating:*** Project that is used to provide dircetly a service for an external customer (usually productive systems)
* **Type:** Type of the cost object, you can choose the following types
 * ***Cost Center:***
 * ***Internal Order:***
 * ***Sales Order:***
 * ***WBS Element:***
* **Name:** Name of the costobject (can be a ID or Name)

#### Responsibility
Who is who to contact in case of fire

* **Operator:** The person responsible for uptime of the systems and who can make decisions on e.g. Instance restarts etc. Used as emergency engineering contact, if CCloud operations needs a name.
* **Security Expert:** The person responsible to request and validate firewall and other security settings. The person who will be contacted by security e.g. If a vulnerability is found by a scan etc.
* **Product Owner:** The person owning the applications features.
* **Controller:** The person responsible for the given Costobject and empowered to decide, which costs are billed on this costobject.

#### Importance
Indicates how important is the project

* **Business Criticality:** Indicates, how critical the system is for your ability to provide your service to your customer. You can choose between tree types
 * ***Development***
 * ***Testing***
 * ***Productive***
* **Number of Endusers:** Roughly estimated number of users the service you provide. Always provide the lower end (-1 indicates that it is infinite).