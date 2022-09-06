import React from "react"
import PropTypes from "prop-types"
import { FixedSizeList as List } from "react-window"
import scrollbarWidth from "../../lib/scrollbarWidth"

/**
 * Example:
 *  <VirtualizedTable
 *    height={400}
 *    width={1140}
 *    rowHeight={50}
 *    columns={columns}
 *    data={containers.items || []}
 *    renderRow={Row}
 *    renderHeader={({ column1 }) =>
        column1(<span style={{ color: "red" }}>TEST</span>)
      } 
 *    showHeader
 *  />
 */
/**
 * Calculate column widths based on total width and columns config
 * @param {object} properties width and columns
 * @returns an array of widths
 */
const calculateColumWidth = ({ width, columns }) => {
  // count invalid width values
  let count = 0
  // unused width
  let restWidth = width
  // valid types
  const validTypes = ["number", "string"]
  // for all columns
  let widths = columns.map((column) => {
    const type = typeof column.width
    // return null unless type of width is valid
    if (validTypes.indexOf(type) < 0) {
      count += 1
      return null
    }

    // parse value to get number
    let value = parseInt(column.width)
    if (type === "string" && column.width.slice(-1) === "%") {
      // precentage to value
      value = parseInt((value * width) / 100)
    }

    restWidth -= value
    if (restWidth < 0) restWidth = 0
    return value
  })

  // calculate missing widths and return
  return widths.map((value) => value || restWidth / count)
}

const SortIcon = ({ strategy, direction }) => {
  const sortIconType = React.useMemo(
    () => (strategy == "text" ? "alpha" : "amount"),
    [strategy]
  )
  return (
    <i
      className={`fa fa-sort-${sortIconType}-${direction || "asc"} ${
        !direction && "virtualized-table-sortable-icon-disabled"
      }`}
    />
  )
}

/**
 * React Component to render large data table
 * @param {object} props
 * @returns
 */
const VirtualizedTable = ({
  width,
  height,
  columns,
  data,
  rowHeight,
  renderHeader,
  showHeader,
  renderRow,
  className,
}) => {
  className = className || "virtualized-table"

  const holderElement = React.createRef()

  // extend columns
  columns = React.useMemo(() => {
    // calculate widths and extend columns
    const widths = calculateColumWidth({ width, columns })
    return columns.map((column, index) => {
      column.width = widths[index]
      return column
    })
  }, [columns, width])

  // this function returns callbacks to get column contents of a row
  // it is a closure
  const rowColumnContentCallbacks = React.useMemo(() => {
    let columnContents

    const columnCallbacks = {}
    for (let i = 0; i < columns.length; i++) {
      columnCallbacks[`column${i + 1}`] = (result) =>
        (columnContents[i] = result || "")
    }

    // return a function which resets on every call the contents array
    return () => {
      columnContents = Array(columns.length)
      return { columnCallbacks, columnContents }
    }
  }, [columns.length])

  // row component
  const Row = React.useCallback(
    ({ index, style }) => {
      const item = data[index]

      // columns is a map, e.g. { "column1": (result) => {content[0] = result}, "column2": (result) => {content[1] = result},...}
      // renderRow must call this functions
      const { columnContents, columnCallbacks } = rowColumnContentCallbacks() // reset columnContents variable
      if (renderRow) {
        // get column contents from renderRow function
        renderRow({ ...columnCallbacks, item })
      }

      return (
        <div
          style={{ ...style, display: "flex" }}
          className={`${className}-tr ${className}-tr-${
            index % 2 === 0 ? "even" : "odd"
          }`}
        >
          {columns.map((column, index) => (
            <div
              key={index}
              style={{ width: column.width }}
              className={`${className}-td`}
            >
              {columnContents[index] || item[column.accessor] || ""}
            </div>
          ))}
        </div>
      )
    },
    [data, columns, rowColumnContentCallbacks, renderRow]
  )

  // head row component
  const Header = React.useCallback(() => {
    // columns is a map, e.g. { "column1": (result) => {content[0] = result}, "column2": (result) => {content[1] = result},...}
    // renderRow must call this functions
    const { columnContents, columnCallbacks } = rowColumnContentCallbacks() // reset columnContents variable
    if (renderHeader) {
      // get column contents from renderRow function
      renderHeader({ ...columnCallbacks, columns })
    }

    return (
      <div
        style={{ display: "flex", width: width - scrollbarWidth() }}
        className={`${className}-tr ${className}-tr-head`}
      >
        {columns.map((column, index) => (
          <div
            key={index}
            className={`${className}-th`}
            style={{
              width: column.width,
              display: "flex",
              justifyContent: "space-between",
            }}
          >
            {columnContents[index] || column.label}

            {column.sortable && (
              <span className={`${className}-sortable`}>
                <SortIcon strategy={column.sortable} />
              </span>
            )}
          </div>
        ))}
      </div>
    )
  }, [width, columns, className, rowColumnContentCallbacks, renderHeader])

  console.log("holderElement", holderElement)

  return (
    <div className={className} ref={holderElement}>
      {(showHeader || renderHeader) && <Header />}

      <List
        height={height}
        itemCount={data.length}
        itemSize={rowHeight}
        width={width}
      >
        {Row}
      </List>
    </div>
  )
}

VirtualizedTable.propTypes = {
  width: PropTypes.number,
  height: PropTypes.number,
  columns: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string,
      accessor: PropTypes.string,
      width: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
      sortable: PropTypes.bool,
    })
  ).isRequired,
  data: PropTypes.arrayOf(PropTypes.object).isRequired,
  rowHeight: PropTypes.number,
  renderHeader: PropTypes.func,
  renderRow: PropTypes.func,
  className: PropTypes.string,
  showHeader: PropTypes.oneOf([true, false, "amount", "text"]),
}

export default VirtualizedTable
