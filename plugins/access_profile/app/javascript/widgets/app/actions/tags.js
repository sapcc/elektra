import { ajaxHelper } from "lib/ajax_helper"

const fetchTags = () => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .get(`/tags`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error.response)
      })
  )
}

const createTag = (tag) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post("/tags/", { tag: tag })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error.response)
      })
  })
}

const removeTag = (tag) => {
  return new Promise((handleSuccess, handleErrors) => {
    return ajaxHelper
      .delete(`/tags/${tag}`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error.response)
      })
  })
}

const fetchConfig = () => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .get(`/tags/config`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error.response)
      })
  )
}

// xs:internet:dns_reader', 'xs:internet:keppel_account_pull:cc-demo'
const composeTag = (profile, serviceAction, option) => {
  const tag = `xs:${profile}:${serviceAction}`
  return tag
}

export { fetchTags, createTag, removeTag, fetchConfig, composeTag }
