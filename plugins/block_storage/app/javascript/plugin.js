// This function is visible only inside this file.
function test() {
  //...
}

// This function is available from everywhere by calling block_storage.name()
block_storage.name = function () {
  "block_storage"
}

// This is always executed on page load.
$(document).ready(function () {
  // ...
})
