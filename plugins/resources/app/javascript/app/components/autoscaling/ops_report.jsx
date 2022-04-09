import { DataTable } from "lib/components/datatable"
import { PrettyDate } from "lib/components/pretty_date"

import { Unit, valueWithUnit } from "../../unit"
import { t } from "../../utils"

//TODO: many of these constants and predicates are duplicated in
//plugins/shared_filesystem_storage/app/components/castellum/operation.jsx

const isOrWas = {
  created: "is",
  confirmed: "is",
  greenlit: "is",
  cancelled: "was",
  succeeded: "was",
  failed: "was",
}

const sortOrderForStates = {
  created: 1,
  confirmed: 2,
  greenlit: 3,
  cancelled: 4,
  succeeded: 5,
  failed: 6,
}
const sortOrderForReasons = {
  low: 1,
  high: 2,
  critical: 3,
}

const sortKeyForNameOrID = (props) => {
  return (props.projectName || "") + props.operation.asset_id
}
const sortKeyForAssetType = (props) => {
  const { serviceType, resourceName } = parseAssetType(
    props.operation.asset_type
  )
  return `${t(serviceType)}/${t(resourceName)}`
}
const sortKeyForStateAndReason = (props) => {
  const { state, reason } = props.operation
  return sortOrderForStates[state] * 10 + sortOrderForReasons[reason]
}
const sortKeyForSizeChange = (props) => {
  const { old_size, new_size } = props.operation
  return old_size * 100000 + new_size
}

export const columns = [
  {
    key: "project",
    label: "Project",
    sortStrategy: "text",
    sortKey: sortKeyForNameOrID,
  },
  {
    key: "asset_type",
    label: "Resource",
    sortStrategy: "text",
    sortKey: sortKeyForAssetType,
  },
  {
    key: "state",
    label: "State/Reason",
    sortStrategy: "numeric",
    sortKey: sortKeyForStateAndReason,
  },
  {
    key: "size",
    label: "Size",
    sortStrategy: "numeric",
    sortKey: sortKeyForSizeChange,
  },
  {
    key: "timeline",
    label: "Timeline",
    sortStrategy: "numeric",
    sortKey: (props) => -props.operation.created.at,
  },
]

const assetTypeRx = /^project-quota:(.+):(.+)$/
const parseAssetType = (assetType) => {
  const match = assetTypeRx.exec(assetType)
  return match
    ? { serviceType: match[1], resourceName: match[2] }
    : { serviceType: "", resourceName: assetType }
}

const titleCase = (str) =>
  str.charAt(0).toUpperCase() + str.substr(1).toLowerCase()

const AutoscalingOperation = ({ operation, projectName, unit: unitName }) => {
  const unit = new Unit(unitName)
  const {
    asset_id: projectID,
    asset_type: assetType,
    state,
    reason,
    old_size: oldSize,
    new_size: newSize,
    created,
    confirmed,
    greenlit,
    finished,
  } = operation
  const { serviceType, resourceName } = parseAssetType(assetType)

  return (
    <React.Fragment>
      <tr>
        <td className="col-md-3">
          {projectName || projectID}
          {projectName && <div className="small text-muted">{projectID}</div>}
        </td>
        <td className="col-md-2">
          {t(resourceName)}
          <div className="small text-muted">{t(serviceType)}</div>
        </td>
        <td className="col-md-2">
          {titleCase(state)}
          <div className="small text-muted">
            Usage {isOrWas[state]} {reason}
          </div>
        </td>
        <td className="col-md-2">
          {valueWithUnit(oldSize, unit)} {"->"} {valueWithUnit(newSize, unit)}
        </td>
        <td className="col-md-3">
          <div>
            Created: <PrettyDate date={created.at} />
          </div>
          {confirmed && confirmed.at != created.at && (
            <div>
              Confirmed: <PrettyDate date={confirmed.at} />
            </div>
          )}
          {greenlit && greenlit.at != confirmed.at && (
            <div>
              Greenlit: <PrettyDate date={greenlit.at} />
            </div>
          )}
          {finished && (
            <div>
              {titleCase(state)}: <PrettyDate date={finished.at} />
            </div>
          )}
        </td>
      </tr>
      {finished && finished.error && (
        <tr className="explains-previous-line">
          <td colSpan="5" className="text-danger">
            {finished.error}
          </td>
        </tr>
      )}
    </React.Fragment>
  )
}

export default class AutoscalingOpsReport extends React.Component {
  componentDidMount() {
    this.initializeData(this.props)
  }
  UNSAFE_componentWillReceiveProps(props) {
    this.initializeData(props)
  }
  initializeData(props) {
    const { scopeData, reportType } = this.props
    props.fetchOperationsReportIfNeeded(scopeData.domainID, reportType)
  }

  render() {
    const { errorMessage, isFetching, data } = this.props.report
    if (isFetching || data == null) {
      return (
        <p>
          <span className="spinner" /> Loading...
        </p>
      )
    }
    if (errorMessage) {
      return (
        <p className="alert alert-danger">
          Cannot load operations: {errorMessage}
        </p>
      )
    }

    const allOperations = data || []
    const operations = allOperations.filter((operation) =>
      operation.asset_type.startsWith("project-quota:")
    )

    return (
      <DataTable columns={columns} pageSize={6}>
        {operations.map((operation, idx) => (
          <AutoscalingOperation
            key={idx}
            operation={operation}
            projectName={this.props.projectNames[operation.asset_id]}
            unit={this.props.units[operation.asset_type]}
          />
        ))}
      </DataTable>
    )
  }
}
