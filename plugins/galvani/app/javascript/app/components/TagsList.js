import React, { useEffect } from "react"
import { fetchTags } from "../actions/tags"
import ErrorPage from "./ErrorPage"
import { useDispatch, useGlobalState } from "./StateProvider"
import useTag from "../../lib/hooks/useTag"

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
    console.log("fetching tags")
    dispatch({
      type: "REQUEST_TAGS",
    })
    fetchTags()
      .then((data) => {
        dispatch({
          type: "RECEIVE_TAGS",
          tags: data.tags,
        })
        console.log("tags: ", data.tags)
      })
      .catch((error) => {
        dispatch({
          type: "REQUEST_TAGS_FAILURE",
          error: error,
        })
        console.log(error)
      })
  }

  return (
    <>
      {profilesCfg && (
        <>
          <h3>Existing Access Profiles</h3>
          {tags.error ? (
            <ErrorPage
              headTitle="Loading access profiles"
              error={tags.error}
              onReload={loadTags}
            />
          ) : (
            <>
              {tags.isLoading && (
                <div>
                  <span className="spinner"></span>
                  Loading profiles...
                </div>
              )}
            </>
          )}
        </>
      )}
    </>
  )
}

export default TagsList
