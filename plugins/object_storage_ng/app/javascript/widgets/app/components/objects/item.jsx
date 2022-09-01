import React from "react"
import { Unit } from "lib/unit"
import { Dropdown, MenuItem } from "react-bootstrap"
import { useRouteMatch, useHistory, useParams } from "react-router-dom"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"
import apiClient from "../../lib/apiClient"
import TimeAgo from "../shared/TimeAgo"
import ItemsCount from "../shared/ItemsCount"
import FileIcon from "./FileIcon"
import useActions from "../../hooks/useActions"
const unit = new Unit("B")

const ObjectItem = ({ item, currentPath }) => {
  let { url } = useRouteMatch()
  let { encode } = useUrlParamEncoder()
  const { name } = useParams()
  let history = useHistory()
  let objectsRoot = url.replace(/([^\/])\/objects.*/, "$1/objects")
  const [isProcessing, setIsProcessing] = React.useState()
  const [error, setError] = React.useState()
  const { loadObjectMetadata, deleteObject } = useActions()

  const deleteMe = React.useCallback(
    (options = {}) => {
      console.log("============", item)

      setIsProcessing("Deleting")
      setError(null)

      Promise.resolve()
        .then(async() => {
          if (options.keepSegments) {
            return deleteObject(name, item.name)
          } else {
            loadObjectMetadata(name, encodeURIComponent(item.name)).then(
              (headers) => {
                // slo: static large object
                // dlo: dynamic large object
                const slo = headers["x-static-large-object"]
                const dloManifest = headers["x-object-manifest"]
                if (slo) {
                  return deleteObject(
                    name,
                    item.name + "?multipart-manifest=delete"
                  )
                } else if (dloManifest) {
                  return deleteObject(name, item.name).then(() => {
                    const [container, path] = dloManifest.split("/", 1)
                    // TODO: delete folder
                  })
                } else {
                  return deleteObject(name, item.name)
                }
              }
            )
          }
        })
        .catch((error) => setError(error.message))
        .finally(() => setIsProcessing(null))

      // const deleteFolder = (container_name, object_path) => {
      // prefix = object_path
      // prefix += "/" unless object_path.ends_with?("/")
      // targets = list_objects_below_path(
      //   container_name, prefix
      // ).map do |obj|
      //   { container: container_name, object: obj.path }
      // end
      // bulk_delete(targets)
      // }
      // if(keepSegments){
      //   elektron_object_storage.delete("#{container_name}/#{object.path}")
      // }else{
      //   if(object.slo) {
      //     elektron_object_storage.delete("#{container_name}/#{object.path}?multipart-manifest=delete")
      //   } else if {object.dlo
      //     // delete dlo manifest
      //     elektron_object_storage.delete("#{container_name}/#{object.path}")
      //     // delete segments container
      //     delete_folder(object.dlo_segments_container,object.dlo_segments_folder_path)
      //   }else{
      //     elektron_object_storage.delete("#{container_name}/#{object.path}")
      //   }
      // }
      // // return nil because nothing usable is returned from the API
      // return nil
    },
    [loadObjectMetadata, deleteObject, name, item.name]
  )

  const handleSelect = React.useCallback(
    (e) => {
      console.log("==========================handleSelect", e)
      switch (e) {
        case "1":
          return history.push(`/containers/${name}/properties`)
        case "2":
          return history.push(`/containers/${name}/access-control`)
        case "3":
          return history.push(`/containers/${name}/empty`)
        case "4":
          return history.push(`/containers/${name}/delete`)
        case "5":
          deleteMe()
          break
        default:
          return
      }
    },
    [name, history]
  )

  const downloadUrl = React.useMemo(
    () => `containers/${name}/objects/download?path=${item.path + item.name}`,
    [name, item]
  )

  return (
    <tr>
      <td>
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
          <a href={downloadUrl}>{item.display_name || item.name}</a>
        )}
      </td>
      <td>
        {isProcessing ? (
          <span>
            <span className="spinner" />
            {isProcessing}
          </span>
        ) : error ? (
          <span className="text-danger">{error}</span>
        ) : (
          <TimeAgo date={item.last_modified} originDate />
        )}
      </td>
      <td>{unit.format(item.bytes)}</td>
      <td className="snug">
        <Dropdown
          id={`object-dropdown-${item.path}-${item.name}`}
          pullRight
          onSelect={handleSelect}
        >
          <Dropdown.Toggle noCaret className="btn-sm">
            <span className="fa fa-cog" />
          </Dropdown.Toggle>

          {item.folder ? (
            <Dropdown.Menu>
              <MenuItem eventKey="1">Delete recursively</MenuItem>
            </Dropdown.Menu>
          ) : (
            <Dropdown.Menu className="super-colors">
              <MenuItem href={downloadUrl}>Download</MenuItem>

              <MenuItem divider />
              <MenuItem eventKey="2">Properties</MenuItem>
              <MenuItem divider />

              <MenuItem eventKey="3">Copy</MenuItem>
              <MenuItem eventKey="4">Move/Rename</MenuItem>
              <MenuItem eventKey="5">Delete</MenuItem>
              <MenuItem eventKey="6">Delete (keep segments)</MenuItem>
            </Dropdown.Menu>
          )}
        </Dropdown>
      </td>
    </tr>
  )
}

export default ObjectItem
