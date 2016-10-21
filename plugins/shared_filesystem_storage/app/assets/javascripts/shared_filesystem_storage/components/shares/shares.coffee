{ div,table,thead,tr,th,tbody,td,span,button } = React.DOM

shared_filesystem_storage.Shares = React.createClass
  componentDidMount: () ->
    # load content on adding this component to the DOM
    @props.loadShares() unless @props.shares
    
  getInitialState: ->
    availability_zones: null
    # share_types: null
    
  loadAvailabilityZones: () ->
    unless @state.availability_zones
      @props.ajax.get 'shares/availability_zones',
        success: ( data, textStatus, jqXHR ) => @setState availability_zones: data  
  
  # loadShareTypes: () ->
  #   unless @state.share_types
  #     $.ajax
  #       url: "#{@props.root_url}/shares/share_types"
  #       dataType: 'json'
  #       method: 'GET'
  #       success: ( data, textStatus, jqXHR ) =>
  #         @setState share_types: data      
 
  # open modal window with form for new share.  
  newShare: () ->
    @loadAvailabilityZones()
    # @loadShareTypes()
    @props.loadShareNetworks()
    @refs.newShareModal.open()
    
  # open modal window with form for new snapshot.  
  newSnapshot: (share) ->
    @refs.newSnapshotModal.open(share)

  # open modal window with form for edit share.
  editShare: (share) ->
    @loadAvailabilityZones()
    # @loadShareTypes()
    @props.loadShareNetworks()
    @refs.editShareModal.open(share)
                  
  render: ->
    unless @props.shares
      div null,
        span className: 'spinner', null
        'Loading...'
    else 
      div null, 
        # Modal Overlay for Editing Share
        React.createElement shared_filesystem_storage.EditShare,
          ref: 'editShareModal',
          ajax: @props.ajax,
          availability_zones: @state.availability_zones
          # share_types: @state.share_types
          shareNetworks: @props.shareNetworks
          handleUpdateShare: @props.updateShare
          setActiveTab: @props.setActiveTab
         
        React.createElement shared_filesystem_storage.NewSnapshot, 
          ref: 'newSnapshotModal', 
          ajax: @props.ajax, 
          handleCreateSnapshot: @props.addSnapshot
          snapshots: @props.snapshots
          loadSnapshots: @props.loadSnapshots
              
        if @props.can_create
          div null,
            # Modal Overlay for Creating Share
            React.createElement shared_filesystem_storage.NewShare, 
              ref: 'newShareModal', 
              availability_zones: @state.availability_zones
              # share_types: @state.share_types
              shareNetworks: @props.shareNetworks
              ajax: @props.ajax, 
              handleCreateShare: @props.addShare
              setActiveTab: @props.setActiveTab
            
  
            div { className: 'toolbar' }, 
              button {type: "button", className: "btn btn-primary", onClick: @newShare}, 'Create new'

              
        table { className: 'table shares' },
          thead null,
            tr null,
              th null, 'Name'
              th null, 'Protocol'
              th null, 'Size'
              th null, 'Visibility'
              th null, 'Status'
              th null, 'Actions'
          tbody null,
            if @props.shares.length==0
              tr null,
                td { colSpan: 6 }, 'No Shares found.'
            for share in @props.shares
              React.createElement shared_filesystem_storage.Share, 
                key: share.id
                ajax: @props.ajax
                handleDeleteShare: @props.deleteShare
                handleEditShare: @editShare 
                handleNewSnapshot: @newSnapshot
                share: share   