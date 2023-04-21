import { useState, useEffect } from "react"
import { fetchSecrets } from "../secretActions"
import { useQuery } from "@tanstack/react-query"

const regexString = (string) => string.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&")
const FETCH_LIMIT = 10

const useSecretsSearch = () => {
  const [isFetching, setIsFetching] = useState(false)
  const [fetchParams, setFetchParams] = useState({ offset: 0, limit: 1 })
  const [fetchedOptions, setFetchedOptions] = useState([])
  const [fetchStatus, setFetchStatus] = useState({})
  const [displayResults, setDisplayResults] = useState([])
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedOptions, setSelectedOptions] = useState([])

  // create the query action with the promise used by useQuery. Needed to get access to the fetchParams
  const fetchAction = ({ queryKey }) => {
    const [_key, fetchParams] = queryKey
    return fetchSecrets(fetchParams)
  }

  // Query to used to fetch more options
  const { data } = useQuery(["fetchOptions", fetchParams], fetchAction, {
    // The query will not execute until it is triggered by the isFetching boolean
    enabled: !!isFetching,
    // do not refetch on focus since it would add existing items to the fetched options array
    refetchOnWindowFocus: false,
    // use the callback to add the fetched options
    onSuccess: (data) => {
      if (data?.total) {
        setFetchStatus({ ...fetchStatus, total: data.total })
      }
      if (data?.secrets && data?.secrets?.length > 0) {
        setFetchedOptions([...fetchedOptions, ...data.secrets])
      } else {
        // if no more options stop fetching
        setIsFetching(false)
      }
    },
  })

  // recalculate the offset when we get new fetched options
  useEffect(() => {
    if (fetchedOptions.length > 0) {
      const offset = fetchedOptions.length
      if (offset < fetchStatus.total) {
        setFetchParams({ ...fetchParams, offset: offset, limit: FETCH_LIMIT })
        setFetchStatus({
          ...fetchStatus,
          message: `${offset} / ${fetchStatus.total}`,
        })
      } else {
        setIsFetching(false)
      }
    }
  }, [fetchedOptions])

  // compute difference between the fetched from api
  // and the selected so the same option can't be selected more then one time
  useEffect(() => {
    if (fetchedOptions) {
      // remove selected options
      const difference = fetchedOptions.filter(
        ({ secret_ref: id1 }) =>
          !selectedOptions.some(({ secret_ref: id2 }) => id2 === id1)
      )
      // filter the difference with the filter string given by the user
      const regex = new RegExp(regexString(searchTerm.trim()), "i")
      const filteredOptions = difference.filter(
        (i) => `${i.name}`.search(regex) >= 0
      )
      setDisplayResults(filteredOptions)
    }
  }, [selectedOptions, fetchedOptions, searchTerm])

  const searchFor = (text) => {
    setSearchTerm(text)
    setIsFetching(true)
    const offset = fetchedOptions.length
    setFetchParams({ ...fetchParams, offset: offset, limit: 1 })
  }
  const setMoreSelectedOptions = (options) => {
    setSelectedOptions(options)
  }
  const cancel = () => {
    setIsFetching(false)
  }

  return {
    displayResults,
    isFetching,
    fetchStatus,
    searchFor,
    setMoreSelectedOptions,
    cancel,
  }
}

export default useSecretsSearch
