import React from "react"
import {
  useParams,
  Link,
  useRouteMatch,
  useHistory,
  Route,
} from "react-router-dom"
import Breadcrumb from "../shared/breadcrumb"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"
import { Alert } from "react-bootstrap"
import { SearchField } from "lib/components/search_field"
import useActions from "../../hooks/useActions"
import NewObject from "./new"
import UploadFile from "./upload"
import ShowProperties from "./show"
import CopyFile from "./copy"

import { reducer, initialState } from "./reducer"
import Table from "./table"

const Objects = ({ objectStoreEndpoint }) => {
  let { url } = useRouteMatch()
  let objectsRoot = url.replace(/([^/])\/objects.*/, "$1/objects")
  let history = useHistory()
  let { name: containerName, objectPath } = useParams()
  const { value: currentPath, encode } = useUrlParamEncoder(objectPath)
  const [searchTerm, setSearchTerm] = React.useState(null)

  const {
    loadContainerObjects,
    deleteObject,
    deleteObjects,
    loadAccountMetadataOnce,
  } = useActions()

  const [objects, dispatch] = React.useReducer(reducer, initialState)

  const loadObjects = React.useCallback(() => {
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
      let objects = await loadContainerObjects(containerName, {
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
  }, [containerName, currentPath, dispatch, loadContainerObjects])

  React.useEffect(() => {
    loadObjects()
  }, [loadObjects])

  // Delete a single file
  const deleteFile = React.useCallback(
    (name, options = {}) => {
      // let deleteFunc

      // if (options.keepSegments !== false) {
      //   deleteFunc = deleteObject(containerName,name)
      // } else {
      //   if(metadata["x-object-manifest"])
      // }
      //   if keep_segments
      //   elektron_object_storage.delete("#{container_name}/#{object.path}")
      // else
      //   if object.slo
      //     elektron_object_storage.delete("#{container_name}/#{object.path}?multipart-manifest=delete")
      //   elsif object.dlo
      //     # delete dlo manifest
      //     elektron_object_storage.delete("#{container_name}/#{object.path}")
      //     # delete segments container
      //     delete_folder(object.dlo_segments_container,object.dlo_segments_folder_path)
      //   else
      //     elektron_object_storage.delete("#{container_name}/#{object.path}")
      //   end
      // end
      dispatch({ type: "UPDATE_ITEM", name, isDeleting: true })
      deleteObject(containerName, name)
        .then(() => dispatch({ type: "REMOVE_ITEM", name }))
        .catch((error) =>
          dispatch({
            type: "UPDATE_ITEM",
            name,
            isDeleting: false,
            error: error.message,
          })
        )
    },
    [containerName, dispatch, deleteObject]
  )

  // Return the delete function and a cancel function
  const [deleteFolder, cancelDeleteFolder] = React.useMemo(() => {
    // this variable indicates whether deletion is active
    let active

    // this is the function which deletes all objects inside a folder
    const action = (name) => {
      if (!containerName || !name) return
      active = true

      // This function deletes all objects of a folder.
      // Since the number of objects to be loaded and deleted is limited,
      // we delete the objects in chunks.
      const deleteAllObjects = async () => {
        let marker
        let deletedCount = 0
        let processing = true
        // We load objects, delete them and repeat this process until there are no more objects
        while (active && processing) {
          // use prefix to limit the deletion to current folder
          await loadContainerObjects(containerName, {
            marker,
            prefix: name,
          }).then(async ({ data }) => {
            if (data.length > 0 && active) {
              // delete objects
              await deleteObjects(containerName, data)
              // update progress
              dispatch({
                type: "UPDATE_ITEM",
                name,
                progress: (deletedCount += data.length),
              })
              // marker is the last item. Marker is used to load the next chunk of items.
              marker = data.pop().name
            } else {
              processing = false
            }
          })
        }
      }

      dispatch({ type: "UPDATE_ITEM", name, isDeleting: true })
      deleteAllObjects()
        .then(() => dispatch({ type: "REMOVE_ITEM", name }))
        .catch((error) => {
          if (!active) return
          dispatch({
            type: "UPDATE_ITEM",
            name,
            isDeleting: false,
            error: error.message,
          })
        })
    }

    // return the actual action and a cancel function to cancel the delete process for large containers
    return [action, () => (active = false)]
  }, [
    containerName,
    loadContainerObjects,
    deleteObjects,
    deleteObjects,
    dispatch,
  ])

  const downloadFile = React.useCallback(
    (name) => {
      const createTmpUrl = async () => {
        const account = await loadAccountMetadataOnce()
        const endpointURL = new URL(objectStoreEndpoint)
        console.log("::::::", objectStoreEndpoint, endpointURL)
        console.log("====================account data", account)

        // return url
      }

      createTmpUrl().then((url) => {
        console.log("====================url", url)
        window.open(url, "_blank").focus()
      })
      //const url = `${objectStoreEndpoint}/${containerName}/${name}`

      // window
      //   .open(`${objectStoreEndpoint}/${containerName}/${name}`, "_blank")

      //   .focus()

      // window.open(
      //   url +
      //     `?temp_url_sig=732fcac368abb10c78a4cbe95c3fab7f311584532bf779abd5074e13cbe8b88b
      // &temp_url_expires=1323479485
      // &filename=${name}`,
      //   "_blank"
      // )

      // const startTime = new Date().getTime()

      // let request = new XMLHttpRequest()

      // request.responseType = "blob"
      // request.open("get", url, true)
      // request.send()

      // request.onreadystatechange = function () {
      //   if (this.readyState == 4 && this.status == 200) {
      //     const imageURL = window.URL.createObjectURL(this.response)

      //     const anchor = document.createElement("a")
      //     anchor.href = imageURL
      //     anchor.download = name
      //     document.body.appendChild(anchor)
      //     anchor.click()
      //   }
      // }

      // request.onprogress = function (e) {
      //   const percent_complete = Math.floor((e.loaded / e.total) * 100)

      //   const duration = (new Date().getTime() - startTime) / 1000
      //   const bps = e.loaded / duration

      //   const kbps = Math.floor(bps / 1024)

      //   const time = (e.total - e.loaded) / bps
      //   const seconds = Math.floor(time % 60)
      //   const minutes = Math.floor(time / 60)

      //   console.log(
      //     `${percent_complete}% - ${kbps} Kbps - ${minutes} min ${seconds} sec remaining`
      //   )
      // }

      // fetch(`${objectStoreEndpoint}/${containerName}/${name}`, {
      //   method: "get",
      //   // mode: "no-cors",
      //   referrerPolicy: "no-referrer",
      // })
      //   .then((res) => {
      //     console.log(res)
      //     return res
      //   })
      //   .then((res) => res.blob())
      //   .then((res) => {
      //     console.log("====res", res)
      //     const aElement = document.createElement("a")
      //     aElement.setAttribute("download", name)
      //     const href = URL.createObjectURL(res)
      //     aElement.href = href
      //     aElement.setAttribute("target", "_blank")
      //     aElement.click()
      //     URL.revokeObjectURL(href)
      //   })
    },
    [containerName, loadAccountMetadataOnce]
  )

  // cancel current deletion process
  React.useEffect(() => {
    return () => cancelDeleteFolder && cancelDeleteFolder()
  }, [cancelDeleteFolder])

  const changeDir = React.useCallback(
    (subdir) => history.push(`${objectsRoot}/${encode(subdir)}`),
    [history, objectsRoot]
  )

  const showProperties = React.useCallback(
    (name) => {
      history.push(
        `${url}/${objectPath ? "" : encode("") + "/"}${encodeURIComponent(
          name
        )}/show`
      )
    },
    [history, objectPath, url]
  )

  const moveFile = React.useCallback(
    (name) => {
      history.push(
        `${url}/${objectPath ? "" : encode("") + "/"}${encodeURIComponent(
          name
        )}/move`
      )
    },
    [history, objectPath, url]
  )

  const copyFile = React.useCallback(
    (name) => {
      history.push(
        `${url}/${objectPath ? "" : encode("") + "/"}${encodeURIComponent(
          name
        )}/copy`
      )
    },
    [history, objectPath, url]
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
      <Route exact path="/containers/:name/objects/:objectPath?/:object/move">
        <CopyFile refresh={loadObjects} deleteAfter />
      </Route>
      <Route exact path="/containers/:name/objects/:objectPath?/:object/copy">
        <CopyFile refresh={loadObjects} showCopyMetadata />
      </Route>
      <Route exact path="/containers/:name/objects/:objectPath?/:object/show">
        <ShowProperties objectStoreEndpoint={objectStoreEndpoint} />
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
              changeDir={(item) => changeDir(item.subdir)}
              deleteFile={(item) => deleteFile(item.name)}
              deleteFolder={(item) => deleteFolder(item.subdir)}
              downloadFile={(item) => downloadFile(item.name)}
              showProperties={(item) => showProperties(item.name)}
              copyFile={(item) => copyFile(item.name)}
              moveFile={(item) => moveFile(item.name)}
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
