#= require components/form_helpers


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateAdvancedOptions} = kubernetes


AdvancedOptions = ({
  clusterForm,
  metaData,
  handleChange,
  edit


}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)


  cluster  = clusterForm.data
  options  = cluster.spec.openstack


  if !metaData.loaded || metaData.error?
    if metaData.error? && metaData.errorCount > 20
      div className: 'alert alert-warning',
        "We couldn't retrieve the advanced options at this time, please try again later"
    else
      div className: 'u-clearfix',
        div className: 'pull-right',
          'Loading options '
          span className: 'spinner'

  else
    selectedRouterIndex     = ReactHelpers.findIndexInArray(metaData.routers,options.routerID, 'id')
    selectedRouter          = metaData.routers[selectedRouterIndex]
    if selectedRouter?
      selectedNetworkIndex  = ReactHelpers.findIndexInArray(selectedRouter.networks,options.networkID, 'id')
      selectedNetwork       = selectedRouter.networks[selectedNetworkIndex]

    div null,
      if metaData.securityGroups?
        # SecurityGroups
        div null,
          div className: "form-group required string" ,
            label className: "string required col-sm-4 control-label", htmlFor: "securityGroupID",
              abbr title: "required", '*'
              ' Security Group'
            div className: "col-sm-8",
              div className: "input-wrapper",
                select
                  name: "securityGroupID",
                  className: "select required form-control",
                  value: (options.securityGroupID || ''),
                  disabled: ('disabled' if metaData.securityGroups.length == 1),
                  onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                      for securityGroup in metaData.securityGroups
                        option value: securityGroup.id, key: securityGroup.id, securityGroup.name

      if metaData.keyPairs?
        # Keypair
        div null,
          div className: "form-group required string" ,
            label className: "string required col-sm-4 control-label", htmlFor: "keyPair",
              abbr title: "required", '*'
              ' Keypair'
            div className: "col-sm-8",
              div className: "input-wrapper",
                select
                  name: "keyPair",
                  className: "select required form-control",
                  value: (options.keyPair || ''),
                  disabled: ('disabled' if metaData.keyPairs.length == 1),
                  onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                      for keyPair in metaData.keyPairs
                        option value: keyPair.name, key: keyPair.name, keyPair.name



      if metaData.routers? # TODO: Think about how to do this in the edit case if metadata empty or incomplete but there is a value set in the cluster spec, probably just display id without name

        # Router
        div className: "form-group required string" ,
          label className: "string required col-sm-4 control-label", htmlFor: "routerID",
            abbr title: "required", '*'
            ' Router'
          div className: "col-sm-8",
            div className: "input-wrapper",
              select
                name: "routerID",
                className: "select required form-control",
                value: (options.routerID || ''),
                disabled: ('disabled' if metaData.routers.length == 1 || edit),
                onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                    for router in metaData.routers
                      option value: router.id, key: router.id, router.name

      # Network
      if options.routerID? && selectedRouter.networks?
        div className: "form-group required string" ,
          label className: "string required col-sm-4 control-label", htmlFor: "networkID",
            abbr title: "required", '*'
            ' Network'
          div className: "col-sm-8",
            div className: "input-wrapper",
              select
                name: "networkID",
                className: "select required form-control",
                value: (options.networkID || ''),
                disabled: ('disabled' if selectedRouter.networks.length == 1 || edit),
                onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                    for network in selectedRouter.networks
                      option value: network.id, key: network.id, network.name


      # Subnet
      if options.lbSubnetID? && selectedNetwork.subnets?
        div className: "form-group required string" ,
          label className: "string required col-sm-4 control-label", htmlFor: "subnetID",
            abbr title: "required", '*'
            ' Subnet'
          div className: "col-sm-8",
            div className: "input-wrapper",
              select
                name: "lbSubnetID",
                className: "select required form-control",
                value: (options.lbSubnetID || ''),
                disabled: ('disabled' if selectedNetwork.subnets.length == 1 || edit),
                onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                    for subnet in selectedNetwork.subnets
                      option value: subnet.id, key: subnet.id, subnet.name





AdvancedOptions = connect(
  (state) ->
    clusterForm:  state.clusterForm
    metaData:     state.metaData

  (dispatch) ->
    handleChange: (name, value) -> dispatch(updateAdvancedOptions(name, value))


)(AdvancedOptions)

kubernetes.AdvancedOptions = AdvancedOptions
