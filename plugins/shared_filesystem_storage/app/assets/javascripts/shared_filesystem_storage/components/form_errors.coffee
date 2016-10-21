{div,ul,li} = React.DOM
shared_filesystem_storage.FormErrors = React.createClass
  
  render: ->
    if @props.errors
      div className: 'alert alert-error', 
        ul null,
          for error,messages of @props.errors
            for message in messages
              li null, "#{error}: #{message}"
    else
      div null          