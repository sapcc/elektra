## react/redux*.js
this files are stil in use for our react components that are written in coffeescripts and need to be wiped out ;-) there are included in 
`app/assets/javascripts/application.js.erb` and backed in with the rails asset pipeline.

In other words at the moment react plugins like `Kubernetes` that are written in coffeescript using a different react/redux version. 
So in the end we have two different react/redux version at the same time. The one from `vendor/` that is packaged via rails asset pipeline (coffeescript) and 
the version that comes via webpacker and is used in our react plugins written in Javascript.

### Migration
1. to remove coffeescript we need to rewrite kupernikus
2. rework elektra that only webpacker handles javascripts packages and dependencies
3. wipeout `vendor/`