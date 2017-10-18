import * as constants from './constants';

export const FormActions = (formName) => ({
  failure(errors) {
    return {
      type: formName+'/'+constants.FAILURE,
      errors
    }
  },

  update(name,value) {
    return {
      type: formName+'/'+constants.UPDATE_VALUE,
      name,
      value
    }
  },

  reset() {
    return {
      type: formName+'/'+constants.RESET
    }
  },

  submit() {
    return {
      type: formName+'/'+constants.SUBMIT
    }
  }
});
