import React, { useEffect } from "react"
import { fetchTags } from "../actions/tags"
import Config from "./Config"
import { useDispatch, useGlobalState } from "./StateProvider"

const TagsList = () => {
  const state = useGlobalState()
  const dispatch = useDispatch()
  console.log(state)

  useEffect(() => {
    fetchTags()
      .then((data) => {
        dispatch({
          type: "RECEIVE_TAGS",
          tags: data.tags,
        })
        console.log("data: ", data)
      })
      .catch((error) => {
        dispatch({
          type: "REQUEST_TAGS_FAILURE",
          error: error,
        })
        console.log(error)
      })
  }, [])

  return (
    <>
      <h2>Tags:</h2>
      <Config />
    </>
  )
}

export default TagsList
