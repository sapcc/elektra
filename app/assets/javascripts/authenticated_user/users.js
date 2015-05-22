$(document).ready(function(){

  $("#accept_tos").click(function() {
    // on checkbox click enable button if checkbox is checked, disable button if checkbox is unchecked
    var tosAccepted = $(this).prop('checked');
    $("#register-button").prop('disabled', !tosAccepted);
  });

});
