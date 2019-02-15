//= require action_cable
//= require_self
//= require_tree ./cable/subscriptions

(function() {
  console.log("Cable init")
  this.App || (this.App = {});

  // do not create the consumer if user domain is unknown 
  if(!window.scopedDomainFid) return null;
  // create consumer
  App.cable = ActionCable.createConsumer('/'+window.scopedDomainFid+'/cable');

}).call(this);
