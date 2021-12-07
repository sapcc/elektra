import React, { useEffect } from "react"
import { persistTags } from "../actions/tags"
import Config from "./Config"

const TagsList = () => {
  useEffect(() => {
    console.log("fetching tags")

    persistTags()
      .then((data) => {
        console.log("data: ", data)
      })
      .catch((error) => {
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
