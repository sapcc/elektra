{ div,table,thead,tbody,tr,th,td,form,select,h4,label,span,input,button,abbr,select,option,a,i,small } = React.DOM
 
ReactCSSTransitionGroup = React.createFactory React.addons.CSSTransitionGroup
 
shared_filesystem_storage.AccessControl = React.createClass 
  displayName: 'AccessControl'
  
  getInitialState: () ->
    share: null
    showForm: false
      
  open: (share) -> 
    @setState share: share
    @refs.modal.open()
    
  close: () -> @refs.modal.close()
  handleClose: () -> @setState @getInitialState()
  
  toggleForm: (e) ->
    e.preventDefault()
    @setState showForm: !@state.showForm
    
  handleDeleteRule: (rule) ->
    @props.handleDeleteRule(@state.share.id, rule)
  
  handleCreateRule: (rule) ->
    @setState showForm: false
    @props.handleCreateRule(@state.share.id, rule)  
  
  shareNetwork: () ->
    if @state.share and @props.shareNetworks
      for network in @props.shareNetworks
        return network if network.id==@state.share.share_network_id  
          
  render: ->
    { Modal, ShareForm } = shared_filesystem_storage
    shareNetwork = @shareNetwork()
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 
          'Share Access Control'
          small null, " #{shareNetwork.name} #{shareNetwork.cidr}" if shareNetwork
      
      div className: 'modal-body', 
        if @state.share && @props.shareRules[@state.share.id]
          div null,
            table { className: 'table share-rules' },
              thead null,
                tr null,
                  th null, 'Access Type'
                  th null, 'Access to'
                  th null, 'Access Level'
                  th null, 'Status'
                  th className: 'snug'
              tbody null,
                if @props.shareRules[@state.share.id].length==0
                  tr null,
                    td colSpan: 5, 'No Rules found.'
                else    
                  for rule in @props.shareRules[@state.share.id]
                    React.createElement shared_filesystem_storage.AccessItem, key: rule.id, rule: rule, handleDeleteRule: @handleDeleteRule, shareId: @state.share.id, ajax: @props.ajax     
            
                tr null,
                  td colSpan: 4, 
                    ReactCSSTransitionGroup  transitionName: "css-transition-fade", transitionEnterTimeout: 500, transitionLeaveTimeout: 300,
                      if @state.showForm
                        React.createElement shared_filesystem_storage.AccessForm, shareId: @state.share.id, ajax: @props.ajax, handleCreateRule: @handleCreateRule,                             
                  td null,
                    if @state.showForm
                      a className: 'btn btn-default btn-sm', href: '#', onClick: @toggleForm, 
                        i className: 'fa fa-close'
                    else    
                      a className: 'btn btn-primary btn-sm', href: '#', onClick: @toggleForm, 
                        i className: 'fa fa-plus'  
        else
          div null,
            span className: 'spinner', null
            'Loading...'  
      
      div className: 'modal-footer',
        button role: 'close', type: 'button', className: 'btn btn-default', onClick: @close, 'Close'