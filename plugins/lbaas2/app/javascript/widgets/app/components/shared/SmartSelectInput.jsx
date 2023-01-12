import React, { useMemo, useState, useEffect } from "react"
import {
  useFloating,
  autoUpdate,
  offset,
  shift,
  useDismiss,
  useRole,
  useClick,
  useInteractions,
  FloatingFocusManager,
  useId,
  size,
} from "@floating-ui/react"
import {
  TextInputRow,
  DataGrid,
  DataGridRow,
  DataGridCell,
  Badge,
  LoadingIndicator,
  Stack,
  Message,
  Button,
  Spinner,
} from "juno-ui-components"

// const optionsContainer = `
//   overflow-y: scroll,
//   border-radius: 0.25rem,
//   box-shadow: var(--tw-ring-inset) 0 0 0 calc(2px + var(--tw-ring-offset-width)) var(--tw-ring-color),
//   `

// const optionFilter = `
//   smart-select-options-filter
//   p-3
//   bg-theme-background-lvl-2
//   sticky
//   top-0
//   w-full
// `

// const optionsRow = `
//   smart-select-options-row
//   hover:text-theme-accent
// `

// const optionsNotFoundStatus = `
//   whitespace-nowrap
// `

// const optionsNotFoundFetchMore = `
//   whitespace-nowrap
// `

// const fakeInputText = (isOpen) => {
//   return `
//     smart-select-input
//     text-theme-textinput
//     bg-theme-textinput
//     min-h-[2.5rem]
//     rounded-3px
//     p-2
//     ${isOpen && `ring-2 ring-theme-focus`}
//     `
//     .replace(/\n/g, " ")
//     .replace(/\s+/g, " ")
// }

// const fakeInputTextPlaceholder = `
//   smart-select-input-placeholder
//   opacity-50
// `

// const fakeInputTextOptions = `
//   smart-select-input-selected-option
//   mr-1
// `

const SmartSelectInput = ({
  options,
  isLoading,
  error,
  fetchPromise,
  isFetching,
  fetchStatus,
  fetchButton,
  onOptionClick,
  onOptionRemove,
  selectedOptions,
  searchTerm,
  onSearchTermChange,
}) => {
  const [open, setOpen] = useState(false)

  // set default to empty string if not given
  options = useMemo(() => {
    if (!options) return []
    return options
  }, [options])

  // set default to empty string if not given
  searchTerm = useMemo(() => {
    if (!searchTerm) return ""
    return searchTerm
  }, [searchTerm])

  // set default to empty array if not given
  selectedOptions = useMemo(() => {
    if (!selectedOptions) return []
    return selectedOptions
  }, [selectedOptions])

  //
  // Set up Floating ui
  //
  const { x, y, reference, floating, strategy, context } = useFloating({
    open,
    placement: "bottom-start",
    onOpenChange: setOpen,
    middleware: [
      offset(8),
      shift(),
      size({
        apply({ rects, elements, availableHeight }) {
          Object.assign(elements.floating.style, {
            maxHeight: `${availableHeight}px`,
            width: `${rects.reference.width}px`,
          })
        },
        padding: 10,
      }),
    ],
    whileElementsMounted: autoUpdate,
  })

  const click = useClick(context, {
    toggle: true,
    event: "mousedown",
  })
  const dismiss = useDismiss(context, {
    referencePress: true,
  })
  const role = useRole(context)

  const { getReferenceProps, getFloatingProps } = useInteractions([
    click,
    dismiss,
    role,
  ])

  const headingId = useId()

  //
  // Callbacks
  //
  const onOptionClicked = (option) => {
    if (onOptionClick) onOptionClick(option)
  }

  const onOptionDeselected = (option) => {
    if (onOptionRemove) onOptionRemove(option)
  }

  return (
    <div>
      <div
        className={`fakeInputText ${open ? "fakeInputText-focus" : ""}`}
        ref={reference}
        {...getReferenceProps()}
      >
        {selectedOptions.length > 0 ? (
          <>
            {selectedOptions.map((item, index) => (
              <Badge
                className="fakeInputTextOptions"
                key={index}
                icon="deleteForever"
                text={item.label}
                variant="info"
                onClick={() => onOptionDeselected(item)}
              />
            ))}
          </>
        ) : (
          <div className="fakeInputTextPlaceholder">Select...</div>
        )}
      </div>

      {open && (
        <FloatingFocusManager context={context} modal={false}>
          <div
            ref={floating}
            className="optionsContainer"
            style={{
              position: strategy,
              top: y ?? 0,
              left: x ?? 0,
            }}
            aria-labelledby={headingId}
            {...getFloatingProps()}
          >
            <div className="optionFilter">
              <Stack alignment="center">
                <TextInputRow
                  className="optionFilterInput"
                  label="Filter"
                  value={searchTerm}
                  onChange={onSearchTermChange}
                  // disabled={!options || options.length === 0}
                />
                {searchTerm && fetchPromise && (
                  <Stack alignment="center" className="optionFilterActions">
                    {fetchStatus && (
                      <span className="optionsNotFoundStatus">
                        {fetchStatus}
                      </span>
                    )}
                    {isFetching && <Spinner variant="primary" />}
                    {fetchButton && fetchButton}
                  </Stack>
                )}
              </Stack>
            </div>
            <DataGrid id={headingId} columns={1}>
              {error && (
                <DataGridRow>
                  <DataGridCell>
                    <Message text={error} variant="error" />
                  </DataGridCell>
                </DataGridRow>
              )}

              {isLoading && (
                <DataGridRow>
                  <DataGridCell>
                    <Stack alignment="center">
                      <LoadingIndicator color="jn-text-theme-info" size="40" />
                      <span>Loading Options...</span>
                    </Stack>
                  </DataGridCell>
                </DataGridRow>
              )}

              {options.length > 0 && (
                <>
                  {options.map((option, i) => (
                    <DataGridRow
                      key={i}
                      onClick={() => onOptionClicked(option)}
                      className="optionsRow"
                    >
                      <DataGridCell>{option.label}</DataGridCell>
                    </DataGridRow>
                  ))}
                </>
              )}

              {(!options || options.length === 0) && (
                <DataGridRow>
                  <DataGridCell>
                    <span>No options available</span>
                  </DataGridCell>
                </DataGridRow>
              )}
            </DataGrid>
          </div>
        </FloatingFocusManager>
      )}
    </div>
  )
}

import { querySecretsForSelect } from "../../../../queries/listener"
import { fetchSecretsForSelect } from "../../actions/listener"
import { useQuery } from "react-query"
import { errorMessage } from "../../helpers/commonHelpers"

const regexString = (string) => string.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&")

const SmartSelectWrapper = () => {
  const [isFetching, setIsFetching] = useState(false)
  const [selectedOptions, setSelectedOptions] = useState([])
  const [displayOptions, setDisplayOptions] = useState(false)
  const [fetchedOptions, setFetchedOptions] = useState([])
  const [searchTerm, setSearchTerm] = useState("")
  const [showFetchMore, setShowMore] = useState(false)
  const [fetchStatus, setFetchStatus] = useState({})
  const [fetchParams, setFetchParams] = useState({ offset: 0, limit: 1 })

  const secrets = querySecretsForSelect({ limit: 10 })

  // create the query action with the promise used by useQuery. Needed to get access to the fetchParams
  const fetchAction = ({ queryKey }) => {
    const [_key, fetchParams] = queryKey
    return fetchSecretsForSelect(fetchParams)
  }

  // Query to used to fetch more options
  const newFetchedOptions = useQuery(
    ["fetchOptions", fetchParams],
    fetchAction,
    {
      // The query will not execute until it is triggered by the isFetching boolean
      enabled: !!isFetching,
      // do not refetch on focus since it would add existing items to the fetched options array
      refetchOnWindowFocus: false,
      // use the callback to add the fetched options
      onSuccess: (data) => {
        console.log("DATA: ", data)
        if (data?.options && data?.options?.length > 0) {
          setFetchedOptions([...fetchedOptions, ...data.options])
        } else {
          // if no more options stop fetching
          setIsFetching(false)
        }
        if (data?.total) {
          setFetchStatus({ ...fetchStatus, total: data?.total })
        }
      },
    }
  )

  // recalculate the offset when we get new fetched options
  useEffect(() => {
    if (fetchedOptions.length > 0) {
      const offset =
        (secrets.data?.options?.length || 0) + fetchedOptions.length
      console.log("offset: ", offset)
      if (offset < fetchStatus.total) {
        console.log("continue!! FETCHING")
        setFetchParams({ ...fetchParams, offset: offset, limit: 100 })
        setFetchStatus({
          ...fetchStatus,
          message: `${offset} / ${fetchStatus.total}`,
        })
      } else {
        console.log("close FETCHING")
        setIsFetching(false)
      }
    }
  }, [fetchedOptions])

  // compute difference between the given default options with the fetched from api
  // and the selected so the same option can't be selected more then one time
  useEffect(() => {
    // collect options
    const newOptions = secrets.data?.options || []
    const collectedOptions = [...newOptions, ...fetchedOptions]
    if (collectedOptions) {
      const difference = collectedOptions.filter(
        ({ value: id1 }) =>
          !selectedOptions.some(({ value: id2 }) => id2 === id1)
      )
      // filter the difference with the filter string given by the user
      const regex = new RegExp(regexString(searchTerm.trim()), "i")
      const filteredOptions = difference.filter(
        (i) => `${i.label}`.search(regex) >= 0
      )
      setDisplayOptions(filteredOptions)
    }
  }, [selectedOptions, secrets.data?.options, fetchedOptions, searchTerm])

  const onFetchClick = (event) => {
    setIsFetching(true)
    const offset = secrets.data?.options?.length || 0 + fetchedOptions.length
    setFetchParams({ ...fetchParams, offset: offset, limit: 1 })
  }
  const onFetchCancel = (event) => {
    setIsFetching(false)
  }

  const onOptionClick = (option) => {
    setSelectedOptions([...selectedOptions, option])
  }

  const onOptionRemove = (option) => {
    const index = selectedOptions.findIndex(
      (item) => item.value == option.value
    )
    if (index < 0) {
      return
    }
    let newOptions = selectedOptions.slice()
    newOptions.splice(index, 1)
    setSelectedOptions(newOptions)
  }

  const onSearchTermChange = (event) => {
    setSearchTerm(event.target.value)
  }

  const fetchButton = useMemo(() => {
    if (!isFetching) {
      return (
        <Button
          className="optionsNotFoundFetchMore"
          icon="widgets"
          label="Fetch more"
          onClick={onFetchClick}
          size="small"
        />
      )
    } else {
      return (
        <Button
          className="optionsNotFoundFetchMore"
          icon="cancel"
          label="Cancel"
          onClick={onFetchCancel}
          variant="primary-danger"
          size="small"
        />
      )
    }
  }, [isFetching])

  return (
    <SmartSelectInput
      // options
      options={displayOptions}
      onOptionClick={onOptionClick}
      onOptionRemove={onOptionRemove}
      selectedOptions={selectedOptions}
      // fetch
      showFetchMore={showFetchMore}
      isFetching={isFetching}
      fetchStatus={fetchStatus?.message}
      fetchButton={fetchButton}
      // searchTerm
      onSearchTermChange={onSearchTermChange}
      searchTerm={searchTerm}
      // states
      isLoading={secrets.isLoading}
      error={secrets.error && errorMessage(secrets.error)}
      fetchPromise={fetchSecretsForSelect}
    />
  )
}

export default SmartSelectWrapper
