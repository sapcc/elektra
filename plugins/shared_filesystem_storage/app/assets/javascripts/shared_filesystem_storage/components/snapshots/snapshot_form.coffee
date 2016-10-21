{div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a,ul,li} = React.DOM

shared_filesystem_storage.SnapshotForm = React.createClass
  statics:
    protocols: ['NFS','CIFS','GlusterFS','HDFS']
      
  getInitialState: ->
    valid: false
    snapshot: @props.snapshot || {}

  componentWillReceiveProps: (nextProps) ->
    @setState snapshot: nextProps.snapshot || {}

  # valid if name, network and subnetwork are given
  validate: ->
    @props.snapshot.share_id

  handleSubmit: (e) ->
    e.preventDefault()
    return unless @state.valid
    @props.handleSubmit(@state.snapshot)
    
  handleChange: (e) ->
    name = e.target.name
    snapshot = @state.snapshot
    snapshot["#{ name }"] = e.target.value
    @setState snapshot: snapshot, () => @setState valid: @validate()


  handleClickNewShareNetwork: (e) ->
    e.preventDefault()
    @props.handleClickNewShareNetwork()
    
  render: ->
    { Modal } = shared_filesystem_storage

    form className: 'form form-horizontal', onSubmit: @handleSubmit,
      div className: 'modal-body',
        React.createElement shared_filesystem_storage.FormErrors, errors:@props.errors

        # Name
        div { className: "form-group string  snapshot_name" },
          label { className: "string  col-sm-4 control-label", htmlFor: "snapshot_name" }, 'Name'
          div { className: "col-sm-8" },
            div { className: "input-wrapper" },
              input { className: "string required form-control", type: "text", name: "name", value: (@state.snapshot.name || ''), onChange: @handleChange }

        # Description
        div { className: "form-group text optional snapshot_description" },
          label { className: "text optional col-sm-4 control-label", htmlFor: "snapshot_description" }, "Description"
          div { className: "col-sm-8" },
            div { className: "input-wrapper" },
              textarea { className: "text optional form-control", name: "description", value: (@state.snapshot.description || ''), onChange: @handleChange }
             
      div className: 'modal-footer',
        button role: 'cancel', type: 'button', className: 'btn btn-default', onClick: @props.handleCancel, 'Cancel'
        React.createElement Modal.SubmitButton, label: @props.buttonLabel, loading: @props.loading, disabled: !@state.valid         