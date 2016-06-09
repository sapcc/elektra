$ ->
  $('[data-toggle="tooltip"]').tooltip(delay: { "show": 300 })

$(document).on 'modal:contentUpdated', () ->  
  $( "[data-autocomplete-url]" ).each () ->
    $input = $(this)
    $input.autocomplete({
      appendTo: $input.parent(),
      source: $input.data('autocompleteUrl'),
      select: ( event, ui ) ->
        $input.val(ui.item.name);
        return false;
    }).data('ui-autocomplete')._renderItem = ( ul, item ) ->
        return $( "<li>" )
          .attr( "data-value", item.name )
          .append( item.name )
          .appendTo( ul );
