 import configureMockStore from 'redux-mock-store';
import * as constants from '../constants';
import fetchProject from './project';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

describe('fetchProject action', () => {

  let store;
  let httpMock;

  const flushAllPromises = () => new Promise(resolve => setImmediate(resolve));

  beforeEach(() => {
    httpMock = new MockAdapter(axios);
    const mockStore = configureMockStore();
    store = mockStore({});
  });

  it('fetches a project', async () => {
    // given
    httpMock.onGet('/reverselookup/project/a_project_id').reply(200, {
      id: 'some_project_id'
    });
    // when
    fetchProject()(store.dispatch);
    await flushAllPromises();
    // then
    expect(store.getActions()).toEqual(
      [
        { type: constants.REQUEST_PROJECT },
        { type: constants.RECEIVE_PROJECT, data: {id: 'some_project_id'}, receivedAt: Date.now() }
      ]);
  })
});
