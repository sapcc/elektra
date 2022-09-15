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
import Breadcrumb from "../shared/breadcrumb"
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
          {item.isProcessing && <span className="spinner" />}
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
          <Dropdown id={`object-dropdown-${item.path}-${item.name}`} pullRight>
            <Dropdown.Toggle noCaret className="btn-sm">
              <span className="fa fa-cog" />
            </Dropdown.Toggle>

            {item.subdir ? (
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
  switch (action.type) {
    case "REQUEST_ITEMS":
      return { ...state, isFetching: true, error: null }
    case "RECEIVE_ITEMS":
      return { ...state, isFetching: false, error: null, items: action.items }
    case "RECEIVE_ERROR":
      return { ...state, isFetching: false, error: action.error }
    default:
      throw new Error()
  }
}

const Objects = () => {
  let { url } = useRouteMatch()
  let objectsRoot = url.replace(/([^/])\/objects.*/, "$1/objects")
  let history = useHistory()
  let { encode } = useUrlParamEncoder()
  let { name, objectPath } = useParams()
  const { value: currentPath } = useUrlParamEncoder(objectPath)
  const [searchTerm, setSearchTerm] = React.useState(null)

  const { loadContainerObjects } = useActions()
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
      }
    },
    [objectsRoot]
  )

  const handleNameClick = React.useCallback(
    (item) =>
      item.subdir && history.push(`${objectsRoot}/${encode(item.subdir)}`),
    [history, objectsRoot]
  )

  const filteredItems = React.useMemo(() => {
    if (!searchTerm || searchTerm.length === 0) return objects.items
    return objects.items.filter((i) => i.display_name.indexOf(searchTerm) >= 0)
  }, [objects.items, searchTerm])

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
