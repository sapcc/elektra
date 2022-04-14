
// This function is visible only inside this file.
function test() {
  //...  
}    

// This function is available from everywhere by calling masterdata_cockpit.name()
masterdata_cockpit.name = function() {
  "masterdata_cockpit"
} 

// This is always executed on page load.
$(document).ready(function(){
  // ...
}); 
    
// Call function from other files inside this plugin using the variable masterdata_cockpit
//masterdata_cockpit.anyFunction()    

// This is always executed on page load.
$(document).ready(function(){
  // show small loading spinner on active tab during ajax calls 
  $(document).ajaxStart( function() {
    $('.loading-place').addClass('loading');
  });
  $(document).ajaxStop( function() {
    $('.loading-place').removeClass('loading');
  });
});