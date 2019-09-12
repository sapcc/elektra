import * as constants from '../constants';

const initialState = {};

export const keppel = (state, action) => {
  if (state == null) {
    state = initialState;
  }

  switch(action.type) {
    default: return state;
  }
};
