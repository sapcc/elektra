{ConfirmDialog} = shared_filesystem_storage

shared_filesystem_storage.ShareNetwork = React.createClass
  getInitialState: ->
    loading: false

  handleDelete: (e) ->
    ConfirmDialog.ask 'Are you sure?', 
      #validationTerm: @props.shareNetwork.name
      description: 'Would you like to delete this shared network?'
      confirmLabel: 'Yes, delete it!'
    .then => @deleteShareNetwork()
    .fail -> null
            
  deleteShareNetwork: ->
    @setState loading: true
    @props.ajax.delete "share-networks/#{ @props.shareNetwork.id }",
      success: () =>
        @props.handleDeleteShareNetwork @props.shareNetwork
      error: ( jqXHR, textStatus, errorThrown ) =>
        alert(errorThrown) 
        @setState loading: false
            
  
  handleEdit: (e) ->
    e.preventDefault()
    @props.handleEditShareNetwork(@props.shareNetwork)      
        
  render: ->
    {tr,td,br,a,span,div,button,ul,li,script} = React.DOM
    
    tr {className: ('updating' if @state.loading)}, 
      td null, 
        @props.shareNetwork.name
        br null
        span { className: 'info-text' }, @props.shareNetwork.id
      td null, @props.shareNetwork.neutron_net_id    
      td null, @props.shareNetwork.neutron_subnet_id	
      td null, @props.shareNetwork.ip_version
      td null, @props.shareNetwork.network_type  
      td { className: "snug" },
        if @props.shareNetwork.permissions.delete or @props.shareNetwork.permissions.update
          div { className: 'btn-group' },
            button { className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true},
              span {className: 'fa fa-cog' }

            ul { className: 'dropdown-menu dropdown-menu-right', role: "menu" },
              if @props.shareNetwork.permissions.delete
                li null, 
                  a { href: '#', onClick: @handleDelete}, 'Delete'
              if @props.shareNetwork.permissions.update
                li null, 
                  a { href: '#', onClick: @handleEdit }, 'Edit'    
