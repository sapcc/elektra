subnets = {}
$loader = $('<span class="spinner"></span>')

showSubnets= (subnets) ->
  $select = $('#floating_ip_floating_subnet_id')
  $select.empty()

  $select.append('<option value=""></option>')
  $select.append('<option value="'+subnet.id+'">'+subnet.name+'</option>') for subnet in subnets

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
    $('fieldset#subnets').append($loader)
    $.ajax(
      #url: "networks/#{networkId}/subnets"
      url: "#{window.location.protocol}//#{window.location.host}/#{scopedDomainFid}/#{scopedProjectFid}/networking/networks/#{networkId}/subnets"
      success: (data, textStatus, jqXHR ) ->
        subnets[networkId] = data
        $loader.remove()
        showSubnets(subnets[networkId])
    )

init= () ->
  if $('#floating_ip_floating_subnet_id').length==0 || ($('#floating_ip_floating_subnet_id')[0].value || '').trim().length==0
    $('fieldset#subnets .form-group').hide()
    $('form#new_floating_ip button[type="submit"]').prop('disabled',true)

  $('#floating_ip_floating_network_id').change () -> loadSubnets(this.value)

  $('#floating_ip_floating_subnet_id').change () ->
    if this.value.trim().length==0
      $('form#new_floating_ip button[type="submit"]').prop('disabled',true)
    else
      $('form#new_floating_ip button[type="submit"]').prop('disabled',false)

$(document).on 'modal:contentUpdated', (e) -> init()
