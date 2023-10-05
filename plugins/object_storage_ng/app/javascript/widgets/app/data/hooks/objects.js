import { useStore } from "../StoreProvider"
import { apiClient } from "../../lib/apiClient"

const containerPath = (containerName) =>
  encodeURIComponent(decodeURIComponent(containerName))

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
const loadAllObjects = async (containerName, prefix = "") => {
  let objects = await apiClient
    .osApi("object-store")
    .get(containerPath(containerName), { params: { prefix, delimiter: "/" } })
    .then((response) => response.data)

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
  let objectsStartingWithSlash = await loadAllObjects(containerName, newPrefix)
  // add new objects to the root objects
  let newObjects = objects.concat(objectsStartingWithSlash)

  // remove duplicates
  return newObjects.filter((item, index) => newObjects.indexOf(item) === index)
}

export const useObjectsContainerName = () =>
  useStore((state) => state.objects.containerName)
export const useObjectsPath = () => useStore((state) => state.objects.path)
export const useObjectsItems = () => useStore((state) => state.objects.items)
export const useObjectsIsFetching = () =>
  useStore((state) => state.objects.isFetching)

export const useObjectsError = () => useStore((state) => state.objects.error)

export const useObjectsUpdatedAt = () =>
  useStore((state) => state.objects.updatedAt)

// load data from API and store it in the state. Manage also loading and error states
export const useLoadContainerObjects = () => {
  const isFetching = useObjectsIsFetching()
  const { request, receive, receiveError } = useStore(
    (state) => state.containers.actions
  )

  return (containerName, path) => {
    if (isFetching) return

    request(containerName, path)
    loadAllObjects(containerName, path)
      .then((items) => {
        // extend items with display_name and sort
        items.forEach((i) => {
          // display name
          let dn = (i.name || i.subdir).replace(path, "")
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
        receive(items)
      })
      .catch((error) => receiveError(error.message))
  }
}
