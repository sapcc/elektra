
@switch_source_type=(event) ->
  value = event.target.value
  if value == 'email'
    $('#email-source').removeClass('hide')
    $('#domain-source').addClass('hide')
    $('#domain-source-name').addClass('hide')
  else if value == 'domain'
    $('#domain-source').removeClass('hide')
    $('#domain-source-name').removeClass('hide')
    $('#email-source').addClass('hide')


@populate_email_addresses=(event) ->
  value = event.target.value
  console.log "email address is changed: " + value
  $('#plain_email_reply_to_addr').val(value)

@populate_domain_addresses=(event) ->
  value = event.target.value
  console.log "domain address is changed: " + value
  $('#plain_email_source_domain').val(value)

@set_domain_suffix=(event) ->
  value = event.target.value
  console.log "domain change detected"
  $('#domain-source-name').val(value)


$(document).on 'modal:contentUpdated', () ->

  # handler to switch source type between email and domain
  # console.log "content updated"
  $(document).on 'change','select[data-toggle="sourceSwitch"]', switch_source_type
  # $(document).on 'click','#domain-source-name', set_domain_suffix
  # $(document).on 'change','select[id="plain_email_source_email"]', populate_email_addresses
  # $(document).on 'change','select[id="plain_email_source_domain"]', populate_domain_addresses
