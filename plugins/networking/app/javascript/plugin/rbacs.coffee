$.fn.rbacFormControl = (options={}) ->
    
  this.each () ->
    # get form control button
    $control  = $(this)
    # get form
    $form = $($control.data('controlRbacForm'))
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
     
    # initialize autocomplete on form input
    $form.find('[name="rbac[target_tenant]"]' ).autocomplete({
      source: (req, add) -> 
        # projects which are already in use
        unavailableProjects = $('table#rbacs tbody tr td:nth-child(2)[class!="form_content"]').map(() -> return $(this).text()).toArray()
        # add current project to unavailable projects
        unavailableProjects.push options['currentProject']
        # filter available projects (authProjects - unavailableProjects)
        values = options['authProjects'].filter ( el ) -> unavailableProjects.indexOf( el ) < 0
        
        add(values)
      appendTo: '#suggestions'
      minLength: 0
    }).click () -> $(this).autocomplete( "search", "" )
        
    return this