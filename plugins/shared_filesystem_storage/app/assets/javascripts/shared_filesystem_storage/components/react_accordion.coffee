{div,h4,a} = React.DOM

shared_filesystem_storage.ReactAccordion = React.createClass
  getDefaultProps: ->
    className: 'smooth-accordion'
    
  render: ->
    div className: "panel-group #{@props.className}", role: "tablist", "aria-multiselectable": true, @props.children
    
shared_filesystem_storage.ReactAccordion.Panel = React.createClass
  render: ->
    id = @props.title.replace(/\s/g,'-').toLowerCase()
    
    div className: "panel",
      div className: "panel-heading", role: "tab",
        h4 className: "panel-title",
          a role: "button", "data-toggle": "collapse", className: ("collapsed" unless @props.active), href: "##{id}", @props.title
      div id: id, className: "panel-collapse collapse #{'in' if @props.active}", role: "tabpanel", "aria-labelledby": "headingOne",
        div className: "panel-body", @props.children
          