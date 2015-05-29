$(document).on('ready page:load', function () {

  $(".toggle-debug").click(function(e) {
    e.preventDefault();
    $(".debug-info").toggleClass("visible");
  });


  /* Interactive page elements */

  $(".js-trigger-hiddenform").click(function(e) {
    e.preventDefault();
    $(this).hide();
    $(".js-target-hiddenform").show();
  });

  $(".js-cancel-hiddenform").click(function(e) {
    e.preventDefault();
    $(".js-target-hiddenform").hide();
    $(".js-trigger-hiddenform").show();
  });

});
