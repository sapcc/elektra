{ div, span, br, button, a, table, tbody, thead, tr, th, td } = React.DOM

ShowSecurityService = ({securityService,close}) ->
  div null,
    div className: 'modal-body',
      table className: 'table no-borders',
        unless securityService.permissions.get
          tbody null,
            tr null,
              th null, "Type"
              td null, securityService.type
            tr null,
              th null, "Name"
              td null, securityService.name
            tr null,
              th null, "ID"
              td null, securityService.id
            tr null,
              th null, "Status"
              td null, securityService.status
        else
          tbody null,
            tr null,
              th null, "Type"
              td null, securityService.type
            tr null,
              th null, "OU (Organizational Unit)"
              td null, securityService.ou  
            tr null,
              th null, "Name"
              td null, securityService.name
            tr null,
              th null, "ID"
              td null, securityService.id
            tr null,
              th null, "Status"
              td null, securityService.status
            tr null,
              th null, "Description"
              td null, securityService.description
            tr null,
              th null, "DNS IP"
              td null, securityService.dns_ip
            tr null,
              th null, "User"
              td null, securityService.user
            tr null,
              th null, "Password"
              td null, securityService.password
            tr null,
              th null, 'Domain'
              td null, securityService.domain
            tr null,
              th null, 'Server'
              td null, securityService.server
            tr null,
              th null, 'Created At'
              td null, securityService.created_at
            tr null,
              th null, 'Updated At'
              td null, securityService.updated_at

    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'

shared_filesystem_storage.ShowSecurityServiceModal = ReactModal.Wrapper('SecurityService Details', ShowSecurityService, large:true)
