import React from "react"
import { DataTable } from "lib/components/datatable"

import { Unit, valueWithUnit } from "../unit"
import { t } from "../utils"

const tableDefs = [
  {
    label: "Domain quota overcommitted",
    dataKey: "domain_quota_overcommitted",
    columnKeys: ["domain", "resource", "domain_quota", "projects_quota"],
  },
  {
    label: "Project quota overspent",
    dataKey: "project_quota_overspent",
    columnKeys: ["project", "resource", "quota", "usage"],
  },
  {
    label: "Project quota mismatch",
    dataKey: "project_quota_mismatch",
    columnKeys: ["project", "resource", "quota", "backend_quota"],
  },
]

const nameOrIDOf = (thing) => {
  if (!thing) {
    return ""
  }
  return thing.name || thing.id || ""
}

const columnDefs = [
  //This contains all columns that can appear in any of the inconsistencies tables.
  //The actual columns for a particular table are picked by matching the keys
  //in this list with `tableDefs[idx].columnKeys`.
  {
    key: "domain",
    label: "Domain",
    sortStrategy: "text",
    sortKey: (props) => nameOrIDOf(props.domain),
  },
  {
    key: "project",
    label: "Project",
    sortStrategy: "text",
    sortKey: (props) =>
      `${nameOrIDOf(props.project.domain)}/${nameOrIDOf(props.project)}`,
  },
  {
    key: "resource",
    label: "Resource",
    sortStrategy: "text",
    sortKey: (props) => `${t(props.service) || ""} ${t(props.resource) || ""}`,
  },
  {
    key: "quota",
    label: "Quota",
    sortStrategy: "numeric",
    sortKey: (props) => props.quota || 0,
  },
  {
    key: "domain_quota",
    label: "Quota",
    sortStrategy: "numeric",
    sortKey: (props) => props.domain_quota || 0,
  },
  {
    key: "projects_quota",
    label: "Assigned to projects",
    sortStrategy: "numeric",
    sortKey: (props) => props.projects_quota || 0,
  },
  {
    key: "backend_quota",
    label: "Backend Quota",
    sortStrategy: "numeric",
    sortKey: (props) => props.backend_quota || 0,
  },
  {
    key: "usage",
    label: "Usage",
    sortStrategy: "numeric",
    sortKey: (props) => props.usage || 0,
  },
]

const cellContents = {
  //This contains functions rendering individual cells in the inconsistency table.
  domain: ({ domain }) => (
    <>
      {domain.name || domain.id}
      {domain.name && <div className="small text-muted">{domain.id}</div>}
    </>
  ),
  project: ({ project }) => {
    const domain = project.domain || {}
    return (
      <>
        <span className="text-muted">{domain.name || domain.id}</span>/
        {project.name || project.id}
        {project.name && <div className="small text-muted">{project.id}</div>}
      </>
    )
  },
  resource: ({ service, resource }) => (
    <>
      {t(resource)}
      <div className="small text-muted">{t(service)}</div>
    </>
  ),
  quota: ({ quota: value, unit }) => valueWithUnit(value, unit),
  domain_quota: ({ domain_quota: value, unit }) => valueWithUnit(value, unit),
  projects_quota: ({ projects_quota: value, unit }) =>
    valueWithUnit(value, unit),
  backend_quota: ({ backend_quota: value, unit }) => valueWithUnit(value, unit),
  usage: ({ usage: value, unit }) => valueWithUnit(value, unit),
}

const InconsistencyRow = (props) => {
  //convert `props.unit` into a Unit instance before passing to the cell renderers
  const cellProps = {
    ...props,
    unit: new Unit(props.unit || ""),
  }

  const cells = []
  for (const key of props.columnKeys) {
    const contents = cellContents[key](cellProps)
    const columnDef = columnDefs.find((c) => c.key == key)
    //make text columns wider than number columns
    const cssClass = columnDef.sortStrategy == "text" ? "col-md-4" : "col-md-2"
    cells.push(
      <td className={cssClass} key={key}>
        {contents}
      </td>
    )
  }

  return <tr>{cells}</tr>
}

export default class Inconsistencies extends React.Component {
  state = {
    active: 0,
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    nextProps.loadInconsistenciesOnce()
  }
  componentDidMount() {
    this.props.loadInconsistenciesOnce()
  }

  handleSelect(pageIdx, e) {
    e.preventDefault()
    this.setState({
      ...this.state,
      active: pageIdx,
    })
  }

  render() {
    const { isFetching, inconsistencies } = this.props
    if (isFetching) {
      return (
        <p>
          <span className="spinner" /> Loading...
        </p>
      )
    }

    const tableDef = tableDefs[this.state.active || 0]
    const columns = tableDef.columnKeys.map((key) =>
      columnDefs.find((c) => c.key == key)
    )
    const tableData = inconsistencies[tableDef.dataKey]

    return (
      <div className="row">
        <div className="col-md-2">
          <ul className="nav nav-pills nav-stacked">
            {tableDefs.map((tableDef, idx) => (
              <li
                key={idx}
                role="presentation"
                className={idx == this.state.active ? "active" : ""}
              >
                <a href="#" onClick={(e) => this.handleSelect(idx, e)}>
                  {tableDef.label}
                </a>
              </li>
            ))}
          </ul>
        </div>
        <div className="col-md-10">
          <DataTable columns={columns} pageSize={8}>
            {tableData.map((rowData, idx) => (
              <InconsistencyRow
                key={idx}
                {...rowData}
                columnKeys={tableDef.columnKeys}
              />
            ))}
          </DataTable>
        </div>
      </div>
    )
  }
}
