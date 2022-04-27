#= require ./helpers

{ div, ul, li, button} = React.DOM

ReactFormHelpers = {}

################# ERRORS RENDERR #################
ReactFormHelpers.Errors = ({errors}) ->
  if typeof errors == 'object'
    ul null,
      for error,messages of errors
        for message in messages
          li null, "#{error}: #{message}"
  else if typeof errors == 'string'
    errors
  else
    null

##################### SUBMIT BUTTON #######################
ReactFormHelpers.SubmitButton = (options={}) ->
  options = ReactHelpers.mergeObjects({
    type: 'submit'
    className: 'btn-primary'
    label: 'Save'
    disable_with: 'Please wait...'
    loading: false
    disabled: true
    onSubmit: () -> null
  },options)

  button
    type: "submit",
    onClick: ((e) -> e.preventDefault(); options.onSubmit()),
    className: "btn #{options.className}",
    disabled: if (options.loading or options.disabled) then true else false
    if options.loading then options.disable_with else options.label

########################## FORM REDUCER #########################
# ReactFormHelpers.FormReducer =
#   initialShareFormState:
#     method: 'post'
#     action: ''
#     data: {}
#     isSubmitting: false
#     errors: null
#     isValid: false
#
#   resetForm: (action,{})->
#     ReactFormHelpers.FormReducer.initialShareFormState
#
#   updateForm: (state,{name,value,validateFunc})->
#     data = ReactHelpers.mergeObjects({},state.data,{"#{name}":value})
#     ReactHelpers.mergeObjects({},state,{
#       data:data
#       errors: null
#       isSubmitting: false
#       isValid: validateFunc(data)
#     })
#
#   submitForm: (state,{})->
#     ReactHelpers.mergeObjects({},state,{
#       isSubmitting: true
#       errors: null
#     })
#
#   prepareForm: (state,{action,method,data})->
#     values =
#       method: method
#       action: action
#       errors: null
#     values['data']=data if data
#     ReactHelpers.mergeObjects({},initialShareFormState,values)
#
#   formFailure: (state,{errors})->
#     ReactHelpers.mergeObjects({},state,{
#       isSubmitting: false
#       errors: errors
#     })

@ReactFormHelpers = ReactFormHelpers
