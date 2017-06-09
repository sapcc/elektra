#= require shared_filesystem_storage/components/shares/list
#= require shared_filesystem_storage/components/share_networks/list
#= require shared_filesystem_storage/components/snapshots/list
#= require shared_filesystem_storage/components/shares/show
#= require shared_filesystem_storage/components/shares/new
#= require shared_filesystem_storage/components/shares/edit
#= require shared_filesystem_storage/components/shares/access_control
#= require shared_filesystem_storage/components/security_services/list
#= require shared_filesystem_storage/components/security_services/show
#= require shared_filesystem_storage/components/security_services/new
#= require shared_filesystem_storage/components/security_services/edit
#= require shared_filesystem_storage/components/snapshots/edit
#= require shared_filesystem_storage/components/snapshots/new
#= require shared_filesystem_storage/components/snapshots/show
#= require shared_filesystem_storage/components/share_networks/new
#= require shared_filesystem_storage/components/share_networks/edit
#= require shared_filesystem_storage/components/share_networks/show
#= require shared_filesystem_storage/components/share_networks/share_network_security_services
#= require react/dialogs

{ div } = React.DOM
{ connect } = ReactRedux
{
  selectTab,
  setCurrentTabToUrl,
  ShareList,
  SnapshotList,
  ShareNetworkList,
  SecurityServiceList,
  ShowShareModal,
  EditShareModal,
  NewShareModal,
  ShowSecurityServiceModal,
  EditSecurityServiceModal,
  NewSecurityServiceModal,
  EditSnapshotModal,
  NewSnapshotModal,
  ShowSnapshotModal,
  ShareAccessControl,
  NewShareNetworkModal,
  EditShareNetworkModal,
  ShowShareNetworkModal,
  ShareNetworkSecurityServices
} = shared_filesystem_storage

tabs = [
  { name: 'Shares', uid: 'shares', permissionKey: 'shares', component: ShareList },
  { name: 'Snapshots', uid: 'snapshots', permissionKey: 'snapshots', component: SnapshotList}
  { name: 'Share Networks', uid: 'share-networks', permissionKey: 'share_networks', component: ShareNetworkList}
  { name: 'Security Services', uid: 'security-services', permissionKey: 'security_services', component: SecurityServiceList}
]

modalComponents =
  'SHOW_SHARE': ShowShareModal
  'NEW_SHARE': NewShareModal
  'EDIT_SHARE': EditShareModal
  'SHOW_SECURITY_SERVICE': ShowSecurityServiceModal
  'NEW_SECURITY_SERVICE': NewSecurityServiceModal
  'EDIT_SECURITY_SERVICE': EditSecurityServiceModal
  'SHARE_ACCESS_CONTROL': ShareAccessControl
  'SHARE_NETWORK_SECURITY_SERVICES': ShareNetworkSecurityServices
  'EDIT_SNAPSHOT': EditSnapshotModal
  'NEW_SNAPSHOT': NewSnapshotModal
  'SHOW_SNAPSHOT': ShowSnapshotModal
  'NEW_SHARE_NETWORK': NewShareNetworkModal
  'EDIT_SHARE_NETWORK': EditShareNetworkModal
  'SHOW_SHARE_NETWORK': ShowShareNetworkModal
  'CONFIRM': ReactConfirmDialog
  'INFO': ReactInfoDialog
  'ERROR': ReactErrorDialog

App = ({activeTabUid, selectTab, permissions}) ->
  return null unless (tabs and tabs.length)

  activeTabUid = tabs[0].uid if !activeTabUid or activeTabUid.trim().length==0
  tabsConfig = []
  for tab in tabs
    if permissions[tab.permissionKey].list
      tabsConfig.push(
        name: tab.name,
        uid: tab.uid,
        content: React.createElement tab.component, permissions: permissions[tab.permissionKey], active: activeTabUid==tab.uid
      )

  div null,
    React.createElement ReactTabs, tabsConfig: tabsConfig, activeTabUid: activeTabUid, onSelect: selectTab
    React.createElement ReactModal.Container('modals',modalComponents)

App = connect(
  (state) -> activeTabUid: state.activeTab.uid,
  (dispatch) -> selectTab: (uid) ->
    dispatch(selectTab(uid))
    setCurrentTabToUrl(uid)
)(App)

shared_filesystem_storage.App = App
