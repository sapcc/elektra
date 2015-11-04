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


Plugins - or How do I work with the Dashboard?
-------

![Dashboard-Plugins](docs/Dashboard-Plugins.jpg?raw=true)

A dashboard plugin encapsulates functionality which belongs together conceptually and/or technically and which is integrated into the dashboard for consumption by the end user. The concept of plugins aims to outsource parts of the dashboard, thus enabling developers to work decoupled. Rather than putting everything in the "app" directory of the main app, the controllers, views and models are distributed in plugins. For example, the network plugin contains all the necessary controllers and views as well as helper classes to create, edit and delete network objects.

The main app provides layout, user and token handling, manages the plugins and offers classes that can be extended by plugins to make use of the functionality they provide. For example, checking whether the user is registered or logged in and the logic for the rescoping is implemented in the DashboardController. The plugin controllers can inherit from this class and won't have to worry about the user management themselves.

Furthermore, the main app provides a service layer through which the plugins are able to access service methods of other plugins on the controller level.

  
###Service Layer

In principle a dashboard plugin is able to store data in the database and access it via the ActiveRecord layer. However, many plugins communicate via an API with services which persist the necessary data. The Service Layer is used by the plugins to communicate with these backend services. Services in this case are primarily OpenStack services like compute or identity. Though other custom services can also be accessed the same way by the plugin.

**Important:** The communication with such services requires a valid user token (OpenStack Keystone).

As described above, the ``DashboardController`` in the main app takes care of user authentication. Each plugin controller that inherits from this controller automatically includes a reference to ``current_user`` which represents the token. The plugin can now use the information in ``current_user`` (mainly the token) to interact with the services.

But how can a plugin for example the compute plugin access the network methods which are implemented in the network plugin? This is where the service layer comes into play. The ``DashboardController`` offers another method called "services" which contains the reference to all available plugin services. For example: ```ruby services.network.networks``` invokes the method networks from the network service. Thus, the Service Layer represents a communication channel to the main backend service a plugin consumes and also to the other plugin services.



###Domain Model 

To avoid that services communicate directly with the API and that each plugin implements its own client, we introduced a driver layer. This layer is located exactly between the service and the API client. Thereby it is possible to abstract the services from the specific client implementation. The driver implements methods that are invoked directly by services and send or receive data to or from the API. The data format between service and driver is limited to the Ruby Hash. Hashes are in principle sufficient for further processing, but in the UI data is usually collected via HTML forms and must be validated before it is sent on to the API. Furthermore you often require helper methods that are not implemented in the hashes.

The mentioned drawbacks of pure hash use are eliminated by the concept of the Domain Model. The Domain Model wraps the data hash and implements methods that work on this hash. Services call driver methods and map the responses to Domain Model objects and, conversely, the Domain Model objects are converted to hashes when they reach the driver layer. As a result, it is possible to work with real ruby objects rather than using hashes. In such Domain Model objects we can use validations and define helper methods.

The plugin folder structure needs to look as follows:
![Plugins](docs/dashboard_plugins_tree.jpg?raw=true)

[Details](docs/dashboard_services.pdf)


###Create Plugin

The complexity of a plugin may vary greatly depending on the tasks. For example the Lib Plugin includes no app tree and is not mountable. However, it contains a lib folder and therefore implements libraries which may be used in other plugins. On the other hand, a mountable plugin includes a full app tree and own routes and is able to be mounted and act as an isolated rails app.

* Lib Plugin
  * includes a "lib" directory and no app tree
* ServiceLayer Plugin
  * includes an implementation of ServiceLayer and DomainModel
  * app tree partially available
  * is a Rails Engine
* Mountable Plugin
  * includes a full app tree
  * can be mounted and define own routes
  * is a Rails Engine 

For ease-of-use we have provided a generator which generates a skeleton plugin folder structure with the necessary elements and some basic classes to get started. To use it first decide which type of plugin you want to start developing:

####Create Lib Plugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME```

####Create ServiceLayer Plugin
1. cd monsoon-dashboard
2. ```bin/rails g dashboard_plugin NAME --service_layer```

####Create Mountable Plugin
1. cd monsoon-dashboard
2. ```bin/rails g dashboard_plugin NAME --mountable```

####Create Mountable-ServiceLayer Plugin
1. cd monsoon-dashboard
2. ```bin/rails g dashboard_plugin NAME --mountable --service_layer```
