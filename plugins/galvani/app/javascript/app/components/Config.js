import React, { useEffect } from "react"
import { fetchConfig } from "../actions/tags"

const Config = () => {
  useEffect(() => {
    console.log("fetching config")

    fetchConfig()
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
