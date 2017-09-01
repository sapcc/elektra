#= require shared_filesystem_storage/components/share_networks/share_network_security_service_form
#= require shared_filesystem_storage/components/share_networks/share_network_security_service
#= require components/transition_groups

{ div,table,thead,tbody,tr,th,td,form,select,h4,label,span,input,button,abbr,select,option,a,i,small } = React.DOM
{ connect } = ReactRedux
{
  updateShareNetworkSecurityServiceForm,
  submitShareNetworkSecurityServiceForm,
  hideShareNetworkSecurityServiceForm,
  showShareNetworkSecurityServiceForm,
  deleteShareNetworkSecurityService,
  ShareNetworkSecurityServiceForm,
  ShareNetworkSecurityServiceItem,
  fetchShareNetworkSecurityServicesIfNeeded,
  shareNetworkSecurityServiceFormForCreate
} = shared_filesystem_storage

ShareNetworkSecurityServices = React.createClass
  componentDidMount: ->
    @props.loadShareNetworkSecurityServicesOnce(@props.shareNetwork.id)

  availableSecurityServices:() ->
    securityServices = [] unless @props.securityServices
    assignedSecurityServices = @props.shareNetworkSecurityServices.items || []
    assignedSecurityServicesIds = []
    assignedSecurityServicesTypes = []
    for securityService in assignedSecurityServices
      assignedSecurityServicesIds.push(securityService.id)
      assignedSecurityServicesTypes.push(securityService.type)
    available = []
    for securityService in @props.securityServices
      if assignedSecurityServicesIds.indexOf(securityService.id)<0 and assignedSecurityServicesTypes.indexOf(securityService.type)<0
        available.push(securityService)
    available

  render: ->
    {
      shareNetworkId,
      shareNetwork,
      isFetching,
      shareNetworkSecurityServices,
      securityServices,
      close,
      handleChange,
      handleSubmit,
      handleDelete,
      hideForm,
      showForm,
      shareNetworkSecurityServiceForm,
      loadShareNetworkSecurityServicesOnce
    } = @props

    availableSecurityServices = @availableSecurityServices()
    div null,
      div className: 'modal-body',
        if shareNetworkSecurityServices.isFetching
          div null,
            span className: 'spinner', null
            'Loading...'
        else
          table { className: 'table share-network-security-services' },
            thead null,
              tr null,
                th null, 'Name'
                th null, 'ID'
                th null, 'Type'
                th null, 'Status'
                th className: 'snug'
            tbody null,
              if shareNetworkSecurityServices.items.length==0
                tr null,
                  td colSpan: 5, 'No Security Service found.'
              else
                for securityService in shareNetworkSecurityServices.items
                  React.createElement ShareNetworkSecurityServiceItem, key: securityService.id, securityService: securityService, shareNetwork: shareNetwork, handleDelete: handleDelete


              if availableSecurityServices.length>0
                tr null,
                  td colSpan: 4,
                    ReactTransitionGroups.Fade null,
                      unless shareNetworkSecurityServiceForm.isHidden
                        React.createElement ShareNetworkSecurityServiceForm, { securityServices, shareNetworkSecurityServices, handleChange, handleSubmit, shareNetworkSecurityServiceForm, availableSecurityServices }
                  td null,

                    unless shareNetworkSecurityServiceForm.isHidden
                      a
                        className: 'btn btn-default btn-sm',
                        href: '#',
                        onClick: ((e) -> e.preventDefault(); hideForm()),
                        i className: 'fa fa-close'
                    else
                      a
                        className: 'btn btn-primary btn-sm',
                        href: '#',
                        onClick: ((e) -> e.preventDefault(); showForm(shareNetworkId)),
                        i className: 'fa fa-plus'

      div className: 'modal-footer',
        button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'

ShareNetworkSecurityServices = connect(
  (state,ownProps) ->
    securityServices: state.securityServices.items
    shareNetworkSecurityServices: (state.shareNetworkSecurityServices[ownProps.shareNetworkId] || {items: [], isFetching: false})
    shareNetwork: state.shareNetworks.items.find((n) -> n.id==ownProps.shareNetworkId)
    shareNetworkSecurityServiceForm: state.shareNetworkSecurityServiceForm
  (dispatch,ownProps) ->
    loadShareNetworkSecurityServicesOnce: (shareNetworkId) -> dispatch(fetchShareNetworkSecurityServicesIfNeeded(shareNetworkId))
    handleChange: (name,value) -> dispatch(updateShareNetworkSecurityServiceForm(name,value))
    handleSubmit: -> dispatch(submitShareNetworkSecurityServiceForm(ownProps.shareNetworkId))
    handleDelete: (securityServiceId) -> dispatch(deleteShareNetworkSecurityService(ownProps.shareNetworkId,securityServiceId))
    hideForm: -> dispatch(hideShareNetworkSecurityServiceForm())
    showForm: (shareNetworkId) ->
      dispatch(shareNetworkSecurityServiceFormForCreate(shareNetworkId))
      dispatch(showShareNetworkSecurityServiceForm())
)(ShareNetworkSecurityServices)
shared_filesystem_storage.ShareNetworkSecurityServices = ReactModal.Wrapper('Share Network Security Service', ShareNetworkSecurityServices,
  large:true
)
