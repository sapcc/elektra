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
// outside this closure you should bind functions to monitoring. 
//  
//       
//= require_tree .  
  
// This function is visible only inside this file.
function test() {
  //...  
}    

// This function is available from everywhere by calling monitoring.name()
monitoring.name = function() {
  "monitoring"
};

// This is always executed on page load.
$(document).ready(function(){
  // show small loading spinner on active tab during ajax calls 
  $(document).ajaxStart( function() {
    $('.loading_place').addClass('loading');
  });
  $(document).ajaxStop( function() {
    $('.loading_place').removeClass('loading');
  });
}); 


monitoring.render_overview_pie = function(TYPE,DATA,SIZE) {

  var width = SIZE || 400;
  var height = SIZE || 400;

  nv.addGraph( function() {
      var chart = nv.models.pieChart()
          .x(function(d) { return d.label })
          .y(function(d) { return d.count })
          .width(width)
          .height(height)
          .noData("There is no Data to display")
          .title(TYPE)
          .donut(true)
          .donutRatio(0.4)
          .showTooltipPercent(true);

      d3.select("#"+TYPE)
          .datum(DATA)
          .transition().duration(1200)
          .attr('width', width)
          .attr('height', height)
          .call(chart);
          
      return chart;
  } );

}
