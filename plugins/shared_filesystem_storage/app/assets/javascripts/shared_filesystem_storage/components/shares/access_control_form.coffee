{ div,form,select,input, option,span,button, label, table, tbody, tr, td, i, p } = React.DOM
{ connect } = ReactRedux
{ updateShareRuleForm, submitShareRuleForm } = shared_filesystem_storage

AccessControlForm = ({ruleForm, shareNetwork, handleSubmit, handleChange}) ->
  rule = ruleForm.data

  onChange=(e) ->
    handleChange(e.target.name,e.target.value)

  accessTypes =
    ip: 'ip'
    # user: 'user'
    # cert: 'cert'
  accessLevels =
    ro: 'read-only'
    rw: 'read-write'

  accessToPlaceholder = switch rule.access_type
    when "ip" then 'IP address'
    when "user" then 'User or group name'
    when "cert" then 'TLS certificate'
    else 'Access to'

  accessToInfo = switch rule.access_type
    when "ip" then 'A valid format is XX.XX.XX.XX or XX.XX.XX.XX/XX. For example 0.0.0.0/0.'
    when "user" then 'A valid value is an alphanumeric string that can contain some special characters and is from 4 to 32 characters long.'
    when "cert" then 'Specify the TLS identity as the IDENTKEY. A valid value is any string up to 64 characters long in the common name (CN) of the certificate. The meaning of a string depends on its interpretation. '
    else null

  form className: "form-inline", onSubmit: ((e) -> e.preventDefault(); handleSubmit()),
    if shareNetwork
      div null, "Network: #{shareNetwork.cidr}"

    if ruleForm.errors
      div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: ruleForm.errors
    div className: "form-group",
      label className: 'sr-only', htmlFor: "access_type", 'Access Type'
      select name: "access_type", className: "select required form-control", onChange: onChange,
        option value: '', 'Select Access Type'
        for accessType, typeLabel of accessTypes
          option { value: accessType, key: accessType }, typeLabel
    div className: 'form-group',
      label className: 'sr-only', htmlFor: "access_to", 'Access To'
      input
        type: 'text',
        className: 'form-control',
        placeholder: accessToPlaceholder,
        name: 'access_to',
        value: rule.access_to || '',
        onChange: onChange

    div className: 'form-group',
      label className: 'sr-only', htmlFor: "access_level", 'Access Level'
      select { name: "access_level", className: "select required form-control", onChange: onChange },
        option value: '', 'Select Access Level'
        for accessLevel, levelLabel of accessLevels
          option { value: accessLevel, key: accessLevel }, levelLabel
    div className: 'form-group',
      button
        type: 'submit',
        className: 'btn btn-primary',
        disabled: !ruleForm.isValid or ruleForm.isSubmitting, if ruleForm.isSubmitting then 'Please wait...' else 'Add'

    if accessToInfo
      p className:'help-block',
        i className: "fa fa-info-circle"
        accessToInfo

shared_filesystem_storage.AccessControlForm = AccessControlForm
