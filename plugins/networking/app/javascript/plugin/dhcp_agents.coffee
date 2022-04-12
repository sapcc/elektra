$.fn.dhcpFormControl = (options={}) ->

  this.each () ->
    # get form control button
    $control  = $(this)
    # get form
    $form = $($control.data('controlDhcpForm'))
    # setup form
    $form.css( "display", "none").removeClass('hidden')

    if typeof options is 'string'
      if options=='hide'
        $(this).text('+').addClass('btn-primary').removeClass('btn-default')
        $form.hide('slow')
      else if options=='show'
        $form.show('slow')
        $(this).text('cancel').removeClass('btn-primary').addClass('btn-default')
      return this;

    # setup control behavior
    $control.click () ->
      if $form.is(':visible')
        $(this).text('+').addClass('btn-primary').removeClass('btn-default')
        $form.hide('slow')
      else
        $form.show('slow')
        $(this).text('cancel').removeClass('btn-primary').addClass('btn-default')

    return this
