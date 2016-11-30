{div,form,input,textarea,h4,label,span,button,abbr,select,option} = React.DOM

shared_filesystem_storage.ShareNetworkForm = React.createClass
  # valid if name, network and subnetwork are given
  valid: ->
    @props.shareNetwork.name && @props.shareNetwork.neutron_net_id && @props.shareNetwork.neutron_subnet_id

  handleChange: (e) ->
    e.preventDefault()
    @props.handleChange(e.target.name, e.target.value)
    
  handleSubmit: (e) ->
    e.preventDefault()
    @props.handleSubmit()  
    
  render: ->
    { Modal } = shared_filesystem_storage
    
    form className: 'form form-horizontal', onSubmit: @handleSubmit,
      div className: 'modal-body',
        React.createElement shared_filesystem_storage.FormErrors, errors:@props.errors
        
        # Name
        div { className: "form-group string required shareNetwork_name" },
          label { className: "string required col-sm-4 control-label", htmlFor: "shareNetwork_name" },
            abbr { title: "required" }, "*"
            'Name'
          div { className: "col-sm-8" },
            div { className: "input-wrapper" },
              input { className: "string required form-control", type: "text", name: "name", value: (@props.shareNetwork.name || ''), onChange: @handleChange }

        # Description
        div { className: "form-group text optional shareNetwork_description" },
          label { className: "text optional col-sm-4 control-label", htmlFor: "shareNetwork_description" }, "Description"
          div { className: "col-sm-8" },
            div { className: "input-wrapper" },
              textarea { className: "text optional form-control", name: "description", value: (@props.shareNetwork.description || ''), onChange: @handleChange }

        if @props.mode=='create'            
          # Networks
          div { className: "form-group select required neutron_net_id" },
            label { className: "select required col-sm-4 control-label", htmlFor: "neutron_net_id" },
              abbr { title: "required" }, '*'
              'Neutron Net'
            div { className: "col-sm-8" },
              div { className: "input-wrapper"},
                if @props.networks
                  select { name: "neutron_net_id", className: "select required form-control", value: (@props.shareNetwork.neutron_net_id || ''), onChange: @handleChange },
                    option null, ' '
                      for network in @props.networks
                        option { value: network.id, key: network.id }, network.name
                else
                  span null,
                    span {className: 'spinner'}, null
                    'Loading...'


        if @props.mode=='create' and @props.shareNetwork.neutron_net_id
          subnets = @props.subnets[@props.shareNetwork.neutron_net_id]
          unless subnets
            @props.loadSubnets(@props.shareNetwork.neutron_net_id)

          div { className: "form-group select required neutron_subnet_id" },
            label { className: "select required col-sm-4 control-label", htmlFor: "neutron_subnet_id" },
              abbr { title: "required" }, '*'
              'Neutron Subnet'
            div { className: "col-sm-8" },
              div { className: "input-wrapper"},
                if subnets
                  select { name: "neutron_subnet_id", className: "select required form-control", value: (@props.shareNetwork.neutron_subnet_id || ''), onChange: @handleChange },
                    option null, ' '
                    for subnet in subnets
                      option { value: subnet.id, key: subnet.id }, subnet.name
                else
                  span null,
                    span {className: 'spinner'}, null
                    'Loading...'

      div className: 'modal-footer',
        button role: 'cancel', type: 'button', className: 'btn btn-default', onClick: @props.handleCancel, 'Cancel'
        React.createElement Modal.SubmitButton, label: @props.buttonLabel, loading: @props.loading, disabled: !@valid()