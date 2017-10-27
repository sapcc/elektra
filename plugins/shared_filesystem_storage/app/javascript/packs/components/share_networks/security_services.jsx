import SecurityServiceItem from './security_service';

export default class ShareNetworkSecurityServices extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {};
  }

  componentDidMount() {
    return this.props.loadShareNetworkSecurityServicesOnce(this.props.shareNetwork.id);
  }

  availableSecurityServices() {
    let securityServices;
    if (!this.props.securityServices) { securityServices = []; }
    const assignedSecurityServices = this.props.shareNetworkSecurityServices.items || [];
    const assignedSecurityServicesIds = [];
    const assignedSecurityServicesTypes = [];
    for (let securityService of assignedSecurityServices) {
      assignedSecurityServicesIds.push(securityService.id);
      assignedSecurityServicesTypes.push(securityService.type);
    }
    const available = [];
    for (let securityService of this.props.securityServices) {
      if ( assignedSecurityServicesIds.indexOf(securityService.id)<0 && assignedSecurityServicesTypes.indexOf(securityService.type)<0) {
        available.push(securityService);
      }
    }
    return available;
  }

  render() {
    const {
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
    } = this.props;

    const availableSecurityServices = this.availableSecurityServices();

    return (
      div(null,
      div({className: 'modal-body'},
        shareNetworkSecurityServices.isFetching ?
          div(null,
            span({className: 'spinner'}, null),
            'Loading...')
        :
          table({ className: 'table share-network-security-services' },
            thead(null,
              tr(null,
                th(null, 'Name'),
                th(null, 'ID'),
                th(null, 'Type'),
                th(null, 'Status'),
                th({className: 'snug'}))
            ),
            tbody(null,
              shareNetworkSecurityServices.items.length===0 ?
                tr(null,
                  td({colSpan: 5}, 'No Security Service found.'))
              :
                Array.from(shareNetworkSecurityServices.items).map((securityService) =>
                  React.createElement(ShareNetworkSecurityServiceItem, {key: securityService.id, securityService, shareNetwork, handleDelete})),


              availableSecurityServices.length>0 ?
                tr(null,
                  td({colSpan: 4},
                    ReactTransitionGroups.Fade(null,
                      !shareNetworkSecurityServiceForm.isHidden ?
                        React.createElement(ShareNetworkSecurityServiceForm, { securityServices, shareNetworkSecurityServices, handleChange, handleSubmit, shareNetworkSecurityServiceForm, availableSecurityServices }) : undefined)),
                  td(null,

                    !shareNetworkSecurityServiceForm.isHidden ?
                      a({
                        className: 'btn btn-default btn-sm',
                        href: '#',
                        onClick(e) { e.preventDefault(); return hideForm(); }
                      },
                        i({className: 'fa fa-close'}))
                    :
                      a({
                        className: 'btn btn-primary btn-sm',
                        href: '#',
                        onClick(e) { e.preventDefault(); return showForm(shareNetworkId); }
                      },
                        i({className: 'fa fa-plus'}))
                  )
                ) : undefined
            )
          )
      ),

      div({className: 'modal-footer'},
        button({role: 'close', type: 'button', className: 'btn btn-default', onClick: close}, 'Close'))
    );
}
