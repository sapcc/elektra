subnets = {}
$loader = $('<span class="spinner"></span>')

showSubnets= (subnets) ->
  $select = $('#router_external_gateway_info_external_fixed_ips_subnet_id')
  selected = $select.data('selected')
  $select.empty()

  $select.append('<option value=""></option>')
  for subnet in subnets
    available_ips = (subnet.total_ips-subnet.used_ips)
    $select.append('<option '+("selected" if $.inArray(selected,subnet.subnet_id))+' '+("disabled=\"disabled\"" if available_ips<=0)+' value="'+subnet.subnet_id+'">'+subnet.subnet_name+' ('+subnet.cidr+', available IPs: '+available_ips+')'+'</option>')

  $('fieldset#subnets .form-group').show()


loadSubnets= (networkId) ->
  if !networkId || networkId.trim().length==0
    $('fieldset#subnets .form-group').hide()
    $('form#new_router button[type="submit"]').prop('disabled',true)
    return

  if subnets[networkId]
    showSubnets(subnets[networkId])
  else
    $('form#new_router button[type="submit"]').prop('disabled',true)
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
  if $('#router_external_gateway_info_external_fixed_ips_subnet_id').length==0 || ($('#router_external_gateway_info_external_fixed_ips_subnet_id')[0].value || '').trim().length==0
    $('fieldset#subnets .form-group').hide()
    $('form#new_router button[type="submit"]').prop('disabled',true)

  $('#router_external_gateway_info_network_id').change () -> loadSubnets(this.value)
  if $('#router_external_gateway_info_network_id').val()
    loadSubnets($('#router_external_gateway_info_network_id').val())

  $('#router_external_gateway_info_external_fixed_ips_subnet_id').change () ->
    if this.value.trim().length==0
      $('form#new_router button[type="submit"]').prop('disabled',true)
    else
      $('form#new_router button[type="submit"]').prop('disabled',false)

$(document).on 'modal:contentUpdated', (e) -> init()
