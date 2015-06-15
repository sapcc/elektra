$(document).on('ready page:load', function () {

  $(".toggle-debug").click(function(e) {
    e.preventDefault();
    $(".debug-info").toggleClass("visible");
  });


  /* Interactive page elements */


  /* -------------------------------------------
     Hidden form
     -------------------------------------------
  */

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


  /* -----------------------------------------------------------------------
     Dynamic Form - Hide/reveal parts of the form following a trigger event
     -----------------------------------------------------------------------
  */

  $(".dynamic-form-trigger").change(function() {
    var allTargets  = $(".dynamic-form-target");
    var target      = allTargets.filter("*[data-type='" + $(this).val() + "']") // from all targets select the one that matches the value that's been selected with the trigger

    // find all targets, hide them, set descendants that are any kind of form input to disabled (to prevent them getting submitted when the form is posted)
    allTargets.hide().find(":input").prop("disabled", true);

    // show the target that's been selected by the trigger, enable all descendants that are inputs
    target.show().find(":input").prop("disabled", false);
  });



});
