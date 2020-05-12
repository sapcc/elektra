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
// outside this closure you should bind functions to lbaas.
//  
//       
//= require_tree .   
  
// This function is visible only inside this file.
function test() {
  //...
}

// This function is available from everywhere by calling lbaas.name()
// Call function from other files inside this plugin using the variable lbaas
//lbaas.anyFunction()
lbaas.name = function() {
  "lbaas"
}

// This is always executed on page load.
$(document).ready(function(){
});

// Get loadbalancer states for all rendered lb-ids
lbaas.update_states = function(poll_url) {
  var ids = $('table.loadbalancers tbody').find('tr').toArray().map(function(elem) {return elem.id}).filter(function(id) {return id  && id.length>0})
  if (ids.length > 0) {
    var data = {
      state_ids: ids,
    }
    //console.log(data)
    $.ajax({
      url: poll_url,
      method: "POST",
      data: data,
      dataType: "script"
    })
  }
}

// Get loadbalancer states for one lb-id
lbaas.update_state = function(poll_url, lb_id) {
  if (lb_id != null) {
    var data = {
      id: lb_id,
    }
    console.log(data)
    $.ajax({
      url: poll_url,
      method: "GET",
      data: data,
      dataType: "script"
    })
  }
}

// Initiates first call immediately and interval based call on update_states
lbaas.startStatesPolling = function(poll_url, poll_freq) {
  lbaas.update_states(poll_url);
  setInterval(function(){lbaas.update_states(poll_url)}, poll_freq);
}
