shared_filesystem_storage.Panel = React.createClass
  getInitialState: () -> 
    shown: false
  
  # Set shown state to true if current tab is activated. 
  # The content of this panel is loaded only once when the tab is clicked for the first time.
  componentDidMount: () -> @setShownState()
  componentDidUpdate: (nextProps, nextState) -> @setShownState() 
  setShownState: -> @setState shown: true if !@state.shown and @props.active
      
  render: ->
    React.DOM.div
      role: 'tabpanel'
      className: "tab-pane#{(if @props.active then ' active' else '')}"
      if @state.shown #render panel only if current tab is active
        React.createElement eval('shared_filesystem_storage.'+@props.contentClass), @props
