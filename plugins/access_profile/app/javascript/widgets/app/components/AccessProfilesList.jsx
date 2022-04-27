import React, { useEffect } from "react"
import { fetchTags } from "../actions/tags"
import ErrorPage from "./ErrorPage"
import { useDispatch, useGlobalState } from "./StateProvider"
import useTag from "../../../lib/hooks/useTag"
import AccessProfileItem from "./AccessProfileItem"

const AccessProfilesList = () => {
  const profilesCfg = useGlobalState().config.profiles
  const tags = useGlobalState().tags
  const topology = useTag(profilesCfg, tags.items)
  const dispatch = useDispatch()

  useEffect(() => {
    // load when the configuration is loaded
    if (profilesCfg) {
      initLoadTags()
    }
  }, [profilesCfg])

  const initLoadTags = () => {
    dispatch({
      type: "REQUEST_TAGS",
    })
    loadTags()
  }

  const loadTags = () => {
    fetchTags()
      .then((data) => {
        dispatch({
          type: "RECEIVE_TAGS",
          tags: data.tags,
        })
      })
      .catch((error) => {
        dispatch({
          type: "REQUEST_TAGS_FAILURE",
          error: error,
        })
      })
  }

  return (
    <>
      {profilesCfg && (
        <>
          {tags.error ? (
            <ErrorPage
              headTitle="Loading access profiles"
              error={tags.error}
              onReload={initLoadTags}
            />
          ) : (
            <>
              {tags.isLoading ? (
                <div>
                  <span className="spinner"></span>
                  Loading access profiles...
                </div>
              ) : (
                <>
                  {topology?.profiles &&
                    Object.keys(topology.profiles).map(
                      (accessProfileKey, i) => (
                        <AccessProfileItem
                          key={i}
                          profileKey={accessProfileKey}
                          items={topology.profiles[accessProfileKey]}
                          reloadTags={loadTags}
                        />
                      )
                    )}
                </>
              )}
            </>
          )}
        </>
      )}
    </>
  )
}

export default AccessProfilesList
