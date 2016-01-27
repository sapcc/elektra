Elektra
=================

A new service based Converged Cloud dashboard.


Prerequisites
-------------
1. Openstack Dev setup
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


Create a new Plugin
-------------------

For more information about plugins, see the chapter "What are Plugins?" below.

The complexity of a plugin may vary greatly depending on its purpose. For example a Lib Plugin includes no app tree and is not mountable. However, it contains a lib folder and therefore implements libraries which may be used in other plugins. The next complexity level is the ServiceLayer Plugin, which already contains a partial app tree but isn't mountable and doesn't define views, it offers a service or library which may be used in other plugins (the ``DomainModelServiceLayer`` is an example of such a plugin). The last plugin type is the mountable plugin which includes a full app tree and its own routes and views and is able to be mounted and act as an isolated rails app (The network plugin is an example of a mountable plugin).

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

For ease-of-use we have provided a generator which generates a skeleton plugin folder structure with the necessary elements and some basic classes with the proper inheritance to get started. First decide which type of plugin you want to start developing (for more infos about plugins see "What are Plugins?" below):

#### Create Lib Plugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME```

#### Create ServiceLayer Plugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME --service_layer```

#### Create Mountable Plugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME --mountable```

#### Create Mountable ServiceLayer-Plugin
1. ```cd monsoon-dashboard```
2. ```bin/rails g dashboard_plugin NAME --mountable --service_layer```

### Creating Migrations

If your plugin needs to save things in the dashboard database, you'll need to create a migration. Migrations and the Models they belong to live within the plugin. One additional step is necessary to register your migration with the host app so that it is applied when ``rake db:migrate`` is called in the host app. To create a new migration in your plugin do the following:

**Background:** you have a plugin named ``my_plugin``.

1. ``cd monsoon-dashboard/plugins/my_plugin``

Inside this (mountable) plugin you will find a bin folder and rails script within this folder.

2. bin/rails g migration entries

A new migration was generated under monsoon-dashboard/plugins/my_plugin/db/migrations/

3. Register this engine's migration for the global rake task

initializer 'my_plugin.append_migrations' do |app|
  unless app.root.to_s == root.to_s
    config.paths["db/migrate"].expanded.each do |path|
      app.config.paths["db/migrate"].push(path)
    end
  end
End

4. cd monsoon-dashboard
5. Rake db:migrate



Plugin Assets
--------------

The dashboard UI design is a theme for [Twitter Bootstrap (v3.~)](http://getbootstrap.com/). All components described in the Twitter Bootstrap documentation also work in the dashboard. In addition we have included [Font Awesome](https://fortawesome.github.io/Font-Awesome/) for icons.

**Important** When building views for your plugin please check existing plugins for established best practices and patterns and also check with the core team (mainly Esther) so that the user experience stays the same or similar across plugins.

In many cases the provided styles will be enough to build your views. If you need extra styles or scripts please coordinate with Esther to see whether we should include them in the core styles so they become accessible for everybody or whether they should remain specific to your plugin. Assets that are specific to your plugin must be located in the assets folder in your plugin.



What are Plugins?
-----------------

![Dashboard-Plugins](docs/Dashboard-Plugins.jpg?raw=true)

The concept of plugins aims to outsource parts of the dashboard, thus enabling developers to work decoupled from the main app and from each other. Rather than putting everything in the "app" directory of the main app, the controllers, views and models are split into plugins. A dashboard plugin encapsulates functionality which belongs together conceptually and/or technically and which is to be integrated into the dashboard for consumption by the end user. The network plugin for example contains all the necessary controllers and views as well as helper classes to create, edit and delete network objects.

The core app provides layout, user and token handling, manages the plugins and offers classes that can be extended by plugins to make use of the functionality they provide. For example, checking whether the user is registered or logged in and the logic for the rescoping is implemented in the ``DashboardController`` in the core app. Plugin controllers can inherit from this class and won't have to worry about the user management themselves.

Furthermore, the core app provides a service layer through which plugins are able to access other plugins' service methods on the controller level.


### Service Layer

In principle a dashboard plugin is able to store data in the dashboard database and to access it via the ActiveRecord layer. However, many plugins communicate via an API with services which persist the necessary data themselves. Dashboard plugins use the _Service Layer_ to communicate with these backend services. Services in this case are primarily OpenStack services like compute or identity. Though other custom services can also be accessed the same way by the plugin.

**Important:** The communication with such services requires a valid user token (OpenStack Keystone).

As described above, the ``DashboardController`` in the core app takes care of user authentication. Each plugin controller that inherits from this controller automatically includes a reference to ``current_user`` which represents the token. The plugin can now use the information in ``current_user`` (mainly the token) to interact with the backend services.

But how can a plugin, for example the compute plugin, access the network methods which are implemented in the network plugin? This is where the service layer comes into play. The ``DashboardController`` offers a method called ``services`` which contains the reference to all available plugin backend services. For example: ```services.networking.networks``` invokes the method networks from the network backend service. Thus, the _Service Layer_ represents a communication channel to the main backend service a plugin consumes and also to the other plugin backend services.

**Before you consume other backend services:** Check how expensive a backend call is. If it is expensive take steps to reduce how often the call is made (e.g. by caching, displaying the information on a view that isn't accessed very often) or at least make the call asynchronously so as to not block the rest of the page from loading.

### Driver Layer and Domain Model

To avoid services having to communicate directly with the API and each plugin having to implement its own client, we introduced a driver layer. This layer is located exactly between the service and the API client. Thereby it is possible to abstract the services from the specific client implementation. The driver implements methods that send or receive data to or from the API and are invoked directly by a service. The data format between service and driver is limited to the Ruby Hash. Hashes are in principle sufficient for further processing, but in the UI data is usually collected via HTML forms and must be validated before it is sent on to the API. Furthermore you often require helper methods that are not implemented in the hashes.

The mentioned drawbacks of pure hash use are eliminated by the concept of the Domain Model. The Domain Model wraps the data hash and implements methods that work on this hash. By inheriting from the core Domain Model (``DomainModelServiceLayer::Model``) your model gets CRUD operations out of the box. You can then add additional methods for formatting, processing, etc.

Services call driver methods and map the responses to Domain Model objects and, conversely, the Domain Model objects are converted to hashes when they reach the driver layer. As a result, it is possible to work with real ruby objects in plugins rather than using hashes. In such Domain Model objects we can use validations and define helper methods.

### Plugin Folder Structure

The following diagram illustrates how plugins are structured and which core classes to inherit to make it all work as described above.
![Plugins](docs/dashboard_plugins_tree.jpg?raw=true)

[Click this link for a detailed class diagram](docs/dashboard_services.pdf)
