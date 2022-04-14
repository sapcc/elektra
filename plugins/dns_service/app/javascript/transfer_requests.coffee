$.fn.initAcceptButtons = () ->
  $table = this
  itemsLength = $table.find('tbody tr').length

  $table.closest('.modal-content').find('[data-dismiss="modal"]').click () ->
    if $table.find('tbody tr').length < itemsLength
      l = window.location
      window.location.href="#{l.protocol}//#{l.host}/#{l.pathname}"

  $('form.transfer-request-accept').each (index,form) ->
    $button = $(form).find('button[type="submit"]')
    $keyInput = $(form).find('input[name="key"]')
    $keyInputContainer = $keyInput.closest('.form-group')

    $button.click (e) ->
      if $keyInput.val()
        $keyInput.closest('tr').addClass('updating')
      else
        e.preventDefault()
        if $keyInputContainer.is(':visible')
          $keyInputContainer.hide('slow', () -> $button.text('Accept'))
        else
          $button.text('Confirm')
          $button.prop('disabled', !$keyInput.val())
          $keyInputContainer.show('slow')

    $keyInput.keyup () ->
      $button.prop('disabled',!$(this).val())
