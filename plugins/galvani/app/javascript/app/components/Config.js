import React, { useEffect } from "react"
import { fetchConfig } from "../actions/tags"
import { useDispatch, useGlobalState } from "./StateProvider"
import ErrorPage from "./ErrorPage"

const Config = () => {
  const dispatch = useDispatch()
  const config = useGlobalState().config

  useEffect(() => {
    loadConfig()
  }, [])

  const loadConfig = () => {
    dispatch({
      type: "REQUEST_CONFIG",
    })
    fetchConfig()
      .then((data) => {
        dispatch({
          type: "RECEIVE_CONFIG",
          config: data.config,
        })
        console.log("config: ", data.config)
      })
      .catch((error) => {
        dispatch({
          type: "REQUEST_CONFIG_FAILURE",
          error: error,
        })
      })
  }

  return (
    <>
      {config.error ? (
        <ErrorPage
          headTitle="Loading configuration"
          error={tags.error}
          onReload={loadConfig}
        />
      ) : (
        <>
          {config.isLoading && (
            <div>
              <span className="spinner"></span>
              Loading configuration...
            </div>
          )}
        </>
      )}
    </>
  )
}

export default Config
