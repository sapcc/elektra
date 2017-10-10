import * as constants from './constants';

const initialState = {
  values: {},
  isSubmitting: false,
  errors: null,
  isValid: false
};

const reset=function(action,...rest){
  return initialShareFormState;
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

export default function(state, action) {
  if (state == null) { state = initialShareFormState; }
  switch (action.type) {
    case constants.RESET: return reset(state,action);
    case constants.UPDATE_VALUE: return updateValue(state,action);
    case constants.SUBMIT: return submit(state,action);
    case constants.FAILURE: return failure(state,action);
    default: return state;
  }
};
