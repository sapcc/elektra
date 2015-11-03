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

![Dashboard-Plugins](docs/Dashboard-Plugins.jpeg).

###Generate Plugin
cd monsoon-dashboard

```
bin/rails g dashboard_plugin NAME --mountable --service_layer
```

####Generate Lib-Plugin
```
bin/rails g dashboard_plugin NAME
```

* no app tree
* no service layer
* no engine
* lib folder

####Generate Service-Plugin
```
bin/rails g dashboard_plugin NAME --service_layer
```

* full app tree 
* service layer (app/services/domain_model/service.rb)
* engine
* lib fodler (includes driver)


####Generate Mountable-Plugin
```
bin/rails g dashboard_plugin NAME --mountable
```

* full app tree
* routes (mountable)
* engine
* lib folder
