window.metrics = window.metrics || {}

// This function is available from everywhere by calling metrics.name()
metrics.name = function () {
  "metrics"
}

// This is always executed on page load.
$(document).ready(function () {
  // ...
})

// Call function from other files inside this plugin using the variable metrics
//metrics.anyFunction()
