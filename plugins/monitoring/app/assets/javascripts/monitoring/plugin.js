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


monitoring.get_metric_names = function() {
  
	var metric_names_unfiltered = []
  $.each(metrics_data, function( index, metric ) {
    metric_names_unfiltered.push(metric[0]);
  });
  //console.log(metric_names_unfiltered);
  
  var metric_names_unique = metric_names_unfiltered.filter(function(metric_name, i, ar){ 
    return ar.indexOf(metric_name) === i; 
  });
  //console.log(metric_names_unique);
  
  return metric_names_unique;
};

monitoring.generate_expression = function() {
  
  var expression = "";
  var metric = $('#metric').val();
  var statistical_function = 'avg';
  var dimensions = "";

  var dimensions = "";
  $('.dimension_key').each(function( ) {
    if($( this ).text() != '' ) {
      var defintion_id = $(this).data('defintion')
      dimensions += $( this ).text()+":"+$('#dimension_value_'+defintion_id).text()+",";
    }
  });

  var period = "";
  var relational_operator = "";
  var threshold_value = "";
  
  expression = statistical_function+"("+metric+"{"+dimensions+"},"+period+")"+relational_operator+" "+threshold_value;
  $('#expression').html(expression);
  
} 

monitoring.render_dimensions = function() {
  $('#expression').html(monitoring.generate_expression());
  
}


monitoring.render_overview_pie = function(TYPE,DATA,SIZE) {

  var width = SIZE || 450;
  var height = SIZE || 450;

  nv.addGraph( function() {
      var chart = nv.models.pieChart()
          .x(function(d) { return d.label })
          .y(function(d) { return d.count })
          .width(width)
          .height(height)
          .showLegend(false)
          .labelThreshold(0.05)
          .noData("There is no Data to display")
          .title(TYPE)
          .donut(true)
          .donutRatio(0.4)
          .showTooltipPercent(true);

      chart.color(function (d, i) {
        // color scheme is used from _variables.scss
         switch(d.label) {
           case "Low":
              //console.log("Low");
              //$medium-blue
              return ["#226ca9"];
           case "Medium":
              //console.log("Medium");
              //$bright-orange
              return ["#de8a2e"];
           case "High":
              //console.log("High");
              //$deep-orange
              return ["#b34a2a"];
           case "Critical":
              //console.log("Critical");
              //$alarm-red
              return ["#e22"];
           case "Ok":
              //console.log("OK");
              //$medium-green
              return ["#8ab54e"];
           case "Alarm":
              //console.log("Alarm");
              //$alarm-red
              return ["#e22"];
           case "Unknown":
              //console.log("Undetermined");
              return ["#aaa"];
         }
      });

      d3.select("#"+TYPE)
          .datum(DATA)
          .transition().duration(1200)
          .attr('width', width)
          .attr('height', height)
          .call(chart);

      return chart;
  } );

};