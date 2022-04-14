import "./recordsets.coffee"
import "./transfer_requests.coffee"

// This function is visible only inside this file.
function test() {
  //...
}

// This function is available from everywhere by calling dns_service.name()
dns_service.name = function () {
  "dns_service"
}

// This is always executed on page load.
$(document).ready(function () {
  // ...
})

// Call function from other files inside this plugin using the variable dns_service
//dns_service.anyFunction()
