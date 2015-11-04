monsoon-dashboard
=================

New service based Converged Cloud dashboard.

Prerequisites
-------------
1. running Authority
2. installed postgres database

Install
-------
this is work in progress so no guarantee of completeness ;-)

1. bundle install
2. copy env.sample to .env and adjust the values
3. rake db:create
4. rake db:seed
5. foreman start
6. now try to access http://localhost:8180

Plugins
-------

![Dashboard-Plugins](docs/Dashboard-Plugins.jpg?raw=true)

Dashboard plugins encapsulate functionality which belong together, but are a part of the dashboard. The concept of plugins aims to outsource parts of the dashboard, thus enabling developer to work decoupled. Rather than to put everything in the "app" directory of the main app the controllers, views and models are distributed in plugins. For example, the network plugin contains all the necessary controllers and views as well as helper classes to create, edit and delete network objects.

The main app provides layout, manages the plugins and offers classes that are extended by plugins. For example, the functionality like checking whether the user is registered or logged in and the logic for the rescoping is implemented in DashboardController. The plugin controllers should just inherit from this class and not worry about the user management.

Furthermore, the main app provides a service layer, through which the plugins are able to access service methods of other plugins on the controller level.

  
###Service Layer

Although a dashboard plugin is able to store data in the database and access it via the ActiveRecord layer. However, many plugins communicate via an API with services which persist the necessary data. With services are primarily meant OpenStack-Services like compute or identity. However, other, custom services can be accessed on the same way by the plugin. It is important that the communication with such services requires a valid user token (OpenStack Keystone).

As described above, the DashboardController in the main app takes care of the user authentication. Each plugin controller that inherits from this controller automatically includes a reference to the current_user which represents the token. The plugin can now use the information in current_user (mainly the token) to interact with the services.

But how can a plugin for example the Compute-Plugin access the network methods which are implemented in the Network-Plugin? This is where the Service Layer comes into play. The DashboardController offers another method called "services" which contains the reference to all available Plugin-Services. ```ruby services.network.networks``` invokes the method networks from the network service. Thus, Service Layer represents a communication channel between the plugin services, which requires a valid user token.


###Domain Model 

To avoid that services communicate directly with the API and that each plugin implements its own client, we introduced a driver layer. This layer is located exactly between the service and the API client. Thereby, it is possible to abstract the services from the specific client implementation. The driver implements methods that are invoked directly by services and send or receive data to or from the API. The data format between service and driver is limited to the Ruby Hash. Hashes are in principle sufficient for further processing, but in the UI data is accumulated by many forms and must be validated before it is sent to the API. Furthermore, often you require helper methods that are not implemented in the hashes.

The mentioned drawbacks of pure hash use are eliminated by the concept of Domain Model. Domain Model wraps the data hash and implements methods that work on this hash. Services call driver methods and map the responses to Domain Model objects and, conversely, the Domain Model objects are converted to hashes when they reach the driver layer. As a result, it is possible to work with real ruby objects rather than using hashes. In such domain model objects we can use validations and define helper methods.

![Plugins](docs/dashboard_plugins_tree.jpg?raw=true)

[Details](docs/dashboard_services.pdf)


###Create Plugin

The complexity of a plugin may vary greatly depending on the tasks. For example the Lib-Plugin includes no app tree and is not mountable. However, it contains a lib folder and therefore implements libraries which may be used in other plugins. On the other hand, a mountable plugin includes a full app tree and own routes and is able to be mounted and act as an isolated rails app. 

* Lib-Plugin
  * includes a "lib" directory and no app tree
* ServiceLayer-Plugin
  * includes an implementation of ServiceLAyer and DomainModel
  * app tree partially available
  * is a Rails Engine
* Mountable-Plugin
  * includes a full app tree
  * can be mounted and define own routes
  * is a Rails Engine 
 
####Create Lib-Pplugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME```

####Create ServiceLayer-Pplugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME --service_layer```

####Create Mountable-Pplugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME --mountable```

####Create Mountable-ServiceLayer-Pplugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME --mountable --service_layer```
