{div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a,ul,li} = React.DOM

shared_filesystem_storage.ShareForm = React.createClass
  statics:
    protocols: ['NFS','CIFS','GlusterFS','HDFS']
      
  getInitialState: ->
    valid: false
    share: @props.share || {}

  componentWillReceiveProps: (nextProps) ->
    @setState share: nextProps.share || {}

  # valid if name, network and subnetwork are given
  validate: ->
    @props.share.share_proto && @props.share.size && @props.share.share_network_id

  handleSubmit: (e) ->
    e.preventDefault()
    return unless @state.valid
    @props.handleSubmit(@state.share)
    
  handleChange: (e) ->
    name = e.target.name
    share = @state.share
    share["#{ name }"] = e.target.value
    @setState share: share, () => @setState valid: @validate()


  handleClickNewShareNetwork: (e) ->
    e.preventDefault()
    @props.handleClickNewShareNetwork()
    
  render: ->
    { Modal } = shared_filesystem_storage

    form className: 'form form-horizontal', onSubmit: @handleSubmit,
      div className: 'modal-body',
        React.createElement shared_filesystem_storage.FormErrors, errors:@props.errors
                    
        # Name
        div { className: "form-group string  share_name" },
          label { className: "string  col-sm-4 control-label", htmlFor: "share_name" }, 'Name'
          div { className: "col-sm-8" },
            div { className: "input-wrapper" },
              input { className: "string required form-control", type: "text", name: "name", value: (@state.share.name || ''), onChange: @handleChange }

        # Description
        div { className: "form-group text optional share_description" },
          label { className: "text optional col-sm-4 control-label", htmlFor: "share_description" }, "Description"
          div { className: "col-sm-8" },
            div { className: "input-wrapper" },
              textarea { className: "text optional form-control", name: "description", value: (@state.share.description || ''), onChange: @handleChange }

        # Protocol
        div { className: "form-group select required share_protocol" },
          label { className: "select required col-sm-4 control-label", htmlFor: "share_protocol" },
            abbr { title: "required" }, '*'
            'Protocol'
          div { className: "col-sm-8" },
            div { className: "input-wrapper"},
              select { name: "protocol", className: "select required form-control", name: 'share_proto', value: (@state.share.share_proto || ''), onChange: @handleChange },
                option null, ' '
                  for protocol in shared_filesystem_storage.ShareForm.protocols
                    option { value: protocol, key: protocol }, protocol

        # Size
        div { className: "form-group required text optional share_size" },
          label { className: "text required optional col-sm-4 control-label", htmlFor: "share_size" }, 
            abbr { title: "required" }, '*'
            "Size (GiB)"
          div { className: "col-sm-8" },
            div { className: "input-wrapper" },
              input { className: "integer required optional form-control", type: 'number', name: "size", value: (@state.share.size || ''), onChange: @handleChange }
        #
        # # Types
        # div { className: "form-group select required share_type" },
        #   label { className: "select required col-sm-4 control-label", htmlFor: "share_type" },
        #     abbr { title: "required" }, '*'
        #     'Type'
        #   div { className: "col-sm-8" },
        #     div { className: "input-wrapper"},
        #       if @props.share_types
        #         select { name: "type", className: "select required form-control", value: (@props.share.type || ''), onChange: @handleChange },
        #           option null, ' '
        #             for type in @props.share_types
        #               option { value: type.id, key: type.id }, type.name
        #       else
        #         span null,
        #           span {className: 'spinner'}, null
        #           'Loading...'
        
        
        # Share networks
        div { className: "form-group required select share_share_network" },
          label { className: "select required col-sm-4 control-label", htmlFor: "share_share_network" }, 
            abbr { title: "required" }, '*'
            'Share Network'
          div { className: "col-sm-8" },
            div { className: "input-wrapper"},
              if @props.shareNetworks
                div null,
                  select { name: "share_network_id", className: "required select form-control", value: (@props.share.share_network_id || ''), onChange: @handleChange },
                    option null, ' '
                      for shareNetwork in @props.shareNetworks
                        option { value: shareNetwork.id, key: shareNetwork.id }, shareNetwork.name
                  if @props.shareNetworks.length==0
                    p className:'help-block',
                      i className: "fa fa-info-circle"   
                      'There are no share networks defined yet. '        
                      a onClick: @handleClickNewShareNetwork, href: '#', 'Create a new share network.'
              else
                span null,
                  span {className: 'spinner'}, null
                  'Loading...'  
                          
        # # Availability Zone
        # div { className: "form-group select  share_availability_zone" },
        #   label { className: "select col-sm-4 control-label", htmlFor: "share_availability_zone" }, 'Availability Zone'
        #   div { className: "col-sm-8" },
        #     div { className: "input-wrapper"},
        #       if @props.availability_zones
        #         select { name: "availability_zone", className: "select form-control", value: (@props.share.availability_zone || ''), onChange: @handleChange },
        #           option null, ' '
        #             for availability_zone in @props.availability_zones
        #               option { value: availability_zone.zoneName, key: availability_zone.zoneName }, availability_zone.zoneName
        #       else
        #         span null,
        #           span {className: 'spinner'}, null
        #           'Loading...'
                  
        div className: "form-group boolean optional hare_is_public",
          div className: "col-sm-offset-4 col-sm-8",
            div className: "checkbox",
              label className: "boolean optional", htmlFor: "share_is_public",
                input className: "boolean optional col-sm-8", type: "checkbox", value: @props.share.is_public, name:"is_public", onChange: @handleChange
                'Is public'   
              p className: 'help-block',
                i className: "fa fa-info-circle"
                'If set then all tenants will be able to see this share.'
                    
      div className: 'modal-footer',
        button role: 'cancel', type: 'button', className: 'btn btn-default', onClick: @props.handleCancel, 'Cancel'
        React.createElement Modal.SubmitButton, label: @props.buttonLabel, loading: @props.loading, disabled: !@state.valid


            