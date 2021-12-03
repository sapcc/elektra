import React, { useEffect } from "react"
import { persistTags } from "../actions/tags"

const Tags = () => {
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

  return <h2>Tags:</h2>
}

export default Tags
