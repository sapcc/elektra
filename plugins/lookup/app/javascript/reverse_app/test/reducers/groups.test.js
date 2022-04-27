import { groups } from '../../reducers/groups'
import * as constants from '../../constants';

describe('groups reducer', () => {

  it('returns initial state', () => {
    expect( groups(undefined, {})).toEqual({
      data: null,
      requestedAt: null,
      receivedAt: null,
      isFetching: false,
      error: null
    });
  });

  it('sets up state when fetching groups', () => {
    // given
    const beforeState = {
      data: null,
      requestedAt: null,
      receivedAt: null,
      isFetching: false,
      error: null
    };
    const date = Date.now();
    const action = {type: constants.REQUEST_GROUPS, requestedAt: date};
    // when
    const afterState = groups(beforeState, action);
    // then
    expect(afterState).toEqual({
      data: null,
      requestedAt: date,
      receivedAt: null,
      isFetching: true,
      error: null
    });
  });

});
