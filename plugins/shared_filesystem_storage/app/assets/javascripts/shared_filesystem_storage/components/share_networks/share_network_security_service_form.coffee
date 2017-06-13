{ div,form,select,input, option,span,button, label, table, tbody, tr, td, i, p } = React.DOM
{ connect } = ReactRedux
{ updateShareNetworkSecurityServiceForm, submitShareNetworkSecurityServiceForm } = shared_filesystem_storage

ShareNetworkSecurityServiceForm = ({shareNetworkSecurityServiceForm, securityServices, shareNetworkSecurityServices, availableSecurityServices, shareNetwork, handleSubmit, handleChange}) ->
  onChange=(e) ->
    handleChange(e.target.name,e.target.value)

  form className: "form-inline", onSubmit: ((e) -> e.preventDefault(); handleSubmit()),
    if shareNetwork
      div null, "Network: #{shareNetwork.cidr}"

    if shareNetworkSecurityServiceForm.errors
      div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: shareNetworkSecurityServiceForm.errors

    div className: "form-group",
      label className: 'sr-only', htmlFor: "access_type", 'Security Service'
      select name: "id", className: "select required form-control", onChange: onChange,
        option value: '', 'Select Security Service'
        for securityService in availableSecurityServices
          option { value: securityService.id, key: securityService.id }, "#{securityService.name} (#{securityService.type})"

    div className: 'form-group',
      button
        type: 'submit',
        className: 'btn btn-primary',
        disabled: !shareNetworkSecurityServiceForm.isValid or shareNetworkSecurityServiceForm.isSubmitting, if shareNetworkSecurityServiceForm.isSubmitting then 'Please wait...' else 'Add'

shared_filesystem_storage.ShareNetworkSecurityServiceForm = ShareNetworkSecurityServiceForm
