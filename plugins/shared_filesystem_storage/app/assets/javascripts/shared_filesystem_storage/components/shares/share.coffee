{ tr,td,br,span,div,button,ul,li,a } = React.DOM
    
shared_filesystem_storage.Share = React.createClass
  getInitialState: ->
    loading: false
    
  handleDelete: (e) ->
    shared_filesystem_storage.ConfirmDialog.ask 'Are you sure?', 
      #validationTerm: @props.shared_network.name
      description: 'Would you like to delete this share?'
      confirmLabel: 'Yes, delete it!'
    .then => @deleteShare()
    .fail -> null
            
  deleteShare: ->
    @setState loading: true
    @props.ajax.delete "shares/#{@props.share.id}",
      success: () =>
        @props.handleDeleteShare @props.share
      error: ( jqXHR, textStatus, errorThrown ) =>
        alert(errorThrown) 
        @setState loading: false
                    
  handleEdit: (e) ->
    e.preventDefault()
    @props.handleEditShare(@props.share)   
    
  handleSnapshot: (e) ->
    e.preventDefault()
    @props.handleNewSnapshot(@props.share)  
    
  render: ->
    tr  {className: ('updating' if @state.loading)},
      td null, 
        @props.share.name
        br null
        span {className: 'info-text'}, @props.share.id
      td null, @props.share.share_proto    
      td null, (@props.share.size || 0) + ' GB'	
      td null, if @props.share.is_public then 'public' else 'private'
      td null, @props.share.status	
      td { className: "snug" },
        if @props.share.permissions.delete or @props.share.permissions.update
          div { className: 'btn-group' },
            button { className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true},
              span {className: 'fa fa-cog' }

            ul { className: 'dropdown-menu dropdown-menu-right', role: "menu" },
              if @props.share.permissions.delete
                li null, 
                  a { href: '#', onClick: @handleDelete}, 'Delete'
              if @props.share.permissions.update
                li null, 
                  a { href: '#', onClick: @handleEdit }, 'Edit' 
                if @props.share.status=='available'
                  li null,
                    a { href: '#', onClick: @handleSnapshot}, 'Create Snapshot'    
  

          	