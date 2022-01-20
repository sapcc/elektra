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
          error={config.error}
          onReload={loadConfig}
        />
      ) : (
        <>
          {config.isLoading ? (
            <div>
              <span className="spinner"></span>
              Loading configuration...
            </div>
          ) : (
            <>
              {(!config.profiles ||
                Object.keys(config.profiles).length == 0) && (
                <ErrorPage
                  headTitle="Loading configuration"
                  error="Configuration seems to be empty."
                  onReload={loadConfig}
                />
              )}
            </>
          )}
        </>
      )}
    </>
  )
}

export default Config
