import React from "react"
import { useDispatch } from "../../app/components/StateProvider"
import { ajaxHelper } from "ajax_helper"
import { confirm } from "lib/dialogs"
import { regexString } from "lib/tools/regex_string"

export const validateForm = (items) => {
  let isValid = true
  if (items && Array.isArray(items)) {
    items.forEach((item) => {
      if (!item.name || item.name.length == 0) {
        isValid = false
      }
      if (!item.address || item.address.length == 0) {
        isValid = false
      }
      if (!item.protocol_port || item.protocol_port.length == 0) {
        isValid = false
      }
    })
  }

  return isValid
}

// parse nested keys to objects
// from values like member[XYZ][name]="arturo" to {XYZ:{name:"arturo"}}
export const parseNestedValues = (items) => {
  let newMemberObjs = {}
  Object.keys(items).forEach((key) => {
    const newKeys = key
      .split("[")
      .filter(function (v) {
        return v.indexOf("]") > -1
      })
      .map(function (value) {
        return value.split("]")[0]
      })

    const member = newKeys[0]
    const field = newKeys[1]
    if (!newMemberObjs[member]) newMemberObjs[member] = {}
    newMemberObjs[member][field] = items[key]
  })
  return newMemberObjs
}

export const filterItems = (searchTerm, items) => {
  if (!searchTerm) return items

  const regex = new RegExp(regexString(searchTerm.trim()), "i")
  return items.filter(
    (i) =>
      `${i.id} ${i.name} ${i.address} ${i.protocol_port}`.search(regex) >= 0
  )
}

const useMember = () => {
  const dispatch = useDispatch()

  const fetchMembers = (lbID, poolID) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers/${lbID}/pools/${poolID}/members`)
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error)
        })
    })
  }

  const fetchMember = (lbID, poolID, memberID) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers/${lbID}/pools/${poolID}/members/${memberID}`)
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error.response)
        })
    })
  }

  const persistMembers = (lbID, poolID) => {
    dispatch({ type: "RESET_MEMBERS" })
    dispatch({ type: "REQUEST_MEMBERS" })
    return new Promise((handleSuccess, handleError) => {
      fetchMembers(lbID, poolID)
        .then((data) => {
          dispatch({ type: "RECEIVE_MEMBERS", items: data.members })
          handleSuccess(data)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_MEMBERS_FAILURE", error: error })
          handleError(error.response)
        })
    })
  }

  const persistMember = (lbID, poolID, memberID) => {
    return new Promise((handleSuccess, handleError) => {
      fetchMember(lbID, poolID, memberID)
        .then((data) => {
          dispatch({ type: "RECEIVE_MEMBER", member: data.member })
          handleSuccess(data)
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_MEMBER", id: memberID })
          }
          handleError(error.response)
        })
    })
  }

  const createNameTag = (name) => {
    return name ? (
      <React.Fragment>
        <b>name:</b> {name} <br />
      </React.Fragment>
    ) : (
      ""
    )
  }

  const deleteMember = (lbID, poolID, memberID, memberName) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <React.Fragment>
          <p>Do you really want to delete following Member?</p>
          <p>
            {createNameTag(memberName)} <b>id:</b> {memberID}
          </p>
        </React.Fragment>
      )
        .then(() => {
          return ajaxHelper
            .delete(
              `/loadbalancers/${lbID}/pools/${poolID}/members/${memberID}`
            )
            .then((response) => {
              dispatch({ type: "REQUEST_REMOVE_MEMBER", id: memberID })
              handleSuccess(response)
            })
            .catch((error) => {
              handleErrors(error)
            })
        })
        .catch((cancel) => true)
    })
  }

  const fetchServers = (lbID, poolID) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(
          `/loadbalancers/${lbID}/pools/${poolID}/members/servers_for_select`
        )
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error.response)
        })
    })
  }

  const create = (lbID, poolID, values) => {
    if (values && Array.isArray(values) && values.length == 1) {
      return createMember(lbID, poolID, values[0])
    }
    return updateBatchMembers(lbID, poolID, values)
  }

  const createMember = (lbID, poolID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .post(`/loadbalancers/${lbID}/pools/${poolID}/members`, {
          member: values,
        })
        .then((response) => {
          dispatch({ type: "RECEIVE_MEMBER", member: response.data })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateBatchMembers = (lbID, poolID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .post(`/loadbalancers/${lbID}/pools/${poolID}/members/batch_update`, {
          members: values,
        })
        .then((response) => {
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateMember = (lbID, poolID, memberID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .put(`/loadbalancers/${lbID}/pools/${poolID}/members/${memberID}`, {
          member: values,
        })
        .then((response) => {
          dispatch({ type: "RECEIVE_MEMBER", member: response.data })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const setSearchTerm = (searchTerm) => {
    dispatch({ type: "SET_MEMBERS_SEARCH_TERM", searchTerm: searchTerm })
  }

  return {
    fetchMembers,
    persistMembers,
    fetchMember,
    persistMember,
    deleteMember,
    fetchServers,
    create,
    createMember,
    updateMember,
    setSearchTerm,
  }
}

export default useMember
