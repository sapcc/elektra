//= require action_cable

(function() {
  console.log("Cable init")
  this.App || (this.App = {});

  // do not create the consumer if user domain is unknown 
  if(!window.scopedDomainFid) return null;
  var path = '/'+window.scopedDomainFid
  if(window.scopedProjectId) path = path + '/'+window.scopedProjectId
  // create consumer
  App.cable = ActionCable.createConsumer(path+'/cable');

}).call(this);
