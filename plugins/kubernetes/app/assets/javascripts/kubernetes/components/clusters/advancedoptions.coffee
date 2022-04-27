#= require components/form_helpers


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,optgroup,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateAdvancedOptions, changeVersion} = kubernetes


AdvancedOptions = ({
  clusterForm,
  metaData,
  info,
  handleChange,
  handleVersionChange,
  edit


}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  isValidVersion= (currentVersion, newVersion) ->
    # if we are not in the edit case there are no rules for which versions are valid, we get the acceptable ones from info.supportedClusterVersions
    return true if !edit
    
    currentNumbers = currentVersion.split('.').map((n) -> Math.trunc(n))
    newNumbers = newVersion.split('.').map((n) -> Math.trunc(n))

    # ensure that major version matches and that new minor version is either equal or exactly 1 greater than current minor version
    newNumbers[0] == currentNumbers[0] && 
    (newNumbers[1] == currentNumbers[1] || newNumbers[1] == currentNumbers[1] + 1)


  # available versions are different for edit and new case. Filter versions so that only valid versions as per the rules are left
  availableVersions= (currentVersion) ->
    versions = if edit then info.availableClusterVersions else info.supportedClusterVersions
    versions.filter((v) -> isValidVersion(currentVersion, v))



  cluster  = clusterForm.data
  spec     = cluster.spec
  options  = cluster.spec.openstack

  div null,
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
              label className: "string required col-sm-4 control-label", htmlFor: "securityGroupName",
                abbr title: "required", '*'
                ' Security Group'
              div className: "col-sm-8",
                div className: "input-wrapper",
                  select
                    name: "securityGroupName",
                    className: "select required form-control",
                    value: (options.securityGroupName || ''),
                    disabled: ('disabled' if metaData.securityGroups.length == 1),
                    onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                        for securityGroup in metaData.securityGroups
                          option value: securityGroup.name, key: securityGroup.id, securityGroup.name



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
        if options.routerID? && selectedRouter? && selectedRouter.networks?
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
        if options.lbSubnetID? && selectedNetwork? && selectedNetwork.subnets?
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


    div className: "form-group required string" ,
      label className: "string col-sm-4 control-label", htmlFor: "securityGroupName",
        ' Kubernetes Version'
      div className: "col-sm-8",
        if !info.loaded
          div className: 'u-clearfix',
          div className: 'pull-right',
            'Loading versions '
            span className: 'spinner'
        else
          div className: "input-wrapper",
            select
              name: "version",
              className: "select form-control",
              value: (spec.version || cluster.status.apiserverVersion || info.defaultClusterVersion),
              onChange: ((e) -> handleVersionChange(e.target.value)),

                  for version in availableVersions(cluster.status.apiserverVersion)
                    option value: version, key: version, version
    





AdvancedOptions = connect(
  (state) ->
    clusterForm:  state.clusterForm
    metaData:     state.metaData
    info:         state.info

  (dispatch) ->
    handleChange:         (name, value) ->  dispatch(updateAdvancedOptions(name, value))
    handleVersionChange:  (value) ->        dispatch(changeVersion(value))



)(AdvancedOptions)

kubernetes.AdvancedOptions = AdvancedOptions
