import React from "react"
import { VariableSizeGrid as Grid } from "react-window"
import scrollbarWidth from "../lib/scrollbarWidth"

const useVirtualizedTable = ({
  width,
  height,
  columns,
  data,
  rowHeight,
  renderCell,
}) => {
  let columnWidths = React.useMemo(() => {
    // count valid width values
    let count = 0
    // unused width
    let restWidth = width
    // valid types
    const validTypes = ["number", "string"]
    // for all columns
    let widths = columns.map((column) => {
      const type = typeof column.width
      // return null unless type of width is valid
      if (validTypes.indexOf(type) < 0) return null

      // parse value to get number
      let value = parseInt(column.width)
      if (type === "string" && column.width.slice(-1) === "%") {
        // precentage to value
        value = parseInt((value * width) / 100)
      }
      count += 1
      restWidth -= value
      if (restWidth < 0) restWidth = 0
      return value
    })
    // calculate missing widths and return
    return widths.map((value) => value || restWidth / count)
  }, [columns, width])

  const Cell = React.useCallback(
    ({ columnIndex, rowIndex, style }) => (
      <div style={style} className="virtualized-table-td">
        {renderCell({ rowIndex, columnIndex, item: data[rowIndex] })}
      </div>
    ),
    [data, renderCell]
  )

  const Header = React.useCallback(
    () => (
      <div style={{ display: "flex" }}>
        {columns.map((column, index) => (
          <div
            key={index}
            className="virtualized-table-th"
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

  const Table = React.useCallback(
    () => (
      <>
        <Header />
        <Grid
          columnCount={columnWidths.length}
          columnWidth={(index) => columnWidths[index]}
          height={height}
          rowCount={data.length}
          rowHeight={(index) => rowHeight}
          width={width + scrollbarWidth()}
        >
          {Cell}
        </Grid>
      </>
    ),
    [Cell, columnWidths, data, width]
  )

  return {
    Table,
    columnWidths,
  }
}

export default useVirtualizedTable
