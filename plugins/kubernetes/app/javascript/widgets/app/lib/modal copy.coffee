import "./helpers.coffee"

import { connect } from "react-redux"

ReactModal = {
  SHOW_MODAL: 'SHOW_MODAL'
  HIDE_MODAL: 'HIDE_MODAL'
  HIDE_ALL: 'HIDE_ALL'
}

addModalUrlFragment=({modalType,modalProps})->
  overlayParams = "&modal=#{modalType}"
  overlayParams += "&#{k}=#{v}" for k,v of modalProps
  if window.location.hash.indexOf('&modal')>=0
    window.location.hash.replace(/&modal.*/,overlayParams)
  else
    window.location.hash += overlayParams

removeModalUrlFragment=({modalType,modalProps})->
  window.location.hash = window.location.hash.replace(/&modal.*/g,'')


Modal = () => {
  elementRef = React.useRef()

  React.useEffect(() => {
    if(!elementRef.current) return 
    $(elementRef.current).modal 'show'
    $(elementRef.current).on 'hidden.bs.modal', @handleClose
    return () => $(elementRef.current).modal 'hide'
  },[elementRef.current])

  close: (e, callback) ->
    e.preventDefault() if e
    # bug in react. Instead of one parameter the onClick callback provides
    # two parameters. The first is a Proxy object (don't know what it is).
    # Deactivate the callback feature until fixed.
    # $(@refs.modal).on('hidden.bs.modal', callback) if callback
    if(!elementRef.current) return
    $(elementRef.current).modal 'hide'

  handleClose: () ->
    if @props.dispatch
      @props.dispatch(type: ReactModal.HIDE_MODAL, modalType: @props.modalType)

  render: ->
    options = ReactHelpers.mergeObjects({closeButton: true},options)
    modalProps = (@props.modalProps || {})
    childProps = ReactHelpers.mergeObjects(@props,{close: @close})
    delete(childProps.modalProps)
    childProps = ReactHelpers.mergeObjects(childProps,modalProps)

    React.createElement 'div', 
      className:"modal fade",
      "data-backdrop": (if options.static==true then 'static' else true),
      tabIndex: "-1",
      ref: 'modal',
      role: "dialog",
      "aria-labelledby": "myModalLabel",
      React.createElement 'div',  className: "modal-dialog #{'modal-lg' if options.large} #{'modal-xl' if options.xlarge}", role: "document",
        React.createElement 'div',  className: "modal-content",
          React.createElement 'div',  className: "modal-header",
            if options.closeButton
              React.createElement 'button',  type: "button", className: "close", "data-dismiss": "modal", "aria-label": "Close",
                React.createElement 'span',   "aria-hidden": "true", 'x'
            React.createElement 'h4',  className: "modal-title", title
          React.createElement WrappedComponent, childProps 
}

ReactModal.Wrapper = (title, WrappedComponent, options = {}) ->
  connect((state) -> state)(
    class Modal extends React.Component 
      componentDidMount: ->
        $(@refs.modal).modal 'show'
        $(@refs.modal).on 'hidden.bs.modal', @handleClose

      componentWillUnmount: ->

      close: (e, callback) ->
        e.preventDefault() if e
        # bug in react. Instead of one parameter the onClick callback provides
        # two parameters. The first is a Proxy object (don't know what it is).
        # Deactivate the callback feature until fixed.
        # $(@refs.modal).on('hidden.bs.modal', callback) if callback
        $(@refs.modal).modal 'hide'

      handleClose: () ->
        if @props.dispatch
          @props.dispatch(type: ReactModal.HIDE_MODAL, modalType: @props.modalType)

      render: ->
        options = ReactHelpers.mergeObjects({closeButton: true},options)
        modalProps = (@props.modalProps || {})
        childProps = ReactHelpers.mergeObjects(@props,{close: @close})
        delete(childProps.modalProps)
        childProps = ReactHelpers.mergeObjects(childProps,modalProps)

        React.createElement 'div', 
          className:"modal fade",
          "data-backdrop": (if options.static==true then 'static' else true),
          tabIndex: "-1",
          ref: 'modal',
          role: "dialog",
          "aria-labelledby": "myModalLabel",
          React.createElement 'div',  className: "modal-dialog #{'modal-lg' if options.large} #{'modal-xl' if options.xlarge}", role: "document",
            React.createElement 'div',  className: "modal-content",
              React.createElement 'div',  className: "modal-header",
                if options.closeButton
                  React.createElement 'button',  type: "button", className: "close", "data-dismiss": "modal", "aria-label": "Close",
                    React.createElement 'span',   "aria-hidden": "true", 'x'
                React.createElement 'h4',  className: "modal-title", title
              React.createElement WrappedComponent, childProps 
  )

ReactModal.Reducer  = (state = [], action) ->
  switch action.type
    when ReactModal.SHOW_MODAL
      contains = false
      for m in state
        if m.modalType==action.modalType
          contains = true
          break

      return state if contains
      newState = state.slice()
      newState.push
        modalType: action.modalType,
        modalProps: action.modalProps

      #addModalUrlFragment(action)
      newState

    when ReactModal.HIDE_MODAL
      newState = state.slice()
      for m,i in state
        if m.modalType==action.modalType
          newState.splice(i,1)

      #removeModalUrlFragment(action)
      newState
    when ReactModal.HIDE_ALL
      []
    else
      return state

ReactModal.Container = (reducerName,componentsMap) ->
  ModalRoot = ({ modals }) ->
    return null unless (modals and modals.length)
    React.createElement 'div',  null,
      for modal in modals
        if modal.modalType and componentsMap[modal.modalType]
          React.createElement componentsMap[modal.modalType],
            key: modal.modalType,
            modalType: modal.modalType,
            modalProps: modal.modalProps

  ModalRoot = connect(
    (state) -> modals: state[reducerName]
  )(ModalRoot)

window.ReactModal = ReactModal
