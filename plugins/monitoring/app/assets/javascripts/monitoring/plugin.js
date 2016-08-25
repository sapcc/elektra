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

monitoring.expression_dimensions = function() {
  // dimensions
  var dimensions = "";
  $('.dimension_key').each(function( ) {
    if($( this ).text() != '' ) {
      var defintion_id = $(this).data('id')
      var key = $( this ).val();
      var value = $('#dimension_value_'+defintion_id).val();
      if(key != '' && value != '') {
        dimensions += key+":"+value+",";
      }    }
  });
  
  // remove the last comma
  dimensions = dimensions.slice(0, -1);
  
  return dimensions;
}

monitoring.generate_expression = function() {
  
  var valid = true;
  $('.create-expression-error').css('display','none');
  
  // metrics
  var metric = $('#metric').val();
  if(metric == "")valid = false;
  
  // dimensions
  var dimensions = monitoring.expression_dimensions();
  
  if (dimensions != "") {
    dimensions = "{"+dimensions+"}";
  }

  // statistical function
  var statistical_function = $('#statistical_function').val();
  
  // period
  var period = $('#period_custom').val();
  if(period == "") valid = false;
  // validation
  period = Math.floor(period);
  var numberReg =  /^[0-9]+$/;
  if (!numberReg.test(period/60)) {
    $('.period.help-block').hide();
    $('.period').addClass('has-error');
    $('.period').append("<span class='help-block' id='period_error'>Period is not a multiple of 60 or an integer</span>");
    period = '-'
    valid = false;
  }
  else {
    $('#period_error').remove();
    $('.period').removeClass('has-error');
    $('.period.help-block').show();
  }
  
  // relational operator
  var relational_operator = $('#threshold_relational_operator').val();
  if(relational_operator == "") valid = false;
  var threshold_value = $('#threshold_value').val();
  if(!$.isNumeric(threshold_value)) {
    $('.threshold.help-block').hide();
    $('.threshold').addClass('has-error');
    $('.threshold').append("<span class='help-block' id='threshold_error'>Threshold must be a number</span>");
    threshold_value = '-';
    valid = false;
  }
  else {
    $('#threshold_error').remove();
    $('.threshold').removeClass('has-error');
    $('.threshold.help-block').show();
  }

//  chain expressions keep it vor later
//  var chain_operator = $('#chain_operator').val();
//  if(chain_operator != '' && valid) {
//    $('#chain_expression_btn').removeClass('hide');
//    $('#create_alarm_definition_btn').addClass('hide');
//  }
//  else {
//    $('#chain_expression_btn').addClass('hide');
//    $('#create_alarm_definition_btn').removeClass('hide');
//  }

  // colorize expression
  $('#preview').removeClass();
  if(valid) {
    $('#preview').addClass('expression-preview text-success pull-left');
    $('#create_alarm_definition_btn').removeClass('hide');
  }
  else {
    $('#create_alarm_definition_btn').addClass('hide');
    $('#preview').addClass('expression-preview text-danger pull-left');
  }

  // render current expression
  var expression = statistical_function+" ("+metric+dimensions+", "+period+") "+relational_operator+" "+threshold_value//+" "+chain_operator;
  $('#preview').text(expression);

//  chain expressions keep it vor later
//  // collect all chained expressions
    var sub_expression = "";
//  $('.sub-expression').each(function(){
//    sub_expression += " "+$(this).text().trim();
//  });

  // write it to form for submit
  $('#expression').val($.trim(sub_expression+" "+expression));
//  $('#ready_expressions').val($.trim(sub_expression+" "+expression));

} 

monitoring.remove_dimension_row = function(ID) {
  // add value to choosen dimension key
  var dimension_key = $("#dimension_key_"+ID).val();
  var dimension_value = $("#dimension_value_"+ID).val();

  // check for exiting key
  if(!dimension_data.hasOwnProperty(dimension_key)) {
    // create key and empty array
    dimension_data[dimension_key] = [];
  }

  // add free value to array
  dimension_data[dimension_key].push(dimension_value);
  // remove entry
  $('#expression_dimension_'+ID).remove();
  // remove latest empty dimension key - value input and render new to update typeahead
  $('#expression_dimension_'+dimension_cnt).remove();
  // generate expression and render new dimension row
  monitoring.generate_expression();
  render_dimension_row(dimension_cnt);
  show_statistic();
};

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
  