#= require react/form_helpers

{ div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateShareForm, submitShareForm, selectTab, openNewShareNetworkDialog } = shared_filesystem_storage
protocols= ['NFS','CIFS']

NewShare = ({
  close,
  shareForm,
  shareNetworks,
  availabilityZones,
  handleSubmit,
  handleChange,
  handleNewShareNetwork
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  share = shareForm.data
  form className: 'form form-horizontal', onSubmit: ((e) -> e.preventDefault(); handleSubmit()),
    div className: 'modal-body',
      if shareForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: shareForm.errors

      # Name
      div className: "form-group string  share_name" ,
        label className: "string  col-sm-4 control-label", htmlFor: "share_name", 'Name'
        div className: "col-sm-8",
          div className: "input-wrapper",
            input
              className: "string required form-control",
              type: "text",
              name: "name",
              value: share.name || '',
              onChange: onChange

      # Description
      div className: "form-group text optional share_description",
        label className: "text optional col-sm-4 control-label", htmlFor: "share_description", "Description"
        div className: "col-sm-8",
          div className: "input-wrapper",
            textarea
              className: "text optional form-control",
              name: "description",
              value: (share.description || ''),
              onChange: onChange

      # Protocol
      div className: "form-group select required share_protocol",
        label className: "select required col-sm-4 control-label", htmlFor: "share_protocol",
          abbr title: "required", '*'
          'Protocol'
        div className: "col-sm-8",
          div className: "input-wrapper",
            select name: "protocol", className: "select required form-control", name: 'share_proto', value: (share.share_proto || ''), onChange: onChange,
              option null, ' '
                for protocol in protocols
                  option value: protocol, key: protocol, protocol

      # Size
      div className: "form-group required text optional share_size",
        label className: "text required optional col-sm-4 control-label", htmlFor: "share_size",
          abbr title: "required", '*'
          "Size (GiB)"
        div className: "col-sm-8",
          div className: "input-wrapper",
            input
              className: "integer required optional form-control",
              type: 'number',
              name: "size",
              value: (share.size || ''),
              onChange: onChange

      # availability_zones
      div className: "form-group  select share_az",
        label className: "select  col-sm-4 control-label", htmlFor: "share_az",
          'Availability Zone'
        div className: "col-sm-8",
          div className: "input-wrapper",
            if availabilityZones.isFetching
              span null,
                span className: 'spinner', null
                'Loading...'
            else
              div null,
                select name: "availability_zone", className: "required select form-control", value: (share.availability_zone || ''), onChange: onChange,
                  option null, ' '
                    for az in availabilityZones.items
                      option value: az.id, key: az.id, az.name
                if availabilityZones.items.length==0
                  p className:'help-block',
                    i className: "fa fa-info-circle"
                    'No availability zones available.'

      # Share networks
      div className: "form-group required select share_share_network",
        label className: "select required col-sm-4 control-label", htmlFor: "share_share_network",
          abbr title: "required", '*'
          'Share Network'
        div className: "col-sm-8",
          div className: "input-wrapper",
            if shareNetworks.isFetching
              span null,
                span className: 'spinner', null
                'Loading...'
            else
              div null,
                select name: "share_network_id", className: "required select form-control", value: (share.share_network_id || ''), onChange: onChange,
                  option null, ' '
                    for shareNetwork in shareNetworks.items
                      option value: shareNetwork.id, key: shareNetwork.id, shareNetwork.name
                if shareNetworks.items.length==0
                  p className:'help-block',
                    i className: "fa fa-info-circle"
                    'There are no share networks defined yet. '
                    a onClick: ((e) -> handleNewShareNetwork(e)), href: '#', 'Create a new share network.'

    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Create',
        loading: shareForm.isSubmitting,
        disabled: !shareForm.isValid
        onSubmit: (() -> handleSubmit(close))

NewShare = connect(
  (state) ->
    shareForm: state.shareForm
    shareNetworks: state.shareNetworks
    availabilityZones: state.availabilityZones
  (dispatch,ownProps) ->
    handleChange: (name,value) -> dispatch(updateShareForm(name,value))
    handleSubmit: (callback) -> dispatch(submitShareForm(callback))
    handleNewShareNetwork: (e) ->
      ownProps.close e, () -> dispatch(selectTab("share-networks"))
)(NewShare)

shared_filesystem_storage.NewShareModal = ReactModal.Wrapper('Create Share', NewShare,
  large:true,
  closeButton: false,
  static: true
)
