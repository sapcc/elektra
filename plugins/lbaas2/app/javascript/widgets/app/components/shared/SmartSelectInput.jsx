import React, { useMemo, useState, useEffect, CSSProperties } from "react"
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
// `

// const optionsRow = `
//   smart-select-options-row
//   hover:text-theme-accent
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
  - @options: fix small amount (max 50) of options to display at the beginning
  - @isLoading: display a loading element to wait until the options are ready to display
  - @error: display an error when fetching options fails
  - @fetchCallback: if set will be called to fetch more options when filtering
*/
const SmartSelectInput = ({ options, isLoading, error, fetchCallback }) => {
  const [open, setOpen] = useState(false)
  const [selectedOptions, setSelectedOptions] = useState([])
  const [displayOptions, setDisplayOptions] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")

  // options = useMemo(() => {
  //   if (!options) return []
  //   return options
  // }, [options])

  // compute difference between the given default options or the fetched by callback
  // and the selected so the same option can't be selected more then one time
  useEffect(() => {
    if (options) {
      const difference = options.filter(
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
  }, [selectedOptions, options, searchTerm])

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

  const onOptionClicked = (option) => {
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
              <TextInputRow
                label="Filter"
                value={searchTerm}
                onChange={onSearchTermChanges}
              />
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
              {displayOptions.length === 0 && searchTerm && (
                <DataGridRow>
                  <DataGridCell>No options found</DataGridCell>
                </DataGridRow>
              )}
            </DataGrid>
          </div>
        </FloatingFocusManager>
      )}
    </div>
  )
}

export default SmartSelectInput
