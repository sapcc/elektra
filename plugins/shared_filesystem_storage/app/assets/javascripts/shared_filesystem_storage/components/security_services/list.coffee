#= require shared_filesystem_storage/components/security_services/item

{ connect } = ReactRedux
{ div, table, thead, tbody, tr, th, td, span, button } = React.DOM
{
  SecurityServiceItem,
  fetchSecurityServicesIfNeeded,
  openNewSecurityServiceDialog,
  openDeleteSecurityServiceDialog,
  openShowSecurityServiceDialog,
  openEditSecurityServiceDialog
} = shared_filesystem_storage

SecurityServiceList = React.createClass
  componentDidMount: ->
    @props.loadSecurityServicesOnce() if @props.active

  componentWillReceiveProps: (nextProps) ->
    @props.loadSecurityServicesOnce() if nextProps.active

  render: ->
    div null,
      if @props.permissions.create
        div className: 'toolbar',
          button
            type: "button",
            className: "btn btn-primary",
            onClick: ((e) => e.preventDefault(); @props.handleNewSecurityService()),
            'Create new'

      if @props.isFetching
        div null,
          span className: 'spinner', null
          'Loading...'
      else
        table {className: 'table security-services'},
          thead null,
            tr null,
              th null, 'Name'
              th null, 'Type'
              th null, 'Status'
              th null, ''
          tbody null,
            if @props.securityServices.length==0
              tr null,
                td { colSpan: 5 }, 'No Security Service found.'
            for securityService in @props.securityServices
              React.createElement SecurityServiceItem,
                key: securityService.id,
                securityService: securityService
                handleShow: @props.handleShow
                handleDelete: @props.handleDelete
                handleEdit: @props.handleEdit

SecurityServiceList = connect(
  (state) ->
    securityServices: state.securityServices.items
    isFetching: state.securityServices.isFetching
  (dispatch) ->
    loadSecurityServicesOnce: () -> dispatch(fetchSecurityServicesIfNeeded())
    handleNewSecurityService: () -> dispatch(openNewSecurityServiceDialog())
    handleShow: (securityService) -> dispatch(openShowSecurityServiceDialog(securityService))
    handleDelete: (securityServiceId) -> dispatch(openDeleteSecurityServiceDialog(securityServiceId))
    handleEdit: (securityService) -> dispatch(openEditSecurityServiceDialog(securityService))
)(SecurityServiceList)

shared_filesystem_storage.SecurityServiceList = SecurityServiceList
