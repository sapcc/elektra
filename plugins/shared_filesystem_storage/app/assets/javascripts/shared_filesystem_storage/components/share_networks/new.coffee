#= require react/form_helpers

{ div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateShareNetworkForm, submitShareNetworkForm } = shared_filesystem_storage

NewShareNetwork = ({
  close,
  shareNetworkForm,
  networks,
  subnets,
  loadSubnets,
  handleSubmit,
  handleChange
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  shareNetwork = shareNetworkForm.data
  if shareNetwork.neutron_net_id and !subnets
    loadSubnets(shareNetwork.neutron_net_id)

  form className: 'form form-horizontal', onSubmit: ((e) -> e.preventDefault(); handleSubmit()),
    div className: 'modal-body',
      if shareNetworkForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: shareNetworkForm.errors

      # Name
      div { className: "form-group string required shareNetwork_name" },
        label { className: "string required col-sm-4 control-label", htmlFor: "shareNetwork_name" },
          abbr { title: "required" }, "*"
          'Name'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input
              className: "string required form-control",
              type: "text",
              name: "name",
              value: (shareNetwork.name || ''),
              onChange: onChange

      # Description
      div { className: "form-group text optional shareNetwork_description" },
        label { className: "text optional col-sm-4 control-label", htmlFor: "shareNetwork_description" }, "Description"
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            textarea
              className: "text optional form-control",
              name: "description",
              value: (shareNetwork.description || ''),
              onChange: onChange

      # Networks
      div { className: "form-group select required neutron_net_id" },
        label { className: "select required col-sm-4 control-label", htmlFor: "neutron_net_id" },
          abbr { title: "required" }, '*'
          'Neutron Net'
        div { className: "col-sm-8" },
          div { className: "input-wrapper"},
            if networks.isFetching
              span null,
                span {className: 'spinner'}, null
                'Loading...'
            else
              select
                name: "neutron_net_id",
                className: "select required form-control",
                value: (shareNetwork.neutron_net_id || ''),
                onChange: onChange,
                option null, ' '
                  for network in networks.items
                    option { value: network.id, key: network.id }, network.name


      if subnets
        div { className: "form-group select required neutron_subnet_id" },
          label { className: "select required col-sm-4 control-label", htmlFor: "neutron_subnet_id" },
            abbr { title: "required" }, '*'
            'Neutron Subnet'
          div { className: "col-sm-8" },
            div { className: "input-wrapper"},
              if subnets.isFetching
                span null,
                  span {className: 'spinner'}, null
                  'Loading...'
              else
                select
                  name: "neutron_subnet_id",
                  className: "select required form-control",
                  value: (shareNetwork.neutron_subnet_id || ''),
                  onChange: onChange,
                  option null, ' '
                  for subnet in subnets.items
                    option { value: subnet.id, key: subnet.id }, subnet.name

    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Create',
        loading: shareNetworkForm.isSubmitting,
        disabled: !shareNetworkForm.isValid
        onSubmit: (() -> handleSubmit(close))

NewShareNetwork = connect(
  (state) ->
    shareNetworkForm: state.shareNetworkForm
    networks: state.networks
    subnets: state.subnets[state.shareNetworkForm.data.neutron_net_id]
  (dispatch) ->
    handleChange: (name,value) -> dispatch(updateShareNetworkForm(name,value))
    handleSubmit: (callback) -> dispatch(submitShareNetworkForm(callback))
    loadSubnets: (neutronNetworkId) -> dispatch(fetchNetworkSubnetsIfNeeded(neutronNetworkId))
)(NewShareNetwork)

shared_filesystem_storage.NewShareNetworkModal = ReactModal.Wrapper('Create Share Network', NewShareNetwork,
  large:true,
  closeButton: false,
  static: true
)
