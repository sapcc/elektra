{ div,button,table,thead,tbody,tr,td,th,span } = React.DOM

shared_filesystem_storage.ShareNetworks = React.createClass
  componentDidMount: () ->
    # load content on adding this component to the DOM
    unless @props.shareNetworks
      @props.loadShareNetworks() 
      @loadNetworks()
    
  getInitialState: ->
    networks: null
    subnets: {}
     
  # this method is called in new or edit forms (see shared_filesystem_storage.EditShareNetwork)     
  loadNetworks: () ->
    unless @state.networks
      @props.ajax.get "share-networks/networks",
        success: ( data, textStatus, jqXHR ) =>
          @setState networks: data 
          
  # this method is called in new or edit forms (see shared_filesystem_storage.NewShareNetwork) 
  loadSubnets: (network_id) ->
    unless @state.subnets[network_id]
      @props.ajax.get "share-networks/subnets",
        data: {network_id: network_id}
        success: ( data, textStatus, jqXHR ) =>
          subnets = @state.subnets
          subnets[network_id] = data
          @setState subnets: subnets            

  # open modal window with form for new shared network.  
  newShareNetwork: () ->
    @refs.newShareNetworkModal.open()
    @loadNetworks()
    
  # open modal window with form for new shared network.  
  showShareNetwork: (shareNetwork) ->
    @refs.showShareNetworkModal.open(shareNetwork)
    @loadNetworks()  
  
  # open modal window with form for edit shared network.
  editShareNetwork: (shareNetwork) ->
    @refs.editShareNetworkModal.open(shareNetwork)
    @loadNetworks()
                        
  render: ->
    unless @props.shareNetworks
      div null,
        span className: 'spinner', null
        'Loading...'
    else
      div null, 
        # Modal Overlay for Editing Shared Network
        React.createElement shared_filesystem_storage.ShowShareNetwork,
          ref: 'showShareNetworkModal',
          networks: @state.networks,
          subnets: @state.subnets,
          loadSubnets: @loadSubnets
          
        React.createElement shared_filesystem_storage.EditShareNetwork,
          ref: 'editShareNetworkModal',
          ajax: @props.ajax,
          networks: @state.networks,
          subnets: @state.subnets,
          handleUpdateShareNetwork: @props.updateShareNetwork
          loadSubnets: @loadSubnets  
            
        if @props.can_create
          div null,
            # Modal Overlay for Creating Shared Network
            React.createElement shared_filesystem_storage.NewShareNetwork, 
              ref: 'newShareNetworkModal', 
              ajax: @props.ajax, 
              networks: @state.networks,
              handleCreateShareNetwork: @props.addShareNetwork  
              loadSubnets: @loadSubnets
            
            div { className: 'toolbar' }, 
              button {type: "button", className: "btn btn-primary", onClick: @newShareNetwork}, 'Create new'


        table { className: 'table share-networks' },
          thead null,
            tr null,
              th null, 'Name'
              th null, 'Neutron Net'
              th null, 'Neutron Subnet'
              th null, ''
          tbody null,
            if @props.shareNetworks.length==0
              tr null,
                td {colSpan: 6},'No Share Networks found.'
            for shareNetwork in @props.shareNetworks
              React.createElement shared_filesystem_storage.ShareNetwork, 
                ajax: @props.ajax, 
                key: shareNetwork.id, 
                shareNetwork: shareNetwork,
                networks: @state.networks,
                subnets: @state.subnets,
                loadSubnets: @loadSubnets,
                handleDeleteShareNetwork: @props.deleteShareNetwork
                handleEditShareNetwork: @editShareNetwork
                handleShowShareNetwork: @showShareNetwork
              