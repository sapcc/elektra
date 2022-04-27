/**
 * Since we are accessing the window object, we use jsdom,
 * which emulates the browser
 * @jest-environment jsdom
 */

import { setupStore } from 'testHelper'
import * as constants from '../../constants'
import { fetchProject } from '../../actions/project'
import axios from 'axios'
import MockAdapter from 'axios-mock-adapter'
import { configureAjaxHelper } from 'ajax_helper'

describe('fetchProject action', () => {

  let store;
  let httpMock;

  const flushAllPromises = () => new Promise(resolve => setTimeout(resolve));
  
  beforeEach(() => {
    httpMock = new MockAdapter(axios)
    store = setupStore({object: {searchedValue: "a_project_id"}})
    const ajaxHelper = configureAjaxHelper({baseURL: ""})
  });

  it('fetches a project', async () => {
    const projectId = "a_project_id"
    httpMock.onGet(`/reverselookup/project/${projectId}`).reply(200, {
      id: 'a_project_id'
    });
    // when
    store.dispatch(fetchProject("a_project_id", projectId))
    await flushAllPromises();
    // then
    expect(store.getActions().length).toEqual(2)
    expect(store.getActions()[0].type).toEqual(constants.REQUEST_PROJECT)
    expect(store.getActions()[1].type).toEqual(constants.RECEIVE_PROJECT)
    expect(store.getActions()[1].data).toEqual({id: 'a_project_id'})
  })

  it('reject project if it is not the same as was requested because of asynchronous requests', async () => {
    const projectId = "b_project_id"
    httpMock.onGet(`/reverselookup/project/${projectId}`).reply(200, {
      id: 'a_project_id'
    });
    // when
    store.dispatch(fetchProject("b_project_id", projectId))
    await flushAllPromises();
    // then
    expect(store.getActions().length).toEqual(1)
    expect(store.getActions()[0].type).toEqual(constants.REQUEST_PROJECT)
  })

});
