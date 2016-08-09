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

/*
monitoring.render_overview_pie = function(dataset) {

      var width = 300;
      var height = 300;
      var radius = Math.min(width, height) / 2;

      // Alternative
      var color = ['#A60F2B', '#648C85', '#B3F2C9', '#528C18', '#C3F25C'];
      
      // define arc
      var arc = d3.arc()
        .innerRadius(0)
        .outerRadius(radius);

      // define pi
      var pie = d3.pie()
        .value(function(d) { return d.count; })
        .sort(null);
      

      // create svg
      var svg = d3.select('#chart')
        .append('svg')
        .attr('width', width)
        .attr('height', height)
        .append('g')
        .attr('transform', 'translate(' + (width / 2) +  ',' + (height / 2) + ')');

      // render the pie chart
      svg.selectAll('path')
        .data(pie(dataset))
        .enter()
        .append('path')
        .attr('d', arc)
        .attr('fill', function(d, i) {
          return color[i];
        });
}
*/

// Call function from other files inside this plugin using the variable monitoring
//monitoring.anyFunction()    
