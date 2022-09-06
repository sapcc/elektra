import React from "react"
import styled from "styled-components"
import { useTable, useBlockLayout } from "react-table"
import { FixedSizeList } from "react-window"
import scrollbarWidth from "./scrollbarWidth"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"

const Styles = styled.div`
  padding: 1rem;

  .table {
    display: inline-block;
    border-spacing: 0;
    border: 1px solid black;

    .tr {
      :last-child {
        .td {
          border-bottom: 0;
        }
      }
    }

    .th,
    .td {
      margin: 0;
      padding: 0.5rem;
      border-bottom: 1px solid black;
      border-right: 1px solid black;

      :last-child {
        border-right: 1px solid black;
      }
    }
  }
`

function Table({ columns, data }) {
  // Use the state and functions returned from useTable to build your UI

  const defaultColumn = React.useMemo(
    () => ({
      width: 150,
    }),
    []
  )

  const scrollBarSize = React.useMemo(() => scrollbarWidth(), [])

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    totalColumnsWidth,
    prepareRow,
  } = useTable(
    {
      columns,
      data,
      defaultColumn,
    },
    useBlockLayout
  )

  const RenderRow = React.useCallback(
    ({ index, style }) => {
      const row = rows[index]
      prepareRow(row)
      console.log("row:", row)
      return (
        <div
          {...row.getRowProps({
            style,
          })}
          className="tr"
        >
          {row.cells.map((cell, i) => {
            console.log("cell", cell)
            return (
              <div key={i} {...cell.getCellProps()} className="td">
                {cell.render("Cell")}
              </div>
            )
          })}
        </div>
      )
    },
    [prepareRow, rows]
  )

  // Render the UI for your table
  return (
    <div {...getTableProps()} className="table">
      <div>
        {headerGroups.map((headerGroup, i) => (
          <div key={i} {...headerGroup.getHeaderGroupProps()} className="tr">
            {console.log(headerGroup)}
            {headerGroup.headers.map((column, j) => (
              <div key={j} {...column.getHeaderProps()} className="th">
                {column.render("Header")}
              </div>
            ))}
          </div>
        ))}
      </div>

      <div {...getTableBodyProps()}>
        <FixedSizeList
          height={400}
          itemCount={rows.length}
          itemSize={35}
          width={totalColumnsWidth + scrollBarSize}
        >
          {RenderRow}
        </FixedSizeList>
      </div>
    </div>
  )
}

function App() {
  const containers = useGlobalState("containers")
  const { loadContainersOnce } = useActions()

  React.useEffect(() => {
    loadContainersOnce()
  }, [loadContainersOnce])

  const columns = React.useMemo(
    () => [
      { Header: "Container name", accessor: "name" },
      { Header: "Last modified", accessor: "last_modified" },
      { Header: "Total size", accessor: "bytes" },
      { Header: "", id: "actions" },
    ],
    []
  )

  const data = React.useMemo(() => containers.items || [], [containers.items])

  console.log("================", data)
  return (
    <Styles>
      <Table columns={columns} data={data} />
    </Styles>
  )
}

export default App
