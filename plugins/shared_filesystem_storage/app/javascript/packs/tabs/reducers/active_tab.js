import * as constants from '../constants';

const activeTab = function(state, action) {
  if (state == null) { state = {}; }
  switch(action.type) {
    case constants.SELECT_TAB:
      return { uid: action.uid };
    default:
      return state;
  }
};

export default activeTab;
