import React, { useEffect } from "react"
import { fetchTags } from "../actions/tags"
import ErrorPage from "./ErrorPage"
import { useDispatch, useGlobalState } from "./StateProvider"
import useTag from "../../lib/hooks/useTag"
import AccessProfile from "./AccessProfile"

const TagsList = () => {
  const profilesCfg = useGlobalState().config.profiles
  const tags = useGlobalState().tags
  const topology = useTag(profilesCfg, tags.items)
  const dispatch = useDispatch()

  useEffect(() => {
    // load when the configuration is loaded
    if (profilesCfg) {
      loadTags()
    }
  }, [profilesCfg])

  const loadTags = () => {
    dispatch({
      type: "REQUEST_TAGS",
    })
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
              onReload={loadTags}
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
                  {topology &&
                    Object.keys(topology).map((accessProfileKey, i) => (
                      <AccessProfile
                        key={i}
                        profileName={accessProfileKey}
                        items={topology[accessProfileKey]}
                      />
                    ))}
                </>
              )}
            </>
          )}
        </>
      )}
    </>
  )
}

export default TagsList
