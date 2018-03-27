import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

//################### IMAGES #########################
const requestImageMembers= () =>
  ({
    type: constants.REQUEST_IMAGE_MEMBERS,
    requestedAt: Date.now()
  })
;

const requestImageMembersFailure= () => (
  {type: constants.REQUEST_IMAGE_MEMBERS_FAILURE}
);

const receiveImageMembers= (json) =>
  ({
    type: constants.RECEIVE_IMAGE_MEMBERS,
    items: json,
    receivedAt: Date.now()
  })
;

const receiveImageMember= (member) =>
  ({
    type: constants.RECEIVE_IMAGE_MEMBER,
    member
  })
;

const fetchImageMembers= (imageId) =>
  function(dispatch) {
    dispatch(requestImageMembers());

    return ajaxHelper.get(`/ng/images/${imageId}/members`).then( (response) => {
      if (response.data.errors) {
        addError(React.createElement(ErrorsList, {errors: response.data.errors}))
      } else {
        dispatch(receiveImageMembers(response.data.members));
      }
    })
    .catch( (error) => {
      dispatch(requestImageMembersFailure());
      addError(`Could not load image members (${error.message})`)
    });
  }
;

const shouldFetchImageMembers= (state) => {
  const members = state.imageMembers;
  if (members.isFetching || members.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchImageMembersIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchImageMembers(getState())) {
      return dispatch(fetchImageMembers());
    }
  }
;

const requestDeleteMember= memberId =>
  ({
    type: constants.REQUEST_DELETE_IMAGE_MEMBER,
    memberId
  })
;

const deleteImageMemberFailure=memberId =>
  ({
    type: constants.DELETE_IMAGE_MEMBER_FAILURE,
    memberId
  })
;

const removeImageMember=memberId =>
  ({
    type: constants.DELETE_IMAGE_MEMBER,
    memberId
  })
;

const deleteImageMember= (imageId,memberId) =>
  function(dispatch) {
    confirm(`Do you really want to delete the member ${memberId}?`).then(() => {
      dispatch(requestDeleteMember(memberId));
      ajaxHelper.delete(`/ng/images/${imageId}/members/${memberId}`).then((response) => {
        if (response.data && response.data.errors) {
          addError(React.createElement(ErrorsList, {errors: response.data.errors}));
          dispatch(deleteImageMemberFailure(memberId))
        } else {
          dispatch(removeImageMember(memberId));
        }
      }).catch((error) => {
        dispatch(deleteImageMemberFailure(memberId))
        addError(React.createElement(ErrorsList, {errors: error.message}));
      })
    }).catch((aborted) => null)
  }
;

//################ IMAGE FORM ###################
const submitNewImageMember= (values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.post(
        `/ng/images/${values.imageId}/members`,
        { member: values }
      ).then((response) => {
        if (response.data.errors) handleErrors({errors: response.data.errors});
        else {
          dispatch(receiveImageMember(response.data))
          handleSuccess()
        }
      }).catch(error => handleErrors({errors: error.message}))
    )
);

export {
  fetchImageMembers,
  deleteImageMember,
  submitNewImageMember
}
