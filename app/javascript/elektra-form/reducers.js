import * as constants from './constants';

const initialState = {
  values: {},
  isSubmitting: false,
  errors: null,
  isValid: false
};

const reset=function(action,...rest){
  return initialState;
};

const updateValue=function(state,{name,value}){
  const values = Object.assign({},state.values,{[name]:value});
  return Object.assign({},state,{values})
};

const submit=function(state,...rest){
  return Object.assign({},state,{isSubmitting: true,errors: null});
};

const handleFailure=(state,{errors})=>
  Object.assign({},state,{isSubmitting: false, errors})
;

export const FormReducers = (name) => function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case name+'/'+constants.RESET: return reset(state,action);
    case name+'/'+constants.UPDATE_VALUE: return updateValue(state,action);
    case name+'/'+constants.SUBMIT: return submit(state,action);
    case name+'/'+constants.FAILURE: return failure(state,action);
    default: return state;
  }
};
