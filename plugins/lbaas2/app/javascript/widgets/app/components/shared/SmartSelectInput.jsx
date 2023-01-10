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
import { QueryClient, QueryClientProvider, useQuery } from "react-query"

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

const regexString = (string) => string.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&")

/*  
  - @options: fix small amount (max 50) of options to display
    Ex: 
        [{
          "label": "HN_TEST_1",
          "value": "df7e-48c1-aca2-5c700d5382b6"
        },
        {
          "label": "HN_TEST_4",
          "value": "e11a-4e8a-ba90-7ecf02858342"
        }]
  - @isLoading: display a loading element to wait until the options are ready to display
    Ex: used when the default options are being fetched and the select is already displayed
  - @error: display a custom error
    Ex: used when getting an error while fetching the default options
  - @fetchPromise(params): promise called when fetching more options
    Return object ex:
        {
          options: [...],
          total: 1345,
        }
  - @onSelectedChange: callback function called when the selected options changed
*/

// TODO: show message on api error
// TODO: just display default options when not filtering
// TODO: callback to return the options selected
const SmartSelectInput = ({
  options,
  isLoading,
  error,
  fetchPromise,
  onSelectedChange,
}) => {
  const [open, setOpen] = useState(false)
  const [callbackEnabled, setCallbackEnabled] = useState(false)
  const [selectedOptions, setSelectedOptions] = useState([])
  const [displayOptions, setDisplayOptions] = useState(false)
  const [fetchedOptions, setFetchedOptions] = useState([])
  const [searchTerm, setSearchTerm] = useState("")
  const [isFetching, setIsFetching] = useState(false)
  const [fetchParams, setFetchParams] = useState({ offset: 0, limit: 1 })
  const [fetchStatus, setFetchStatus] = useState({ total: 0 })

  // create the query action with the promise used by useQuery. Needed to get access to the fetchParams
  const fetchAction = ({ queryKey }) => {
    const [_key, fetchParams] = queryKey
    return fetchPromise(fetchParams)
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
      const offset = (options.length || 0) + fetchedOptions.length
      console.log("offset: ", offset)
      if (offset < fetchStatus.total) {
        console.log("continue!! FETCHING")
        setFetchParams({ ...fetchParams, offset: offset, limit: 100 })
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
    const newOptions = options || []
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
  }, [selectedOptions, options, fetchedOptions, searchTerm])

  // notify when selectedOptions changes
  useEffect(() => {
    if (callbackEnabled && onSelectedChange) {
      console.log("selectedOptions changed: ", selectedOptions)
    }
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
    setCallbackEnabled(true)
    setSelectedOptions([...selectedOptions, option])
  }

  const onOptionDeselected = (option) => {
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

  const onSearchTermChanges = (event) => {
    setSearchTerm(event.target.value)
  }

  const onFetchMore = () => {
    setIsFetching(true)
    const offset = options.length || 0 + fetchedOptions.length
    setFetchParams({ ...fetchParams, offset: offset, limit: 1 })
  }

  const onFetchCancel = () => {
    setIsFetching(false)
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
                  onChange={onSearchTermChanges}
                  disabled={!options || options.length === 0}
                />
                {searchTerm && fetchPromise && (
                  <Stack alignment="center" className="optionFilterActions">
                    {!isFetching ? (
                      <Button
                        className="optionsNotFoundFetchMore"
                        icon="widgets"
                        label="Fetch more"
                        onClick={onFetchMore}
                        size="small"
                      />
                    ) : (
                      <>
                        <span className="optionsNotFoundStatus">{`${fetchParams.offset} / ${fetchStatus.total}`}</span>
                        <Spinner variant="primary" />
                        <Button
                          className="optionsNotFoundFetchMore"
                          icon="cancel"
                          label="Cancel"
                          onClick={onFetchCancel}
                          variant="primary-danger"
                          size="small"
                        />
                      </>
                    )}
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

              {displayOptions.length > 0 && (
                <>
                  {displayOptions.map((option, i) => (
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

              {searchTerm && displayOptions.length === 0 && (
                <DataGridRow>
                  <DataGridCell>
                    <span>No options found</span>
                  </DataGridCell>
                </DataGridRow>
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

const SmartSelect = (props) => {
  // Create an own query client
  const queryClient = new QueryClient()

  return (
    <QueryClientProvider client={queryClient}>
      <SmartSelectInput {...props} />
    </QueryClientProvider>
  )
}

export default SmartSelect
