import { FormComponent } from '../components/form';
import { connect } from  'react-redux';

import { FormReducers } from '../reducers';
import { FormActions } from '../actions';
import { replaceOrAddReducers } from 'store';

export const FormContainer = connect(
  (state,ownProps) => {
    let form = state.forms[ownProps.name]
    let validateFunc = ownProps.valid
    let isValid = true
    if (validateFunc) {
      isValid = validateFunc(form.values) ? true : false
    }
    return {
      isSubmitting: form.isSubmitting,
      isValid,
      values: form.values,
      errors: form.errors
    }
  },

  (dispatch,ownProps) => {
    let formActions = FormActions(ownProps.name)
    let onSubmitFunc = ownProps.onSubmit
    return {
      onChange: (key,value) => dispatch(formActions.update(key,value)),
      onFailure: (errors) => dispatch(formActions.failure(errors)),
      onSubmit: (values) => {
        dispatch(formActions.submit())
        onSubmitFunc(values, {
          handleSuccess: () => dispatch(formActions.reset()),
          handleErrors: (errors) =>  dispatch(formActions.failure(errors))
        })
      },
      reset: () => dispatch(formActions.reset())
    }
  }
)(FormComponent);
