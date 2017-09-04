import * as constants from '../constants';

//######################### SHARE FORM ###########################
const initialShareFormState = {
  method: 'post',
  action: '',
  data: {},
  isSubmitting: false,
  errors: null,
  isValid: false
};

const resetShareForm=function(action,...rest){
  const obj = rest[0];
  return initialShareFormState;
};

const updateShareForm=function(state,{name,value}){
  const data = Object.assign({},state.data,{[name]:value});
  return Object.assign({},state,{
    data,
    errors: null,
    isSubmitting: false,
    isValid: (data.share_proto && data.size && data.share_network_id)
  });
};

const submitShareForm=function(state,...rest){
  const obj = rest[0];
  return Object.assign({},state,{
    isSubmitting: true,
    errors: null
  });
};

const prepareShareForm=function(state,{action,method,data}){
  const values = {
    method,
    action,
    errors: null
  };
  if (data) { values['data']=data; }

  return Object.assign({},initialShareFormState,values);
};

const shareFormFailure=(state,{errors})=>
  Object.assign({},state,{
    isSubmitting: false,
    errors
  })
;

const shareForm = function(state, action) {
  if (state == null) { state = initialShareFormState; }
  switch (action.type) {
    case constants.RESET_SHARE_FORM: return resetShareForm(state,action);
    case constants.UPDATE_SHARE_FORM: return updateShareForm(state,action);
    case constants.SUBMIT_SHARE_FORM: return submitShareForm(state,action);
    case constants.PREPARE_SHARE_FORM: return prepareShareForm(state,action);
    case constants.SHARE_FORM_FAILURE: return shareFormFailure(state,action);
    default: return state;
  }
};

export default shareForm;
