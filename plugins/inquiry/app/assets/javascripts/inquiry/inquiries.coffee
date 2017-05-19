$ ->
  $("#inquiry-kind-filter").change ->
    $('.inquiries-container tbody').html("<tr><td><div class='spinner'></div></td></tr>")
    $("#inquiry-filter-form").submit();
