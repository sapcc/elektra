import React from "react"
import { VariableSizeGrid as Grid, FixedSizeList as List } from "react-window"
import scrollbarWidth from "../lib/scrollbarWidth"

const useVirtualizedTable = ({
  width,
  height,
  columns,
  data,
  rowHeight,
  renderRow,
  className,
}) => {
  className = className || "virtualized-table"

  const holderElement = React.createRef()

  let columnWidths = React.useMemo(() => {
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
  }, [columns, width])

  const Row = React.useCallback(
    ({ index, style }) => {
      if (!renderRow) return <div style={style}>Row {index}</div>

      const content = Array(columnWidths.length)
      columns = columnWidths.reduce((map, width, index) => {
        map[`column${index + 1}`] = (result) =>
          (content[index] = (
            <div key={index} style={{ width }} className={`${className}-td`}>
              {result}
            </div>
          ))
        return map
      }, {})

      renderRow({ ...columns, item: data[index] })
      return (
        <div
          style={{ ...style, display: "flex" }}
          className={`${className}-tr ${className}-tr-${
            index % 2 === 0 ? "even" : "odd"
          }`}
        >
          {content}
        </div>
      )
    },
    [data, columnWidths, renderRow]
  )

  const Header = React.useCallback(
    () => (
      <div
        style={{ display: "flex" }}
        className={`${className}-tr ${className}-tr-head`}
      >
        {columns.map((column, index) => (
          <div
            key={index}
            className={`${className}-th`}
            style={{
              width: columnWidths[index],
            }}
          >
            {column.label}
          </div>
        ))}
      </div>
    ),
    [columnWidths, columns]
  )

  console.log("holderElement", holderElement)

  const Table = React.useCallback(
    () => (
      <div className={className} ref={holderElement}>
        <Header />
        <List
          height={height}
          itemCount={data.length}
          itemSize={rowHeight}
          width={width + scrollbarWidth()}
        >
          {Row}
        </List>
      </div>
    ),
    [Row, data, width, Header]
  )

  return {
    Table,
    columnWidths,
  }
}

export default useVirtualizedTable
