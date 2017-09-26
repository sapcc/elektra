#### Cost Object

The *cost object* is the cost center, internal order, WBS element or sales order to which the costs for this project will be charged. If in doubt, ask the responsible controller of the cost object for permission.

* **Inherited from domain:** You can use the cost object defined by the domain if the domain administrator allows this.
* Choose a **Solution** if the project is used for one of the strategic solutions of SAP.
* The **revenue relevance** indicates if the project is directly or indirectly creating revenue:
  * **Enabling** projects enable other (generating) products to provide their service (for example, services provided to SAP-internal customers).
  * **Generating** projects provide services directly to an external customer (usually productive systems).
* The **type** and **name** fields specify the cost object. Some types of cost object have IDs instead of names. Enter these in the **name** field as well.

#### Responsibility

These persons may be contacted by Converged Cloud operations or other parties in case of questions.

* The **operator** is responsible for the uptime of the systems in this project, and who can decide, for example, when an instance may be restarted. Used as emergency engineering contact by CCloud operations.
* The **security expert** is responsible for requesting and validating firewall and other security settings. This person will be contacted by security, for example, if a vulnerability is found.
* The **product owner** holds the vision for the product and is responsible for maintaining, prioritizing and updating the backlog.
* The **controller** is responsible for the given cost object and may decide which costs are billed on this cost object.

#### Importance

The importance of a project is measured in two ways:

* The **business criticality** indicates how critical the system is for your ability to provide your service to your customer. You can choose between *Development*, *Testing* and *Productive*.
* The **number of endusers** is a rough estimate of the number of users this project provides services to. Always enter the lower end, or -1 to indicate an infinite number of users.
