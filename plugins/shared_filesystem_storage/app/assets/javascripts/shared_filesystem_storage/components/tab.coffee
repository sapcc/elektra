shared_filesystem_storage.Tab = React.createClass
  handleClick: (event) ->
    event.preventDefault()
    @props.onSelect @props.uid
  
  render: () ->
    {li,a} = React.DOM
    
    li { className: (if @props.active then 'active' else null) },
      a { href: "#" + @props.uid, onClick: this.handleClick }, @props.label