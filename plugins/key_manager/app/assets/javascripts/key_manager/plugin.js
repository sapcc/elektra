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
// outside this closure you should bind functions to key_manager. 
//  
//       
//= require_tree .   
  
// This function is visible only inside this file.
function test() {
  //...  
}    

// This function is available from everywhere by calling key_manager.name()
key_manager.name = function() {
  "key_manager"
} 

// This is always executed on page load.
$(document).ready(function(){
  // ...
}); 
    
// Call function from other files inside this plugin using the variable key_manager
//key_manager.anyFunction()    