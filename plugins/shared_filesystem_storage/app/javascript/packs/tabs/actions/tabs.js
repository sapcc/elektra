import * as constants from '../constants';

const selectTab = uid =>
  ({
    type: constants.SELECT_TAB,
    uid
  })
;

export default { selectTab };
