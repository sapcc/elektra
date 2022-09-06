import React from "react"
import styled from "styled-components"
import {
  useTable,
  useSortBy,
  useResizeColumns,
  useBlockLayout,
} from "react-table"
import { FixedSizeList as List, VariableSizeGrid as Grid } from "react-window"
import scrollbarWidth from "./scrollbarWidth"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"
import AutoSizer from "react-virtualized-auto-sizer"

// const Styles = styled.div`
//   padding: 1rem;

//   .table {
//     display: inline-block;
//     border-spacing: 0;

//     .tr {
//       border-top: 1px solid #ddd;
//     }
//     .head .tr {
//       border-bottom: 1px solid #ddd;
//       border-top: none;
//     }

//     .th,
//     .td {
//       margin: 0;
//       padding: 0.5rem;

//       position: relative;

//       .resizer {
//         display: inline-block;
//         background: blue;
//         width: 10px;
//         height: 100%;
//         position: absolute;
//         right: 0;
//         top: 0;
//         transform: translateX(50%);
//         z-index: 1;
//         ${"" /* prevents from scrolling while dragging on touch devices */}
//         touch-action:none;
//         &.isResizing {
//           background: red;
//         }
//       }
//     }
//   }
// `

// function Table({ columns, data }) {
//   // Use the state and functions returned from useTable to build your UI
//   const scrollBarSize = React.useMemo(() => scrollbarWidth(), [])

//   const defaultColumn = React.useMemo(
//     () => ({
//       minWidth: 30,
//       width: 150,
//       maxWidth: 400,
//     }),
//     []
//   )
//   const {
//     getTableProps,
//     getTableBodyProps,
//     headerGroups,
//     rows,
//     totalColumnsWidth,
//     prepareRow,
//     state,
//   } = useTable(
//     {
//       columns,
//       data,
//       defaultColumn,
//     },
//     useBlockLayout,
//     useSortBy,
//     useResizeColumns
//   )

//   const RenderRow = React.useCallback(
//     ({ index, style }) => {
//       const row = rows[index]
//       prepareRow(row)
//       return (
//         <div
//           {...row.getRowProps({
//             style,
//           })}
//           className="tr"
//         >
//           {row.cells.map((cell, i) => {
//             console.log("cell", cell)
//             return (
//               <div key={i} {...cell.getCellProps()} className="td">
//                 {cell.render("Cell")}
//               </div>
//             )
//           })}
//         </div>
//       )
//     },
//     [prepareRow, rows]
//   )

//   console.log("====================getTableProps", getTableProps())
//   // Render the UI for your table
//   return (
//     <div {...getTableProps()} className="table">
//       {/* HEADER */}
//       <div className="head">
//         {headerGroups.map((headerGroup, i) => (
//           <div
//             key={i}
//             {...headerGroup.getHeaderGroupProps({ style: { width: "100%" } })}
//             className="tr"
//             // style={{ width: "100%" }}
//           >
//             {headerGroup.headers.map((column, j) => (
//               <div
//                 key={j}
//                 {...column.getHeaderProps(column.getSortByToggleProps())}
//                 className="th"
//               >
//                 {column.render("Header")}
//                 {/* Add a sort direction indicator */}
//                 <span>
//                   {column.isSorted ? (column.isSortedDesc ? " 🔽" : " 🔼") : ""}
//                 </span>
//                 <div
//                   {...column.getResizerProps()}
//                   className={`resizer ${column.isResizing ? "isResizing" : ""}`}
//                 />
//               </div>

//               // <div
//               //   test={console.log("::::::::::::::", column)}
//               //   key={j}
//               //   {...column.getHeaderProps()}
//               //   className="th"
//               // >
//               //   {column.render("Header")}
//               // </div>
//             ))}
//           </div>
//         ))}
//       </div>

//       {/* BODY */}

//       <AutoSizer>
//         {({ height, width }) => (
//           <div {...getTableBodyProps()} className="body">
//             <FixedSizeList
//               height={400}
//               itemCount={rows.length}
//               itemSize={50}
//               width={width + scrollBarSize}
//             >
//               {RenderRow}
//             </FixedSizeList>
//           </div>
//         )}
//       </AutoSizer>
//     </div>
//   )
// }

// function App() {
//   const containers = useGlobalState("containers")
//   const { loadContainersOnce } = useActions()

//   React.useEffect(() => {
//     loadContainersOnce()
//   }, [loadContainersOnce])

//   const columns = React.useMemo(
//     () => [
//       {
//         Header: "Container name",
//         accessor: "name",
//       },
//       { Header: "Last modified", accessor: "last_modified" },
//       { Header: "Total size", accessor: "bytes" },
//       { Header: "", id: "actions" },
//     ],
//     []
//   )

//   const data = React.useMemo(() => containers.items || [], [containers.items])

//   console.log("================", data)
//   return (
//     <Styles>
//       <Table columns={columns} data={data} />
//     </Styles>
//   )
// }

// export default App

const Styles = styled.div`
  .row {
    border-top: 1px solid #ddd;
  }

  .head .row {
    border-rop: none;
    border-bottom: 1px solid #ddd;

    font-weight: bold;
  }
`

function parseColumnWidth(value) {
  if (!value) return null

  if (typeof value === "string" && value[value.length - 1] === "%")
    return (parseFloat(value.slice(0, -1)) * width) / 100
  return parseFloat(value)
}

const Row = ({ index, style }) => <div style={style}>Row {index}</div>
const Cell = ({ columnIndex, rowIndex, style }) => (
  <div style={style}>
    Item {rowIndex},{columnIndex}
  </div>
)

const width = 1140
const columns = [
  { label: "Header 1" },
  { label: "Header 2", width: "20%" },
  { label: "Header 3", width: "20%" },
  { label: "Header 4", width: 100 },
]

let columnWidths = columns.map((column) => {
  let value = column.width
  if (!value) return null

  if (typeof value === "string" && value[value.length - 1] === "%")
    return (parseFloat(value.slice(0, -1)) * width) / 100
  return parseFloat(value)
})
const usedWidth = columnWidths.reduce(
  (array, w) => {
    if (w !== null) {
      array[0] += w
      array[1] += 1
    }
    return array
  },
  [0, 0]
)
console.log(columnWidths, usedWidth)

columnWidths = columnWidths.map((value) => {
  if (value !== null) return value
  console.log(width, usedWidth, (width - usedWidth[0]) / usedWidth[1])
  return (width - usedWidth[0]) / (columns.length - usedWidth[1])
})
console.log(":::::::::::", columnWidths, scrollbarWidth)

const Example = () => (
  <Styles>
    {/* <div className="row head">
      <div className="cell">Header 1</div>
      <div className="cell">Header 2</div>
      <div className="cell">Header 3</div>
      <div className="cell">Actions</div>
    </div>
    <List height={400} itemCount={1000} itemSize={35} width={width}>
      {Row}
    </List> */}

    <Grid
      columnCount={4}
      columnWidth={(index) => columnWidths[index]}
      height={400}
      rowCount={1000}
      rowHeight={(index) => 50}
      width={width + scrollbarWidth()}
    >
      {Cell}
    </Grid>
  </Styles>
)

const VirtualizedTable = ({ width, columns, values, Header, Row }) => {
  let columnWidths = React.useMemo(() => {
    let widths = []
    columns.forEach((column) => {
      parseColumnWidth(column.width)
    })
  }, [])
  const usedWidth = columnWidths.reduce(
    (array, w) => {
      if (w !== null) {
        array[0] += w
        array[1] += 1
      }
      return array
    },
    [0, 0]
  )
  console.log(columnWidths, usedWidth)

  columnWidths = columnWidths.map((value) => {
    if (value !== null) return value
    console.log(width, usedWidth, (width - usedWidth[0]) / usedWidth[1])
    return (width - usedWidth[0]) / (columns.length - usedWidth[1])
  })
}
export default Example
