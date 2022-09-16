import React from "react"
import PropTypes from "prop-types"
import VirtualizedTable from "lib/components/VirtualizedTable"
import ContextMenu from "lib/components/ContextMenuPopover"
import TimeAgo from "../shared/TimeAgo"
import { Unit } from "lib/unit"
import {
  useParams,
  Link,
  useRouteMatch,
  useHistory,
  Route,
} from "react-router-dom"
import FileIcon from "./FileIcon"
import Breadcrumb from "../shared/breadcrumb"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"
import { Alert } from "react-bootstrap"
import { SearchField } from "lib/components/search_field"
import useActions from "../../hooks/useActions"
import NewObject from "./new"
import UploadFile from "./upload"

const unit = new Unit("B")

// const itemsChunks = (items, chunkSize) => {
//   if (chunkSize) {
//     const chunks = []
//     for (let i = 0; i < items.length; i += chunkSize) {
//       chunks.push(items.slice(i, i + chunkSize))
//     }
//     return chunks
//   } else {
//     return [items]
//   }
// }

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

const Table = ({ data, onMenuAction, onNameClick }) => {
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
      {
        width: "60",
      },
    ],
    []
  )

  const Row = React.useCallback(
    ({ Row, item }) => (
      <Row>
        <Row.Column>
          {(item.isProcessing || item.isDeleting) && (
            <span className="spinner" />
          )}
          <FileIcon item={item} />{" "}
          <a
            href="#"
            onClick={(e) => {
              e.preventDefault()
              item.subdir ? onNameClick(item) : onMenuAction("download", item)
            }}
          >
            {item.display_name}
          </a>
          {item.error && (
            <>
              <br />
              <span className="text-danger">{item.error}</span>
            </>
          )}
        </Row.Column>
        <Row.Column>
          {!item.subdir && <TimeAgo date={item.last_modified} originDate />}
        </Row.Column>
        <Row.Column>{!item.subdir && unit.format(item.bytes)}</Row.Column>
        <Row.Column>
          {item.subdir ? (
            <ContextMenu>
              <ContextMenu.Item
                onClick={() => onMenuAction("deleteRecursively", item)}
              >
                Delete recursively
              </ContextMenu.Item>
            </ContextMenu>
          ) : (
            <ContextMenu>
              <ContextMenu.Item onClick={() => onMenuAction("download", item)}>
                Download
              </ContextMenu.Item>

              <ContextMenu.Divider />
              <ContextMenu.Item
                onClick={() => onMenuAction("properties", item)}
              >
                Properties
              </ContextMenu.Item>
              <ContextMenu.Item divider />

              <ContextMenu.Item onClick={() => onMenuAction("copy", item)}>
                Copy
              </ContextMenu.Item>
              <ContextMenu.Item onClick={() => onMenuAction("move", item)}>
                Move/Rename
              </ContextMenu.Item>
              <ContextMenu.Item onClick={() => onMenuAction("delete", item)}>
                Delete
              </ContextMenu.Item>
              <ContextMenu.Item
                onClick={() => onMenuAction("deleteKeepSegments", item)}
              >
                Delete (keep segments)
              </ContextMenu.Item>
            </ContextMenu>
          )}
        </Row.Column>
      </Row>
    ),
    []
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

Table.propTypes = {
  data: PropTypes.arrayOf(PropTypes.object).isRequired,
  onMenuAction: PropTypes.func.isRequired,
  onNameClick: PropTypes.func.isRequired,
}

const initialState = { items: [], isFetching: false, error: null }

function reducer(state, action) {
  const { type, ...props } = action
  switch (type) {
    case "REQUEST_ITEMS":
      return { ...state, isFetching: true, error: null }
    case "RECEIVE_ITEMS":
      return { ...state, isFetching: false, error: null, items: props.items }
    case "RECEIVE_ITEM": {
      const items = state.items.slice()
      items.unshift(props.item)
      return { ...state, items }
    }
    case "REMOVE_ITEM": {
      const items = state.items.slice()
      const index = items.findIndex((i) => i.name === props.name)
      if (index >= 0) items.splice(index, 1)
      return { ...state, items }
    }
    case "UPDATE_ITEM": {
      const items = state.items.slice()
      const index = items.findIndex((i) => i.name === props.name)
      if (index < 0) return state
      items[index] = { ...items[index], ...props }
      return { ...state, items }
    }
    case "RECEIVE_ERROR":
      return { ...state, isFetching: false, error: props.error }
    default:
      throw new Error()
  }
}

const Objects = () => {
  let { url } = useRouteMatch()
  let objectsRoot = url.replace(/([^/])\/objects.*/, "$1/objects")
  let history = useHistory()
  let { name, objectPath } = useParams()
  const { value: currentPath, encode } = useUrlParamEncoder(objectPath)
  const [searchTerm, setSearchTerm] = React.useState(null)

  const { loadContainerObjects, deleteObject } = useActions()
  const [objects, dispatch] = React.useReducer(reducer, initialState)

  React.useEffect(() => {
    // Load objects
    // For objects beginning with a slash, this function is called recursively
    // until there are no objects beginning with a slash

    /** Normally, slashes are intended as delimiters for the directories. 
     * However, it is also allowed to create objects with leading slashes in names. 
     * This leads to a problem when we call the API with prefix and delimiter.
     * Example:
     * Given: [
     *  {name: "test/sub_test/image.pmg"},
     *  {name: "/test1/image.png"},
     *  {name: "//test3/sub_test3/a/b.png"}
     * ]
     * API Call: prefix: "", delimiter: "/" => ["test/", "/", "//"]
     * API Call: prefix: "/", delimiter: "/" => ["/test1/", "//"]
     * API Call: prefix: "//", delimiter: "/" => ["//test3/"]

    * As you can see, all calls deliver different results. To get all objects, 
    * even those starting with multiple slashes, we start with the empty prefix and 
    * * load the objects. After that, we search the results for names that only contain slashes. 
    * Remove these and recursively load with the prefix of the removed items, etc. 
    * until the results contain no objects with leading slashes.
    */
    const loadAllObjects = async (prefix = "") => {
      let objects = await loadContainerObjects(name, {
        prefix,
        delimiter: "/",
      }).then(({ data }) => data)
      // find index of the first object which name starts with a slash
      let regex = new RegExp(`^${prefix}/+$`)
      const startingWithSlashIndex = objects.findIndex(
        (o) => o.subdir && o.subdir.match(regex)
      )

      // index not found -> end of recursion
      if (startingWithSlashIndex < 0)
        return objects.filter((o) => o.name !== prefix)

      // get the new prefix based on the found object
      const newPrefix = objects[startingWithSlashIndex].subdir
      // remove all objects which names start with multiple slashes
      objects = objects.filter((o) => !(o.name || o.subdir).match(regex))
      // load objects recursively based on the new prefix
      let objectsStartingWithSlash = await loadAllObjects(newPrefix)
      // add new objects to the root objects
      let newObjects = objects.concat(objectsStartingWithSlash)

      // remove duplicates
      return newObjects.filter(
        (item, index) => newObjects.indexOf(item) === index
      )
    }

    dispatch({ type: "REQUEST_ITEMS" })
    loadAllObjects(currentPath)
      .then((items) => {
        // extend items with display_name and sort
        items.forEach((i) => {
          // display name
          let dn = (i.name || i.subdir).replace(currentPath, "")
          if (dn[dn.length - 1] === "/") dn = dn.slice(0, -1)
          i.display_name = dn
        })
        items = items.sort((a, b) =>
          a.display_name > b.display_name
            ? 1
            : a.display_name < b.display_name
            ? -1
            : 0
        )
        dispatch({ type: "RECEIVE_ITEMS", items })
      })
      .catch((error) =>
        dispatch({ type: "RECEIVE_ERROR", error: error.message })
      )
  }, [name, currentPath, dispatch, loadContainerObjects])

  const handleMenuAction = React.useCallback(
    (action, item) => {
      console.log("action", action, item)
      switch (action) {
        case "changePath":
          history.push(`${objectsRoot}/${encode(item.path)}`)
          break
        case "delete": {
          dispatch({ type: "UPDATE_ITEM", name: item.name, isDeleting: true })
          deleteObject(name, item.name)
            .then(() => dispatch({ type: "REMOVE_ITEM", name: item.name }))
            .catch((error) =>
              dispatch({
                type: "UPDATE_ITEM",
                name: item.name,
                isDeleting: false,
                error: error.message,
              })
            )
          break
        }
      }
    },
    [name, objectsRoot, deleteObject, dispatch]
  )

  const handleNameClick = React.useCallback(
    (item) =>
      item.subdir && history.push(`${objectsRoot}/${encode(item.subdir)}`),
    [history, objectsRoot]
  )

  const handleFolderCreated = React.useCallback(
    (values) => {
      dispatch({ type: "RECEIVE_ITEM", item: values })
    },
    [dispatch]
  )

  const filteredItems = React.useMemo(() => {
    if (!searchTerm || searchTerm.length === 0) return objects.items
    return objects.items.filter((i) => i.display_name.indexOf(searchTerm) >= 0)
  }, [objects.items, searchTerm])

  return (
    <React.Fragment>
      <Route exact path="/containers/:name/objects/:objectPath?/new">
        <NewObject onCreated={handleFolderCreated} />
      </Route>
      <Route exact path="/containers/:name/objects/:objectPath?/upload">
        <UploadFile />
      </Route>

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
      <Breadcrumb count={filteredItems.length} />
      {objects.isFetching ? (
        <span>
          <span className="spinner" /> Loading...
        </span>
      ) : objects.error ? (
        <Alert bsStyle="danger">{objects.error}</Alert>
      ) : !objects || objects.items.length === 0 ? (
        <span>No entries found.</span>
      ) : (
        <>
          {filteredItems.length > 0 ? (
            <Table
              data={filteredItems}
              onNameClick={handleNameClick}
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
