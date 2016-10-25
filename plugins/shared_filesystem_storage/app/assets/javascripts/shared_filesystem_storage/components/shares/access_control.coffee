{ div,table,thead,tbody,tr,th,td,form,select,h4,label,span,input,button,abbr,select,option,a,i } = React.DOM
 
ReactCSSTransitionGroup = React.createFactory React.addons.CSSTransitionGroup
 
shared_filesystem_storage.AccessControl = React.createClass 

  getInitialState: () ->
    shareId: null
    showForm: false
      
  open: (shareId) -> 
    @setState shareId: shareId
    @refs.modal.open()
    
  close: () -> @refs.modal.close()
  handleClose: () -> @setState @getInitialState()
  
  toggleForm: (e) ->
    e.preventDefault()
    @setState showForm: !@state.showForm
    
  handleDeleteRule: (rule) ->
    @props.handleDeleteRule(@state.shareId, rule)
  
  handleCreateRule: (rule) ->
    @setState showForm: false
    @props.handleCreateRule(@state.shareId, rule)  
          
  render: ->
    { Modal, ShareForm } = shared_filesystem_storage
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'Access Control'
      
      div className: 'modal-body', 
        if @state.shareId && @props.shareRules[@state.shareId]
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
                if @props.shareRules[@state.shareId].length==0
                  tr null,
                    td colSpan: 5, 'No Rules found.'
                else    
                  for rule in @props.shareRules[@state.shareId]
                    React.createElement shared_filesystem_storage.AccessItem, key: rule.id, rule: rule, handleDeleteRule: @handleDeleteRule, shareId: @state.shareId, ajax: @props.ajax     
            
                tr null,
                  td colSpan: 4, 
                    ReactCSSTransitionGroup  transitionName: "css-transition-fade", transitionEnterTimeout: 500, transitionLeaveTimeout: 300,
                      if @state.showForm
                        React.createElement shared_filesystem_storage.AccessForm, shareId: @state.shareId, ajax: @props.ajax, handleCreateRule: @handleCreateRule,                             
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
        null      