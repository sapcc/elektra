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
    $('.loading-place').addClass('loading');
  });
  $(document).ajaxStop( function() {
    $('.loading-place').removeClass('loading');
  });
}); 

// https://remysharp.com/2010/07/21/throttling-function-calls
// http://stackoverflow.com/questions/4364729/jquery-run-code-2-seconds-after-last-keypress
monitoring.throttle = function(f, delay){
  var timer = null;
  return function(){
      var context = this, args = arguments;
      clearTimeout(timer);
      timer = window.setTimeout(function(){
          f.apply(context, args);
      },
      delay || 500);
  };
}

monitoring.render_statistic = function(ID,DATA) {
    // cleanup left overs
    // http://stackoverflow.com/questions/22452112/nvd3-clear-svg-before-loading-new-chart
    // http://stackoverflow.com/questions/28560835/issue-with-useinteractiveguideline-in-nvd3-js
    // https://github.com/Caged/d3-tip/issues/133
    d3.selectAll("svg > *").remove();
    d3.select("#"+ID)
      .on("mousemove", null)
      .on("mouseout", null)
      .on("dblclick", null)
      .on("click", null);
    d3.select(".nvtooltip").remove();
    
    $('#'+ID).empty();
    
    // check that we have a valid data object
    if(typeof(DATA) != "object") {
      return;
    }

    nv.addGraph(function() {
      var chart = nv.models.lineChart();
      
      chart.margin({"left":30,"right":30,"top":5,"bottom":30});
      chart.useInteractiveGuideline(true);
      chart.xAxis.tickFormat(function(d) { return d + ' min' });

      d3.select('#'+ID)
        .datum(DATA)
        .transition().duration(500)
        .call(chart)
        ;
    
      nv.utils.windowResize(chart.update);
      return chart;
    });
  }

