#= require_tree .

{ combineReducers } = Redux

((app) ->
  app.AppReducers = combineReducers({
    activeTab:            app.activeTab,
    modals:               ReactModal.Reducer,
    shares:               app.shares,
    shareRules:           app.shareRules,
    shareForm:            app.shareForm,
    shareRuleForm:        app.shareRuleForm,
    shareNetworks:        app.shareNetworks,
    shareNetworkForm:     app.shareNetworkForm,
    snapshots:            app.snapshots,
    snapshotForm:         app.snapshotForm,
    networks:             app.networks,
    subnets:              app.subnets,
    availabilityZones:    app.availabilityZones,
    securityServices:     app.securityServices,
    securityServiceForm:  app.securityServiceForm
  })
)(shared_filesystem_storage)
