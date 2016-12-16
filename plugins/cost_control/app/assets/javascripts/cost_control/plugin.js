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
// outside this closure you should bind functions to cost_control. 
//  
//       
//= require_tree .   

// This function is visible only inside this file.
function test() {
    //...
}

// This function is available from everywhere by calling cost_control.name()
cost_control.name = function () {
    "cost_control"
}

// This is always executed on page load.
$(document).ready(function () {
    // ...
});

// Call function from other files inside this plugin using the variable cost_control
//cost_control.anyFunction()

// Stacked multi chart bar
cost_control.stream_layers = function (n, values) {
    function bump(a) {
        var x = 1,
            y = 2,
            z = 10,
            w = (0 - y) * z;
        a[0] += x * Math.exp(-w * w);
    }

    return values.map(function (val, idx) {
            // normalize
            val *=10;
            var a = [val];
            bump(a);
            return a.map(cost_control.stream_index);
        });
    }

cost_control.stream_index = function (d, i) {
    return {x: 0, y: Math.max(0, d)};
}

cost_control.render_cost_bar = function (ID, DATA) {

    d3.selectAll("svg > *").remove();
    d3.select(ID)
        .on("mousemove", null)
        .on("mouseout", null)
        .on("dblclick", null)
        .on("click", null);
    d3.select(".nvtooltip").remove();

    nv.addGraph(function () {
        var width = 250,
            height = 400,
            chart = nv.models.multiBarChart()
                .width(width)
                .height(height)
                .showXAxis(false)
                .showYAxis(false);

        chart.margin({"left": 10, "right": 30, "top": 5, "bottom": 30});
        //chart.xAxis.tickFormat(function(d) { return d + ' min' });

        chart.multibar.stacked(true);
        //Do not allow user to switch between 'Grouped' and 'Stacked' mode.
        chart.showControls(false);


        // TODO: custom tooltips
        chart.tooltip.contentGenerator(function (obj) { return obj.data.key +' : ' + obj.data.size / 10});

        d3.select(ID)
            .datum(DATA)
            .transition().duration(500)
            .call(chart)
            .style({'width': width, 'height': height});

        nv.utils.windowResize(chart.update);

        return chart;
    });
};
