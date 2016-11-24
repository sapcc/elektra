{ div,form,textarea,b,table,tbody,tr,th,td,h4,h3,label,span,button,abbr,select,option,ul,li,a } = React.DOM
{ ReactAccordion} = shared_filesystem_storage
 
shared_filesystem_storage.ShowShareNetwork = React.createClass 
  getInitialState: ->
    shareNetwork: null
    
  open: (shareNetwork) -> 
    @refs.modal.open()
    @setState shareNetwork: shareNetwork
    @props.loadSubnets(@state.shareNetwork.neutron_net_id) unless @props.subnets[@state.shareNetwork.neutron_net_id]   
    
  close: () -> @refs.modal.close()
  handleClose: () -> null
      
  neutronNetwork: ->
    if @props.networks and @props.networks.length>0
      for network in @props.networks 
        if network.id==@state.shareNetwork.neutron_net_id  
          return network
    return null
         
  neutronSubnet: () ->
    if @props.subnets[@state.shareNetwork.neutron_net_id] 
      for subnet in @props.subnets[@state.shareNetwork.neutron_net_id]
        if subnet.id==@state.shareNetwork.neutron_subnet_id        
          return subnet
    return null
            
  render: ->
    React.createElement shared_filesystem_storage.Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'Share Network'
      
      if @state.shareNetwork
        network = @neutronNetwork()
        subnet = @neutronSubnet()
        
        div className: 'modal-body',
          React.createElement ReactAccordion, null,
            React.createElement ReactAccordion.Panel, title: 'Overview', active: true,
              table className: 'table',
                tbody null,
                  tr null,
                    th style: {width: '30%'}, 'Name'
                    td null, @state.shareNetwork.name
                  tr null,
                    th null, 'ID'
                    td null, @state.shareNetwork.id  
                  tr null,
                    th null, 'Description'
                    td null, @state.shareNetwork.description 
                  tr null,
                    th null, 'Cidr'
                    td null, @state.shareNetwork.cidr
                  tr null,
                    th null, 'IP Version'
                    td null, @state.shareNetwork.ip_version
                  tr null,
                    th null, 'Network Type'
                    td null, @state.shareNetwork.network_type
                  tr null,
                    th null, 'Neutron Network ID'
                    td null, @state.shareNetwork.neutron_net_id
                  tr null,
                    th null, 'Neutron Subnet ID'
                    td null, @state.shareNetwork.neutron_subnet_id
                  tr null,
                    th null, 'Project ID'
                    td null, @state.shareNetwork.project_id              
                  
            
            if network                      
              React.createElement ReactAccordion.Panel, title: 'Neutron Network', active: false,
                table className: 'table',
                  tbody null,
                    tr null,
                      th style: {width: '30%'}, 'Name'
                      td null, network.name
                    tr null,
                      th null, 'ID'
                      td null, network.id  
                    tr null,
                      th null, 'Description'
                      td null, network.description 
                    tr null,
                      th null, 'Shared'
                      td null, if network.shared then 'Yes' else 'No'
                    tr null,
                      th null, 'Status'
                      td null, network.status

            if subnet
              React.createElement ReactAccordion.Panel, title: 'Neutron Subnet', active: false,
                table className: 'table',
                  tbody null,
                    tr null,
                      th style: {width: '30%'}, 'Name'
                      td null, subnet.name
                    tr null,
                      th null, 'ID'
                      td null, subnet.id  
                    tr null,
                      th null, 'Description'
                      td null, subnet.description 
                    tr null,
                      th null, 'Cidr'
                      td null, subnet.cidr
                    tr null,
                      th null, 'Gateway IP'
                      td null, subnet.gateway_ip
                    tr null,
                      th null, 'IP Version'
                      td null, subnet.ip_version  
                    tr null,
                      th null, 'Network ID'
                      td null, subnet.network_id                      
                      

      div className: 'modal-footer',
        button role: 'close', type: 'button', className: 'btn btn-default', onClick: @close, 'Close'
        
        