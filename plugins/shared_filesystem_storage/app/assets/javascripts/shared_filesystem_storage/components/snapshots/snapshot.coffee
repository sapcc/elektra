{tr,td,br,span,div,ul,li,button,a} = React.DOM

shared_filesystem_storage.Snapshot = React.createClass
  getInitialState: ->
    loading: false
    
  handleDelete: (e) ->
    e.preventDefault()
    shared_filesystem_storage.ConfirmDialog.ask 'Are you sure?', 
      #validationTerm: @props.shared_network.name
      description: 'Would you like to delete this snapshot?'
      confirmLabel: 'Yes, delete it!'
    .then => @deleteSnapshot()
    .fail -> null
            
  deleteSnapshot: ->
    @setState loading: true
    @props.ajax.delete "snapshots/#{ @props.snapshot.id }",
      success: () =>
        @props.handleDeleteSnapshot @props.snapshot
      error: ( jqXHR, textStatus, errorThrown ) => 
        errors = JSON.parse(jqXHR.responseText)
        message = ul null,
          li(key: name, "#{name}: #{error}") for name,error of errors if errors 
        ReactErrorDialog.show(errorThrown, description: message)
        
        @setState loading: false
                    
  
  handleEdit: (e) ->
    e.preventDefault()
    @props.handleEditSnapshot(@props.snapshot)  
    
  render: ->
    tr {className: ('updating' if @state.loading)},
      td null, 
        @props.snapshot.name
        br null
        span {className: 'info-text'}, @props.snapshot.id
      td null, 
        if @props.share
          div null,
            @props.share.name
            br null
            span {className: 'info-text'}, @props.snapshot.share_id    
        else
          @props.snapshot.share_id 
            
      td null, (@props.snapshot.size || 0) + ' GB'	
      td null, @props.snapshot.status	
      td { className: "snug" },
        if @props.snapshot.permissions.delete or @props.snapshot.permissions.update
          div { className: 'btn-group' },
            button { className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true},
              span {className: 'fa fa-cog' }

            ul { className: 'dropdown-menu dropdown-menu-right', role: "menu" },
              if @props.snapshot.permissions.delete
                li null, 
                  a { href: '#', onClick: @handleDelete}, 'Delete'
              if @props.snapshot.permissions.update
                li null, 
                  a { href: '#', onClick: @handleEdit }, 'Edit' 