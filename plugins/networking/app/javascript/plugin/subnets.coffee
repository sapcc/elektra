errorsToStringArray= (errors) ->
  errorsStringArray = []
  if typeof errors == 'object'
    for key, messages of errors
      msg = if typeof messages == 'array' then messages.join(', ') else messages
      errorsStringArray.push(key+': '+msg)
  else
    errorsStringArray = [errors]
  errorsStringArray

class SubnetForm
  constructor: (url, createCallback) ->
    @data = { name: null, cidr: null }
    @url = url
    @createCallback = createCallback
    @state = {
      errors: null
      show: false
      loading: false
    }

  submit: () ->
    @state.loading = true
    @render()
    $.ajax
      url: @url
      method: 'post'
      data: { subnet: @data }
      success: (data, textStatus, jqXHR) =>
        @state.loading = false
        @createCallback(data)
      error: ( jqXHR, statusText, errorThrown ) =>
        errors = if jqXHR.responseJSON
                   jqXHR.responseJSON["errors"]
                 else
                   errorThrown || statusText
        @state.errors = errorsToStringArray(errors)

        @state.loading = false
        @render()

  reset: ->
    @state.errors = null
    @data = {}
    @render()

  setData: (data) ->
    for key, value of data
      @data[key] = value

  show: ->
    @state.show = true
    @render()

  hide: ->
    @state.errors = null
    @state.show = false
    @render()

  render: ->
    unless @$form
      cidrHelpText = 'must be within 10.180.0.0/16 range'

      @$form = $('<form class="form-inline"></form>')
      @$form.submit (e) =>
        e.preventDefault()
        @submit()

      @$nameInput = $('<input class="form-control string required" placeholder="Name" type="text">')
      @$cidrInput = $('<input class="form-control string required" placeholder="CIDR ('+cidrHelpText+')" type="text">')

      self = this
      @$nameInput.keyup () -> self.data['name'] = this.value
      @$cidrInput.keyup () -> self.data['cidr'] = this.value

      @$submitButton = $('<input type="submit" class="btn btn-primary" value="Add">')

      # @$form.append($('<div class="form-group"></div>').append(@$nameInput))
      # .append($('<div class="form-group"></div>').append(@$cidrInput))
      # .append($('<div class="form-group"></div>').append(@$submitButton))

      @$form.append($('<div class="form-group"></div>').append(@$nameInput))
        .append($('<div class="form-group"></div>').append(@$cidrInput))
        .append($('<div class="form-group"></div>').append(@$submitButton))

      @$error = $('<div></div>').appendTo(@$form)

      @$cidrInput.tooltip(placement: 'top', title: cidrHelpText)

    @$error.empty()
    @$nameInput.val(@data['name'])
    @$cidrInput.val(@data['cidr'])

    if @state.show then @$form.fadeIn('slow') else @$form.fadeOut('slow')

    if @state.errors
      @$error.append('<div class="has-error"><span class="help-block">'+@state.errors.join(' and ')+'</span></div>')

    if @state.loading
      @$submitButton.prop('disabled', true).val('Please wait...')
    else
      @$submitButton.prop('disabled', false).val('Add')
    @$form


class Subnets
  constructor: (element) ->
    @element = element
    @url = $(element).data('url')
    @subnets = $(element).data('items')
    @network = $(element).data('network')

    @state = {
      lastItemsCount: 0
      loading: false
      showForm: false
      subnets: $(element).data('items')
      errors: null
    }

    @form = new SubnetForm @url, (subnet) =>
      @state.subnets.push(subnet)
      @state.showForm = false
      @render()

    @render()
    @loadSubnets() unless @subnets

  loadSubnets: () ->
    @state.loading = true
    @render()
    $.ajax
      url: @url
      cache: false
      success: (data, textStatus, jqXHR) =>
        @state.loading = false
        @state.subnets = data
        @render()

  toggleForm: (anker) ->
    @state.showForm = !@state.showForm
    @render()

  removeSubnet: (anker, subnetId) ->
    if $(anker).data('confirm')
      clearTimeout(@removeTimer)
      $(anker).closest('tr').addClass('updating')
      $(anker).hide().html('<i class="fa fa-trash"></i>')

      $.ajax
        url: @url+'/'+subnetId
        method: 'delete'
        error: ( jqXHR, statusText, errorThrown ) =>
          $(anker).show().data('confirm',false)
          $(anker).closest('tr').removeClass('updating')
          errors = if jqXHR.responseJSON
                     jqXHR.responseJSON["errors"]
                   else
                     errorThrown || statusText
          @state.errors = errorsToStringArray(errors)
          @render()
        success: (data, textStatus, jqXHR) =>
          subnets = @state.subnets
          @state.subnets = []
          for subnet in subnets
            @state.subnets.push(subnet) unless subnet.id == subnetId
          @render()

    else
      $(anker).data('confirm', true).text('Confirm Delete')
      reset = () -> $(anker).data('confirm',false).html('<i class="fa fa-trash"></i>')
      @removeTimer = setTimeout(reset, 3000)

  loading: ->
    @$loading ||= $('<tr><td colspan="5"><span class="spinner"></span></td></tr>')

  render:  ->
    networkType = if @network['router:external'] then 'external' else 'private'

    unless @created
      @created = true

      if policy.isAllowed("networking:network_#{networkType}_update", {network: @network})
        toolbar = $('<div class="toolbar toolbar-controlcenter"></div>').appendTo(@element)
        buttons = $('<div class="main-control-buttons"></div>').appendTo(toolbar)

        @form.render().appendTo(toolbar).hide()
        @$addButton = $('<a href="#" class="btn btn-primary">+</a>').appendTo(buttons)
        @$addButton.click () => @toggleForm(this)

      @$error = $('<div></div>').appendTo(@element)

      $table = $('<table class="table">
      <thead><tr>
      <th>Name / ID</th>
      <th>CIDR</th>
      <th>Allocation Pools</th>
      <th>Host Routes</th>
      <th>Gateway IP</th>
      <th></th>
      </tr></thead></table>').appendTo(@element)
      @$tbody = $('<tbody></tbody>').appendTo($table)

    if @state.subnets && @state.lastItemsCount != @state.subnets.length
      @state.lastItemsCount = @state.subnets.length

      @$tbody.empty()
      self = this
      for subnet in @state.subnets
        pools = "#{p.start} - #{p.end}<br/>" for p in subnet.allocation_pools
        routes = "#{r.destination} -> #{r.nexthop}<br/>" for r in subnet.host_routes
        $tr = $('<tr id="'+subnet.id+'">
        <td>'+subnet.name+'<br/><span class="info-text">'+subnet.id+'</span></td>
        <td>'+subnet.cidr+'</td>
        <td>'+pools+'</td>
        <td>'+(routes || "")+'</td>
        <td>'+subnet.gateway_ip+'</td>
        </tr>').appendTo(@$tbody)
        $actions = $('<td class="snug"></td>').appendTo($tr)



        if policy.isAllowed("networking:network_#{networkType}_update", {network: @network})
          $deleteButton = $('<a class="btn btn-danger btn-sm" href="#"><i class="fa fa-trash"></i></a>').appendTo($actions)
          $deleteButton.click () ->
            subnet_id = $(this).closest('tr').prop('id')
            self.removeSubnet(this,subnet_id)

    if policy.isAllowed("networking:network_#{networkType}_update", {network: @network})
      if @state.showForm
        @form.show()
        @$addButton.addClass('btn-default').removeClass('btn-primary').text('x')
      else
        @form.hide()
        @$addButton.addClass('btn-primary').removeClass('btn-default').text('+')

    if @state.loading
      @loading().appendTo(@$tbody)
    else
      @loading().remove()

    @$error.empty()
    if @state.errors
      @$error.append('<div class="has-error"><span class="help-block">'+@state.errors.join(' and ')+'</span></div>')

$(document).on 'modal:contentUpdated', (e) ->
  $('*[data-network-subnets]').each () -> new Subnets(this)

$ ->
  # init the subnets also on plain pages like from object lookup and wait until policy
  if typeof policy == 'undefined'
    setTimeout ( ->
      $('*[data-network-subnets]').each () -> new Subnets(this)
    ), 1000
