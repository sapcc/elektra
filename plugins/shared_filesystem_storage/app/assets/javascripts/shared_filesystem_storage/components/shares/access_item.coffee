{ tr,td,button,i } = React.DOM

shared_filesystem_storage.AccessItem = React.createClass
  getInitialState: ->
    deleting: false

  handleDelete: (e) ->
    e.preventDefault()
    shared_filesystem_storage.ConfirmDialog.ask 'Are you sure?',
      #validationTerm: @props.shared_network.name
      description: 'Would you like to delete this access?'
      confirmLabel: 'Yes, delete it!'
    .then => @delete()
    .fail -> null

  delete: ->
    @setState deleting: true

    @props.ajax.delete "shares/#{@props.shareId}/rules/#{@props.rule.id}",
      success: () =>
        @props.handleDeleteRule @props.rule
      error: ( jqXHR, textStatus, errorThrown ) =>
        @setState deleting: null

  humanizeAccessLevel: () ->
    switch @props.rule.access_level
      when 'ro' then 'read only'
      when 'rw' then 'read/write'
      else @props.rule.access_level

  render: ->
    tr className: ('updating' if @state.deleting),
      td null, @props.rule.access_type
      td null, @props.rule.access_to
      td className: "#{if @props.rule.access_level == 'rw' then 'text-success' else 'text-info'}",
        i className: "fa fa-fw fa-#{if @props.rule.access_level == 'rw' then 'pencil-square' else 'eye'}"
        @humanizeAccessLevel()
      td null, @props.rule.state
      td className: 'snug',
        button className: 'btn btn-danger btn-sm', onClick: @handleDelete,
          i className: 'fa fa-minus'
