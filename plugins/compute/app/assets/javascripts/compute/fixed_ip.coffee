sanitize = (value) ->
  lt = /</g
  gt = />/g
  ap = /'/g
  ic = /"/g
  value.toString().replace(lt, "&lt;").replace(gt, "&gt;").replace(ap, "&#39;").replace(ic, "&#34;");

$.fn.fixedIpSelector = (options={}) ->

  this.each () ->
    $networkSelect = $(options.networkSelector)
    $subnetSelect = $(options.subnetSelector)
    $portInput = $(options.portSelector)
    $fixedIpInput = $(this)
    subnets = options.subnets
    ports = options.ports

    $ips_container = $('<div/>').insertAfter($fixedIpInput)

    $fixedIpInput.autocomplete({
      source: [],
      appendTo: $ips_container,
      minLength: 0,
      select: (event, ui) ->
        event.preventDefault()
        $fixedIpInput.val(ui.item.fixed_ips[0]['ip_address'])
    }).data('ui-autocomplete')._renderItem = (ul, port) ->
      for ip in port.fixed_ips
        description = port.description || port.name
        description = if description then "(#{description})" else ''
        return $('<li>').append("#{ip.ip_address} #{description}").appendTo(ul)

    updatePortId = (ip) ->
      ip = (ip || '').trim()
      $portInput.val(null)
      for port in ports
        for ip_data in port.fixed_ips
          $portInput.val(port.id) if ip_data.ip_address.trim() == ip

    $fixedIpInput.focus () -> $fixedIpInput.autocomplete('search', '')
    $fixedIpInput.click () -> $fixedIpInput.autocomplete('search', '')
    $fixedIpInput.change () -> updatePortId($(this).val())
    $fixedIpInput.blur () -> updatePortId($(this).val())

    updateAvailablePorts = (subnetId) ->
      selected = $fixedIpInput.val()
      $fixedIpInput.val('')
      $portInput.val('')
      source = []
      if subnetId
        for port in ports
          for ip in port.fixed_ips
            if ip.subnet_id == subnetId
              if selected == ip.ip_address
                $fixedIpInput.val(selected)
                #$portInput.val(port.id)
              description = port.description || port.name
              description = if description then "(#{description})" else ''
              source.push(port)

      $fixedIpInput.autocomplete('option', 'source', source)

    updateAvailableSubnets = (networkId) ->
      selected = $subnetSelect.val()
      $subnetSelect.find("option").remove() # remove all options first
      unless networkId
        # indicate to the user that no network is selected
        $subnetSelect.append( $("<option value=''>Please choose a network first</option>") )
        updateAvailablePorts('')
        return

      filtered_subnets = subnets.filter (sub) -> sub.network_id == networkId # filter for subnets for the selected network
      if filtered_subnets.length > 1
        $subnetSelect.append($("<option value=''>Choose a subnet (optional)</option>"))
        for subnet in filtered_subnets
          $subnetSelect.append(
            $("<option value='#{subnet.id}' #{'selected' if subnet.id==selected}>#{sanitize(subnet.name)} (#{subnet.cidr})</option>")
          )
        updateAvailablePorts($subnetSelect.val())
      else
        # if network has only one subnet display it to the user but don't actually select it to prevent the special handling with port creation
        first_subnet = filtered_subnets[0]
        $subnetSelect.append(
          $("<option value='#{first_subnet.id}'>#{sanitize(first_subnet.name)} (#{first_subnet.cidr})</option>")
        )
        updateAvailablePorts(first_subnet.id)



    $networkSelect.change () -> updateAvailableSubnets($(this).val())
    $subnetSelect.change () -> updateAvailablePorts($(this).val())

    updateAvailableSubnets($networkSelect.val())
    updateAvailablePorts($subnetSelect.val())
