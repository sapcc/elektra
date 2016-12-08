{ul,li} = React.DOM
shared_filesystem_storage.Application = React.createClass
  displayName: 'Application'
  statics: 
    # tabs information
    tabs:[
      { uid: 'shares', label: 'Shares', contentClass: 'Shares' },
      { uid: 'snapshots', label: 'Snapshots', contentClass: 'Snapshots' },
      { uid: 'share_networks', label: 'Share Networks', contentClass: 'ShareNetworks' }]
    
    ajax: 
      request: (url, method, options={}) ->
        url = url.replace(/([^:]\/)\/+/g, "$1")
        $.ajax 
          url: url
          method: method
          dataType: 'json'
          data: options['data']
          success: options['success']
          error: options['error']  
          complete: ( jqXHR, textStatus) ->
            redirectToUrl = jqXHR.getResponseHeader('Location')          
            if redirectToUrl # url is presented
              # Redirect to url
              currentUrl = encodeURIComponent(window.location.href)
              redirectToUrl = redirectToUrl.replace(/after_login=(.*)/g,"after_login=#{currentUrl}")
              window.location = redirectToUrl  
            else
              options['complete'](jqXHR, textStatus) if options["complete"]
          
      get: (url, options={}) -> shared_filesystem_storage.Application.ajax.request(url,'GET',options)
      post: (url, options={}) -> shared_filesystem_storage.Application.ajax.request(url,'POST',options)
      put: (url, options={}) -> shared_filesystem_storage.Application.ajax.request(url,'PUT',options)
      delete: (url, options={}) -> shared_filesystem_storage.Application.ajax.request(url,'DELETE',options)    
  
  # creates an ajax object using root_url as prefix for url 
  ajax: () ->
    unless @ajaxObject 
      root_url = @props.root_url
      @ajaxObject=
        get:    (path, options={}) -> shared_filesystem_storage.Application.ajax.get("#{root_url}/#{path}",options)  
        post:   (path, options={}) -> shared_filesystem_storage.Application.ajax.post("#{root_url}/#{path}",options)  
        put:    (path, options={}) -> shared_filesystem_storage.Application.ajax.put("#{root_url}/#{path}",options)  
        delete: (path, options={}) -> shared_filesystem_storage.Application.ajax.delete("#{root_url}/#{path}",options)  
    @ajaxObject
      
  getDefaultProps: () ->
    permissions: 
      shares:           { create: false, list: false }
      snapshots:        { create: false, list: false }
      shareNetworks:  { create: false, list: false }       
    
  getInitialState: () ->
    tabs = shared_filesystem_storage.Application.tabs
    activeTab = 'shares'
    
    for tab in tabs
      if window.location.hash=="##{tab.uid}"
        activeTab = tab.uid
        break
        
    activeTabUid: activeTab
    shareNetworks: null
    snapshots: null
    shares: null
    
  
  ################### HELPER METHODS ####################
  loadItems: (path) ->
    itemsName=path
    # replace all "-x" with "X"
    if itemsName.indexOf('-')>-1
      tokens = itemsName.split('-')
      itemsName = tokens.shift()
      itemsName += token.charAt(0).toUpperCase() + token.slice(1) for token in tokens
      
    # do not do ajax if items already loaded
    return if @state[itemsName]
    # load remote items
    @ajax().get path,
      error: ( jqXHR, textStatus, errorThrown) -> 
        console.log jqXHR, textStatus, errorThrown
        errors = JSON.parse(jqXHR.responseText)
        message = ul null,
          li(key: name, "#{name}: #{error}") for name,error of errors if errors
          
        shared_filesystem_storage.ReactErrorDialog.show(errorThrown, description: message)
      success: ( data, textStatus, jqXHR ) => 
        newState = {}
        newState[itemsName] = data
        @setState newState
  
  addItem: (itemsName,item) ->
    items = @state[itemsName].slice()
    items.push item
    newState = {}
    newState[itemsName] = items
    @setState newState
  
  updateItem: (itemsName,item,data) ->
    items = @state[itemsName].slice()
    for index of items
      if items[index].id==item.id
        items[index]=data
        break
    newState = {}
    newState[itemsName] = items
    @setState newState
   
  deleteItem: (itemsName,item) ->
    items = @state[itemsName].slice()
    index = items.indexOf item
    items.splice index, 1
    newState = {}
    newState[itemsName] = items
    @setState newState
    
    
  reloadShare: (share) ->
    @ajax().get "shares/#{share.id}",
      success: ( data, textStatus, jqXHR ) => 
        @updateShare(share,data)    
        
  getShare: (shareId) ->
    return null unless @state.shares
    for share in @state.shares
      return share if shareId==share.id           
    
          
  ###################### HANDLE SHARES #################
  loadShares: -> @loadItems("shares")
  addShare: (share) -> @addItem("shares",share)
  updateShare: (share,data) -> @updateItem("shares",share,data)
  deleteShare: (share) -> @deleteItem("shares",share)
     
  ###################### HANDLE SHARE NETWORKS #################  
  loadShareNetworks: () -> @loadItems("share-networks")
  addShareNetwork: (shareNetwork) -> @addItem("shareNetworks",shareNetwork)
  updateShareNetwork: (shareNetwork,data) -> @updateItem("shareNetworks",shareNetwork,data)
  deleteShareNetwork: (shareNetwork) -> @deleteItem("shareNetworks",shareNetwork)
   
  #################### HANDLE SNAPSHOTS ####################
  loadSnapshots: () -> @loadItems("snapshots")
  addSnapshot: (snapshot) -> @addItem("snapshots",snapshot)
  updateSnapshot: (snapshot,data) -> @updateItem("snapshots",snapshot,data)
  deleteSnapshot: (snapshot) -> @deleteItem("snapshots",snapshot)
          
  setActiveTab: (uid) ->
    @setState activeTabUid: uid
    window.location.hash = uid
  
  can: (action,uid) ->
    @props.permissions[uid][action]  

  render: -> 
    {div,ul} = React.DOM
    tabs = shared_filesystem_storage.Application.tabs

    div null,
      ul { className: 'nav nav-tabs' },
        for tab in tabs
          if @can('list',tab.uid)
            React.createElement shared_filesystem_storage.Tab, active: (@state.activeTabUid is tab.uid), key: tab.uid, 
            uid: tab.uid, label: tab.label , onSelect: @setActiveTab

      div { className: 'tab-content'},
        for tab in tabs
          if @can('list',tab.uid)
            React.createElement shared_filesystem_storage.Panel, 
              active: (@state.activeTabUid is tab.uid)
              key: tab.uid
              ajax: @ajax()
              can_create: @can('create',tab.uid)
              contentClass: tab.contentClass
              setActiveTab: @setActiveTab
              
              shareNetworks:      @state.shareNetworks
              loadShareNetworks:  @loadShareNetworks
              addShareNetwork:    @addShareNetwork 
              updateShareNetwork: @updateShareNetwork
              deleteShareNetwork: @deleteShareNetwork 
              
              shares:       @state.shares
              loadShares:   @loadShares
              addShare:     @addShare
              updateShare:  @updateShare
              deleteShare:  @deleteShare
              reloadShare:  @reloadShare
              getShare:     @getShare
              
              snapshots:      @state.snapshots
              loadSnapshots:  @loadSnapshots
              addSnapshot:    @addSnapshot
              updateSnapshot: @updateSnapshot
              deleteSnapshot: @deleteSnapshot