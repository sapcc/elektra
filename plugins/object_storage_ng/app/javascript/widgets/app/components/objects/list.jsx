import React from "react"
import { useParams, Link, useRouteMatch } from "react-router-dom"
import ObjectItem from "./item"
import Router from "./router"
import Breadcrumb from "./breadcrumb"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"
import { Alert } from "react-bootstrap"
// import apiClient from "../../lib/apiClient"
import { SearchField } from "lib/components/search_field"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"

const itemsChunks = (items, chunkSize) => {
  if (chunkSize) {
    const chunks = []
    for (let i = 0; i < items.length; i += chunkSize) {
      chunks.push(items.slice(i, i + chunkSize))
    }
    return chunks
  } else {
    return [items]
  }
}

// const deleteObjects = (objects, options = {}) => {
//   const containerName = options.containerName
//   const prefix = containerName ? containerName + "/" : ""
//   let promises = []

//   if (options.bulkDeleteSupported) {
//     const chunks = itemsChunks(objects, options.maxDeletePerRequest)
//     // console.log("chunks", chunks)

//     promises = chunks.map((objects) => {
//       const list = objects.reduce((list, item) => {
//         list += prefix + item + "\n"
//         return list
//       }, "")
//       console.log(list)

//       return apiClient
//         .osApi("object-store")
//         .delete("", list, { headers: { "Content-Type": "text/plain" } })
//         .then((response) => console.log(response))
//     })
//   } else {
//     promises = objects.map((o) =>
//       apiClient
//         .osApi("object-store")
//         .delete(prefix + o)
//         .then((response) => console.log(response))
//     )
//   }

//   return Promise.all(promises)
// }

const Objects = () => {
  let { url } = useRouteMatch()
  let { name, objectPath } = useParams()
  const { value: currentPath } = useUrlParamEncoder(objectPath)
  const [searchTerm, setSearchTerm] = React.useState(null)
  const { objects: containerObjects, capabilities } = useGlobalState()
  const { loadContainerObjectsOnce, loadObjectMetadata } = useActions()

  React.useEffect(() => {
    loadContainerObjectsOnce(name)
  }, [name])

  const objects = React.useMemo(
    () => containerObjects[name] || {},
    [containerObjects, name]
  )

  // const emptyContainer = React.useCallback(
  //   (containerName) => {
  //     const maxDeletePerRequest =
  //       capabilities.data?.bulk_delete?.max_deletes_per_request

  //     deleteObjects([], {
  //       bulkDeleteSupported: !!maxDeletePerRequest,
  //       maxDeletePerRequest,
  //       containerName,
  //     })
  //   },
  //   [capabilities]
  // )

  // Filter visible items.
  // Filter out items that are in "directories" and show only the directories and files.
  const visibleItems = React.useMemo(() => {
    if (objects.isFetching || !objects.items || objects.items.length === 0)
      return []

    let prefix = currentPath || ""
    if (prefix[0] === "/") prefix = prefix.slice(1)
    if (prefix.length > 0 && prefix[prefix.length - 1] !== "/")
      prefix = prefix + "/"

    const itemRegex = new RegExp("^/?" + prefix + "(/*[^/]+/?)(/*[^/]*)")

    const filteredItems = objects.items.reduce((items, item) => {
      const itemMatch = item.name.match(itemRegex)

      // only items witch matches the regex
      if (itemMatch) {
        // console.log(itemMatch)
        const path = itemMatch[1]
        const subItemName = itemMatch[2]
        // if path ends with a slash then it is a folder
        const isFolder = path && path[path.length - 1] === "/"
        const displayName = path.match(/^(\/*[^/]*)\/?/)[1]

        if (items[displayName]) {
          // item with displayName is already registered
          // sum up the size
          items[displayName].bytes += item.bytes

          // last modified date should be the newest one
          const currentItemDate = Date.parse(item.last_modified)
          const lastItemDate = Date.parse(items[displayName].last_modified)
          if (currentItemDate > lastItemDate)
            items[displayName].last_modified = item.last_modified
          // update folder value
          items[displayName].folder = items[displayName].folder || isFolder
        } else {
          // register item
          items[displayName] = {
            name: item.name,
            display_name: displayName,
            folder: isFolder,
            bytes: item.bytes,
            last_modified: item.last_modified,
            path: currentPath + path,
            sub_items: {},
          }
        }

        // count subitems
        if (subItemName && subItemName.length > 0) {
          items[displayName].sub_items[subItemName] = true
          items[displayName].count = Object.keys(
            items[displayName].sub_items
          ).length
        }
      }
      return items
    }, {})

    return Object.values(filteredItems).sort((a, b) =>
      (a.folder && !b.folder) || a.display_name < b.display_name
        ? -1
        : (!a.folder && b.folder) || a.display_name > b.display_name
        ? 1
        : 0
    )
  }, [currentPath, objects])

  const filteredItems = React.useMemo(() => {
    if (!searchTerm || searchTerm.length === 0) return visibleItems
    return visibleItems.filter((i) => i.display_name.indexOf(searchTerm) >= 0)
  }, [visibleItems, searchTerm])

  return (
    <React.Fragment>
      <Router />

      <div className="toolbar">
        <SearchField
          onChange={setSearchTerm}
          placeholder="name"
          text="Filters by name"
        />

        <div className="main-buttons">
          <Link className="btn btn-default" to={`${url}/new`}>
            Create folder
          </Link>
          <Link className="btn btn-primary" to={`${url}/upload`}>
            Upload file
          </Link>
        </div>
      </div>

      {objects.isFetching ? (
        <span>
          <span className="spinner" /> Loading...
        </span>
      ) : objects.error ? (
        <Alert bsStyle="danger">{error}</Alert>
      ) : !objects || objects.length === 0 ? (
        <span>No entries found.</span>
      ) : (
        <>
          {" "}
          <Breadcrumb />
          {filteredItems.length > 0 ? (
            <table className="table">
              <thead>
                <tr>
                  <th>Object name</th>
                  <th>Last Modified</th>
                  <th>Size</th>
                  <th className="snug"></th>
                </tr>
              </thead>
              <tbody>
                {filteredItems.map((item, i) => (
                  <ObjectItem item={item} key={i} currentPath={currentPath} />
                ))}
              </tbody>
            </table>
          ) : (
            <span>This folder is empty</span>
          )}
        </>
      )}
    </React.Fragment>
  )
}

export default Objects
