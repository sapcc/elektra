#= require components/form_helpers
#= require components/transition_groups

{ div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateSecurityServiceForm, submitSecurityServiceForm } = shared_filesystem_storage

# type
# name
# description
# dns_ip
# user
# password
# domain
# server

NewSecurityService = ({
  close,
  securityServiceForm,
  handleSubmit,
  handleChange
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  securityService = securityServiceForm.data
  form className: 'form form-horizontal', onSubmit: handleSubmit,
    div className: 'modal-body',
      if securityServiceForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: securityServiceForm.errors

      # Type
      div className: "form-group select required security_service_type",
        label className: "select required col-sm-4 control-label", htmlFor: "security_service_type",
          abbr title: "required", '*'
          'Type'
        div className: "col-sm-8",
          div className: "input-wrapper",
            select name: "protocol", className: "select required form-control", name: 'type', value: (securityService.type || ''), onChange: onChange,
              for type,typeLabel of {'active_directory': 'Active Directory'}
                option value: type, key: type, typeLabel

      # Organizational Unit
      div { className: "form-group string required security_service_ou" },
        label { className: "string required col-sm-4 control-label", htmlFor: "security_service_ou" },
          abbr title: "required", '*'
          'OU (Organizational Unit)'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input { className: "string required form-control", type: "text", name: "ou", value: (securityService.ou || ''), onChange: onChange }

      # Name
      div { className: "form-group string required security_service_name" },
        label { className: "string required col-sm-4 control-label", htmlFor: "security_service_name" },
          abbr title: "required", '*'
          'Name'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input { className: "string required form-control", type: "text", name: "name", value: (securityService.name || ''), onChange: onChange }

      # Description
      div { className: "form-group text optional security_service_description" },
        label { className: "text optional col-sm-4 control-label", htmlFor: "security_service_description" }, "Description"
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            textarea { className: "text optional form-control", name: "description", value: (securityService.description || ''), onChange: onChange }

      # DNS IP
      div { className: "form-group string  security_service_dns_ip" },
        label { className: "string  col-sm-4 control-label", htmlFor: "security_service_dns_ip" }, 'DNS IP'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input { className: "string required form-control", type: "text", name: "dns_ip", value: (securityService.dns_ip || ''), onChange: onChange }
          p className: "help-block",
            i className: "fa fa-info-circle"
            "Please provide an IP (ipv4) of your AD's DNS"
      # User
      div { className: "form-group string  security_service_user" },
        label { className: "string  col-sm-4 control-label", htmlFor: "security_service_user" }, 'User'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input { className: "string required form-control", type: "text", name: "user", value: (securityService.user || ''), onChange: onChange }

      # Password
      ReactTransitionGroups.Fade null,
        if securityService.user and securityService.user.trim().length>0
          div { className: "form-group string  security_service_password" },
            label { className: "string  col-sm-4 control-label", htmlFor: "security_service_password" }, 'Password'
            div { className: "col-sm-8" },
              div { className: "input-wrapper" },
                input { className: "string required form-control", type: "text", name: "password", value: (securityService.password || ''), onChange: onChange }

      # Domain
      div { className: "form-group string  security_service_domain" },
        label { className: "string  col-sm-4 control-label", htmlFor: "security_service_domain" }, 'Domain'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input { className: "string required form-control", type: "text", name: "domain", value: (securityService.domain || ''), onChange: onChange }

      # Server
      div { className: "form-group string  security_service_server" },
        label { className: "string  col-sm-4 control-label", htmlFor: "security_service_server" }, 'Server'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input { className: "string required form-control", type: "text", name: "server", value: (securityService.server || ''), onChange: onChange }

    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Create',
        loading: securityServiceForm.isSubmitting,
        disabled: !securityServiceForm.isValid
        onSubmit: (() -> handleSubmit(close))

NewSecurityService = connect(
  (state) ->
    securityServiceForm: state.securityServiceForm
  (dispatch) ->
    handleChange: (name,value) -> dispatch(updateSecurityServiceForm(name,value))
    handleSubmit: (callback) -> dispatch(submitSecurityServiceForm(callback))
)(NewSecurityService)

shared_filesystem_storage.NewSecurityServiceModal = ReactModal.Wrapper('Create SecurityService', NewSecurityService,
  large:true,
  closeButton: false,
  static: true
)
