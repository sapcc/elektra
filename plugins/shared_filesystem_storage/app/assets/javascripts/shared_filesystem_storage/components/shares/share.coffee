{ tr,td,br,span,div,button,ul,li,a ,i,small} = React.DOM
    
shared_filesystem_storage.Share = React.createClass
  componentDidMount: ->
    @props.loadShareRules(@props.share.id) unless @props.shareRules[@props.share.id]
    $(@refs.row).find('[data-toggle="tooltip"]').tooltip() 
  
  componentDidUpdate: ->
    $(@refs.row).find('[data-toggle="tooltip"]').tooltip()  
    
  getInitialState: ->
    loading: false

  handleDelete: (e) ->
    e.preventDefault()
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
        @setState loading: false      
                    
  handleEdit: (e) ->
    e.preventDefault()
    @props.handleEditShare(@props.share)   
    
  handleSnapshot: (e) ->
    e.preventDefault()
    @props.handleNewSnapshot(@props.share)  
    
  handleAccessControl: (e) ->
    e.preventDefault()
    @props.handleAccessControl(@props.share)  
    
  handleShow: (e) ->
    e.preventDefault()
    @props.handleShowShare(@props.share)
  
  shareNetwork: () ->
    if @props.shareNetworks
      for network in @props.shareNetworks
        return network if network.id==@props.share.share_network_id  
      
  render: ->
    shareNetwork = @shareNetwork()
    
    tr {className: ('updating' if @state.loading), ref: 'row'},
      td null, 
        a href: '#', onClick: @handleShow, @props.share.name
      td null, @props.share.share_proto    
      td null, (@props.share.size || 0) + ' GB'	
      td null, (if @props.share.is_public then 'public' else 'private')
      td null, 
        if @props.share.status=='creating'
          setTimeout( (() => @props.reloadShare(@props.share)),5000)
          span className: 'spinner'
        @props.share.status	
      td null, 
        if shareNetwork
          span null, 
            shareNetwork.name
            span className: 'info-text', " "+shareNetwork.cidr
            if @props.shareRules and (rules = @props.shareRules[@props.share.id])
              span null,
                br null
                for rule in rules
                  small key: rule.id,
                  "data-toggle": "tooltip",  "data-placement": "right", 
                  title: "Access Level: #{if rule.access_level=='ro' then 'read only' else if 'rw' then 'read/write' else rule.access_level}", 
                  className: "#{if rule.access_level == 'rw' then 'text-success' else 'text-warning'}",
                    
                    i className: "fa fa-fw fa-#{if rule.access_level == 'rw' then 'unlock' else 'unlock-alt'}"
                    rule.access_to
        else
          span className: 'spinner'  
        
          
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
              if @props.share.permissions.update and @props.share.status=='available'
                li null,
                  a { href: '#', onClick: @handleSnapshot}, 'Create Snapshot'        
               
              if @props.share.permissions.update and @props.share.status=='available'    
                li null, 
                  a { href: '#', onClick: @handleAccessControl }, 'Access Control'    
  

          	