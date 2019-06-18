#### Cost Object

The **Cost Object**(CO) is the *"Cost Center"*, *"Internal Order"*, *"WBS Element"* or *"Sales Order"* to which the costs for this project will be charged. If in doubt, ask the responsible [Infrastructure Coordinator](https://jam4.sapjam.com/blogs/show/tMu79H0QHEA3vNMGSkanxa) or [Controller](https://portal.wdf.sap.corp/irj/portal?NavigationTarget=navurl://9b3e872d8ee3f3c3cbfa4cd8cbadfd3b) of the cost object for permission.

* **Inherited from domain:** You can use the cost object defined by the domain if the domain administrator allows this.
* The **Type** and **Name/Number** fields specify the cost object. Some types of cost object have IDs instead of names. Enter these in the **Name/Number** field as well.

#### Contact

These Inforamtion is important for Converged Cloud operations to cover full support for this project!

* The **Primary Contact** is the first contact for support questions. It is the contact in case of incidents or questions related to the project. Especially if **Other Responsibility** contacts are not maintained.
* The **Hotline/TicketQueue/Other** field is optional and should be filled if the project is set to *"Business Criticality = Productivity"*

#### Significance

The significance of a project is measured in three ways:

* The **Business Criticality** indicates how critical the system is for your ability to provide your service to your customer. You can choose between *"Development"*, *"Testing"* and *"Productive"*.
* The **Revenue Relevance** indicates if the project is directly or indirectly creating revenue:
  * **Enabling** projects enable other (generating) products to provide their service (for example, services provided to SAP-internal customers).
  * **Generating** projects provide services directly to an external customer (usually productive systems).
  * **Other** covers all other cases.
* The **Number of Endusers** is a rough estimate of the number of users this project provides services to. Always enter the lower end, or -1 to indicate an infinite number of users.

#### Other Responsibilitys

These persons may be contacted by Converged Cloud operations or other parties in case of questions.

* The **Operator** is responsible for the uptime of the systems in this project, and who can decide, for example, when an instance may be restarted. Used as emergency engineering contact by CCloud operations.
* The **Security Expert** is responsible for requesting and validating firewall and other security settings. This person will be contacted by security, for example, if a vulnerability is found.
* The **Product Owner** holds the vision for the product and is responsible for maintaining, prioritizing and updating the backlog.
* The **Controller** is responsible for the given cost object and may decide which costs are billed on this cost object.