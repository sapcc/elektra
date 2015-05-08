$(document).on('ready page:load', function () {

$(".toggle-debug").click(function(e) {
  e.preventDefault();
  $(".debug-info").toggleClass("visible");
});

});
