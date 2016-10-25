{ div,form,select,input, option,span,button, label, table, tbody, tr, td, i, p } = React.DOM

shared_filesystem_storage.AccessForm = React.createClass
  statics:
    accessTypes: 
      ip: 'ip'
      user: 'user'
      cert: 'cert'
    accessLevels: 
      ro: 'read-only'
      rw: 'read-write'
      
  getInitialState: ->
    errors: null
    loading: false
    access_type: ''
    access_to: ''
    access_level: ''
    
  accessToPlaceholder: () ->
    switch @state.access_type
      when "ip" then 'IP address'
      when "user" then 'User or group name'
      when "cert" then 'TLS certificate'
      else 'Access to'
  
  accessToInfo: () ->
    switch @state.access_type
      when "ip" then 'A valid format is XX.XX.XX.XX or XX.XX.XX.XX/XX. For example 0.0.0.0/0.'
      when "user" then 'A valid value is an alphanumeric string that can contain some special characters and is from 4 to 32 characters long.'
      when "cert" then 'Specify the TLS identity as the IDENTKEY. A valid value is any string up to 64 characters long in the common name (CN) of the certificate. The meaning of a string depends on its interpretation. '
      else null      
      
  handleSubmit: (e) ->
    e.preventDefault()
    @setState loading: true
    @props.ajax.post "shares/#{@props.shareId}/rules",
      data: 
        rule: 
          access_type: @state.access_type 
          access_level: @state.access_level 
          access_to: @state.access_to
           
      success: (data, textStatus, jqXHR) =>
        @props.handleCreateRule(data)
        @setState @getInitialState()
      error: ( jqXHR, textStatus, errorThrown)  =>
        @setState errors: jqXHR.responseJSON
      complete: () =>
        @setState loading: false
  
  valid: ->
    @state.access_type && @state.access_level && @state.access_to

  handleChange: (e) ->
    name = e.target.name
    @setState "#{name}": e.target.value
    
  render: ->
    infoText = @accessToInfo()  
    form className: "form-inline", onSubmit: @handleSubmit,
      React.createElement shared_filesystem_storage.FormErrors, errors: @state.errors
      div className: "form-group",
        label className: 'sr-only', htmlFor: "access_type", 'Access Type'
        select name: "access_type", className: "select required form-control", onChange: @handleChange ,
          option value: '', 'Select Access Type'
          for accessType, typeLabel of shared_filesystem_storage.AccessForm.accessTypes
            option { value: accessType, key: accessType }, typeLabel
      div className: 'form-group', 
        label className: 'sr-only', htmlFor: "access_to", 'Access To'
        input type: 'text', className: 'form-control', placeholder: @accessToPlaceholder(), name: 'access_to', value: @state.access_to, onChange: @handleChange
      div className: 'form-group',  
        label className: 'sr-only', htmlFor: "access_level", 'Access Level'
        select { name: "access_level", className: "select required form-control", onChange: @handleChange },
          option value: '', 'Select Access Level'
          for accessLevel, levelLabel of shared_filesystem_storage.AccessForm.accessLevels
            option { value: accessLevel, key: accessLevel }, levelLabel
      div className: 'form-group', 
        button type: 'submit', className: 'btn btn-primary', disabled: !@valid(), if @state.loading then 'Please wait...' else 'Add' 
      
      if infoText 
        p className:'help-block',
          i className: "fa fa-info-circle"   
          infoText  