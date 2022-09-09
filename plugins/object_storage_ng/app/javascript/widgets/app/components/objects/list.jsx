import React from "react"
import PropTypes from "prop-types"
import VirtualizedTable from "lib/components/VirtualizedTable"
import { Dropdown, MenuItem } from "react-bootstrap"
import TimeAgo from "../shared/TimeAgo"
import ItemsCount from "../shared/ItemsCount"
import { Unit } from "lib/unit"
import { useParams, Link, useRouteMatch, useHistory } from "react-router-dom"
import FileIcon from "./FileIcon"
import Router from "./router"
import Breadcrumb from "./breadcrumb"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"
import { Alert } from "react-bootstrap"
// import apiClient from "../../lib/apiClient"
import { SearchField } from "lib/components/search_field"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"

const unit = new Unit("B")

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

const Table = ({ data, containerName, onMenuAction, currentPath }) => {
  let { url } = useRouteMatch()
  let history = useHistory()
  let objectsRoot = url.replace(/([^/])\/objects.*/, "$1/objects")
  let { encode } = useUrlParamEncoder()

  const columns = React.useMemo(
    () => [
      {
        label: "Object name",
        accessor: "name",
        sortable: "text",
        // filterable: true,
      },
      {
        label: "Last modified",
        accessor: "last_modified",
        width: "20%",
        sortable: "date",
      },
      {
        label: "Size",
        accessor: "bytes",
        width: "20%",
        sortable: true,
      },
      { width: "60" },
    ],
    []
  )

  const Row = React.useCallback(
    ({ Row, item }) => (
      <Row>
        <Row.Column>
          <FileIcon item={item} />{" "}
          {item.folder ? (
            <>
              <a
                href="#"
                onClick={(e) => {
                  e.preventDefault()
                  console.log("objectsRoot", objectsRoot, "item", item)
                  history.push(`${objectsRoot}/${encode(item.path)}`)
                }}
              >
                {item.display_name || item.name}
              </a>{" "}
              <br />
              <ItemsCount count={item.count} />{" "}
            </>
          ) : (
            <a
              href="#"
              onClick={(e) => {
                e.preventDefault()
                onMenuAction("download", item)
              }}
            >
              {item.display_name || item.name}
            </a>
          )}
        </Row.Column>
        <Row.Column>
          {item.isProcessing ? (
            <span>
              <span className="spinner" />
              {item.isProcessing}
            </span>
          ) : item.error ? (
            <span className="text-danger">{item.error}</span>
          ) : (
            <TimeAgo date={item.last_modified} originDate />
          )}
        </Row.Column>
        <Row.Column>{unit.format(item.bytes)}</Row.Column>
        <Row.Column>
          <Dropdown id={`object-dropdown-${item.path}-${item.name}`} pullRight>
            <Dropdown.Toggle noCaret className="btn-sm">
              <span className="fa fa-cog" />
            </Dropdown.Toggle>

            {item.folder ? (
              <Dropdown.Menu>
                <MenuItem
                  onClick={() => onMenuAction("deleteRecursively", item)}
                >
                  Delete recursively
                </MenuItem>
              </Dropdown.Menu>
            ) : (
              <Dropdown.Menu className="super-colors">
                <MenuItem onClick={() => onMenuAction("download", item)}>
                  Download
                </MenuItem>

                <MenuItem divider />
                <MenuItem onClick={() => onMenuAction("properties", item)}>
                  Properties
                </MenuItem>
                <MenuItem divider />

                <MenuItem onClick={() => onMenuAction("copy", item)}>
                  Copy
                </MenuItem>
                <MenuItem onClick={() => onMenuAction("move", item)}>
                  Move/Rename
                </MenuItem>
                <MenuItem onClick={() => onMenuAction("delete", item)}>
                  Delete
                </MenuItem>
                <MenuItem
                  onClick={() => onMenuAction("deleteKeepSegments", item)}
                >
                  Delete (keep segments)
                </MenuItem>
              </Dropdown.Menu>
            )}
          </Dropdown>
        </Row.Column>
      </Row>
    ),
    [objectsRoot]
  )

  return (
    <VirtualizedTable
      height="max"
      rowHeight={50}
      columns={columns}
      data={data || []}
      renderRow={Row}
      showHeader
      bottomOffset={160} // footer height
    />
  )
}

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

  const handleMenuAction = React.useCallback((action, item) => {
    console.log("action", action, item)
  }, [])

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
            <Table
              data={filteredItems}
              containerName={name}
              currentPath={currentPath}
              onMenuAction={handleMenuAction}
            />
          ) : (
            <span>This folder is empty</span>
          )}
        </>
      )}
    </React.Fragment>
  )
}

export default Objects
