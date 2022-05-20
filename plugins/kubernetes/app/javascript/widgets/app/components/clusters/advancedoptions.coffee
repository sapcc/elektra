import { connect } from "react-redux"
import "../../lib/form_helpers.coffee"
import { updateAdvancedOptions, changeVersion} from "../../actions/clusters.coffee"


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

  React.createElement 'div', null,
    if !metaData.loaded || metaData.error?
      if metaData.error? && metaData.errorCount > 20
        React.createElement 'div', className: 'alert alert-warning',
          "We couldn't retrieve the advanced options at this time, please try again later"
      else
        React.createElement 'div', className: 'u-clearfix',
          React.createElement 'div', className: 'pull-right',
            'Loading options '
            React.createElement 'span', className: 'spinner'

    else
      selectedRouterIndex     = ReactHelpers.findIndexInArray(metaData.routers,options.routerID, 'id')
      selectedRouter          = metaData.routers[selectedRouterIndex]
      if selectedRouter?
        selectedNetworkIndex  = ReactHelpers.findIndexInArray(selectedRouter.networks,options.networkID, 'id')
        selectedNetwork       = selectedRouter.networks[selectedNetworkIndex]

      React.createElement 'div', null,
        if metaData.securityGroups?
          # SecurityGroups
          React.createElement 'div', null,
            React.createElement 'div', className: "form-group required string",
              React.createElement 'label', className: "string required col-sm-4 control-label", htmlFor: "securityGroupName",
                React.createElement 'abbr', title: "required", '*'
                ' Security Group'
              React.createElement 'div', className: "col-sm-8",
                React.createElement 'div', className: "input-wrapper",
                  React.createElement 'select',
                    name: "securityGroupName",
                    className: "select required form-control",
                    value: (options.securityGroupName || ''),
                    disabled: ('disabled' if metaData.securityGroups.length == 1),
                    onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                        for securityGroup, i in metaData.securityGroups
                          React.createElement 'option', value: securityGroup.name, key: i, securityGroup.name



        if metaData.routers? # TODO: Think about how to do this in the edit case if metadata empty or incomplete but there is a value set in the cluster spec, probably just display id without name

          # Router
          React.createElement 'div', className: "form-group required string" ,
            React.createElement 'label', className: "string required col-sm-4 control-label", htmlFor: "routerID",
              React.createElement 'abbr', title: "required", '*'
              ' Router'
            React.createElement 'div', className: "col-sm-8",
              React.createElement 'div', className: "input-wrapper",
                React.createElement 'select',
                  name: "routerID",
                  className: "select required form-control",
                  value: (options.routerID || ''),
                  disabled: ('disabled' if metaData.routers.length == 1 || edit),
                  onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                      for router, i in metaData.routers
                        React.createElement 'option', value: router.id, key: i, router.name

        # Network
        if options.routerID? && selectedRouter? && selectedRouter.networks?
          React.createElement 'div', className: "form-group required string" ,
            React.createElement 'label', className: "string required col-sm-4 control-label", htmlFor: "networkID",
              React.createElement 'abbr', title: "required", '*'
              ' Network'
            React.createElement 'div', className: "col-sm-8",
              React.createElement 'div', className: "input-wrapper",
                React.createElement 'select',
                  name: "networkID",
                  className: "select required form-control",
                  value: (options.networkID || ''),
                  disabled: ('disabled' if selectedRouter.networks.length == 1 || edit),
                  onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                      for network, i in selectedRouter.networks
                        React.createElement 'option', value: network.id, key: i, network.name


        # Subnet
        if options.lbSubnetID? && selectedNetwork? && selectedNetwork.subnets?
          React.createElement 'div', className: "form-group required string" ,
            React.createElement 'label', className: "string required col-sm-4 control-label", htmlFor: "subnetID",
              React.createElement 'abbr', title: "required", '*'
              ' Subnet'
            React.createElement 'div', className: "col-sm-8",
              React.createElement 'div', className: "input-wrapper",
                React.createElement 'select',
                  name: "lbSubnetID",
                  className: "select required form-control",
                  value: (options.lbSubnetID || ''),
                  disabled: ('disabled' if selectedNetwork.subnets.length == 1 || edit),
                  onChange: ((e) -> handleChange(e.target.name, e.target.value)),

                      for subnet, i in selectedNetwork.subnets
                        React.createElement 'option', value: subnet.id, key: i, subnet.name


    React.createElement 'div', className: "form-group required string" ,
      React.createElement 'label', className: "string col-sm-4 control-label", htmlFor: "securityGroupName",
        ' Kubernetes Version'
      React.createElement 'div', className: "col-sm-8",
        if !info.loaded
          React.createElement 'div', className: 'u-clearfix',
          React.createElement 'div', className: 'pull-right',
            'Loading versions '
            React.createElement 'span', className: 'spinner'
        else
          React.createElement 'div', className: "input-wrapper",
            React.createElement 'select',
              name: "version",
              className: "select form-control",
              value: (spec.version || cluster.status.apiserverVersion || info.defaultClusterVersion),
              onChange: ((e) -> handleVersionChange(e.target.value)),

                  for version in availableVersions(cluster.status.apiserverVersion)
                    React.createElement 'option', value: version, key: version, version

AdvancedOptions = connect(
  (state) ->
    clusterForm:  state.clusterForm
    metaData:     state.metaData
    info:         state.info

  (dispatch) ->
    handleChange:         (name, value) ->  dispatch(updateAdvancedOptions(name, value))
    handleVersionChange:  (value) ->        dispatch(changeVersion(value))
)(AdvancedOptions)

export default AdvancedOptions
