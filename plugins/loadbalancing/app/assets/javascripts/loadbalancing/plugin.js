// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// Every Plugin file is surrounded with a closure by dashboard.
// It means that your plugin js code runs in own namespace and can't 
// break any code of other plugins. If you want to make your code available 
// outside this closure you should bind functions to loadbalancing. 
//  
//       
//= require_tree .   
  
// This function is visible only inside this file.
function test() {
  //...
}

// This function is available from everywhere by calling loadbalancing.name()
// Call function from other files inside this plugin using the variable loadbalancing
//loadbalancing.anyFunction()
loadbalancing.name = function() {
  "loadbalancing"
}

// This is always executed on page load.
$(document).ready(function(){
});

// Get loadbalancer states for all rendered lb-ids
function update_states(poll_url) {
  var ids = $('table.loadbalancers tbody').find('tr').toArray().map(elem => elem.id).filter(id => id && id.length>0)
  if (ids.length > 0) {
    var data = {
      state_ids: ids,
    }
    //console.log(ids)
    $.ajax({
      url: poll_url,
      method: "GET",
      data: data,
      dataType: "script"
    })
  }
}

// Initiates first call immediately and interval based call on update_states
loadbalancing.startStatesPolling = function(poll_url, poll_freq) {
  update_states(poll_url);
  setInterval(() => update_states(poll_url), poll_freq);
}
