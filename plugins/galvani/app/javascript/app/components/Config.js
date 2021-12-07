import React, { useEffect } from "react"
import { persistConfig } from "../actions/tags"

const Config = () => {
  useEffect(() => {
    console.log("fetching config")

    persistConfig()
      .then((data) => {
        console.log("config: ", data)
      })
      .catch((error) => {
        console.log(error)
      })
  }, [])

  return <h2>Tags:</h2>
}

export default Config
