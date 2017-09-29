import * as constants from '../constants';

const selectTab = uid => {
  console.log('tab uid', uid)
  return {
    type: constants.SELECT_TAB,
    uid
  }
};

export { selectTab };
