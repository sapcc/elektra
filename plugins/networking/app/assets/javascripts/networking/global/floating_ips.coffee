subnets = {}
$loader = $('<span class="spinner"></span>')

showSubnets= (subnets) ->
  $select = $('#floating_ip_floating_subnet_id')
  $select.empty()

  $select.append('<option value=""></option>')
  for subnet in subnets
    available_ips = (subnet.total_ips-subnet.used_ips)
    $select.append('<option '+("disabled=\"disabled\"" if available_ips<=0)+' value="'+subnet.subnet_id+'">'+subnet.subnet_name+' ('+subnet.cidr+', available IPs: '+available_ips+')'+'</option>')
  $('fieldset#subnets .form-group').show()


loadSubnets= (networkId) ->
  if !networkId || networkId.trim().length==0
    $('fieldset#subnets .form-group').hide()
    $('form#new_floating_ip button[type="submit"]').prop('disabled',true)
    return

  if subnets[networkId]
    showSubnets(subnets[networkId])
  else
    $('form#new_floating_ip button[type="submit"]').prop('disabled',true)
    $('fieldset#subnets .form-group').hide()
    if policy.isAllowed("networking:ip_availability")
      $('fieldset#subnets').append($loader)
      $.ajax(
        #url: "networks/#{networkId}/ip_availability"
        url: "#{window.location.protocol}//#{window.location.host}/#{scopedDomainFid}/#{scopedProjectFid}/networking/networks/#{networkId}/ip_availability"
        success: (data, textStatus, jqXHR ) ->
          subnets[networkId] = data
          $loader.remove()
          showSubnets(subnets[networkId])
      )
    else
      $select = $('#floating_ip_floating_subnet_id')
      $select.empty()
      $('fieldset#subnets .form-group').show()
      $('#floating_ip_floating_subnet_id').parent().append("<p class='help-block'>Get availability ips is not allowed</p>")

init= () ->
  if $('#floating_ip_floating_subnet_id').length==0 || ($('#floating_ip_floating_subnet_id')[0].value || '').trim().length==0
    $('fieldset#subnets .form-group').hide()
    $('form#new_floating_ip button[type="submit"]').prop('disabled',true)

  #loadSubnets(this.value) if $('#floating_ip_floating_network_id').trim().length>0

  $('#floating_ip_floating_network_id').change () -> loadSubnets(this.value)

  $('#floating_ip_floating_subnet_id').change () ->
    if this.value.trim().length>0 || $('#floating_ip_floating_ip_address').val().trim().length>0
      $('form#new_floating_ip button[type="submit"]').prop('disabled',false)
    else
      $('form#new_floating_ip button[type="submit"]').prop('disabled',true)

  $('#floating_ip_floating_ip_address').change () ->
    if this.value.trim().length>0 || $('#floating_ip_floating_subnet_id').val().trim().length>0
      $('form#new_floating_ip button[type="submit"]').prop('disabled',false)
    else
      $('form#new_floating_ip button[type="submit"]').prop('disabled',true)

  if $('#floating_ip_floating_network_id').val()
    setTimeout () ->
      loadSubnets($('#floating_ip_floating_network_id').val())
    , 500

$(document).on 'modal:contentUpdated', (e) -> init()
