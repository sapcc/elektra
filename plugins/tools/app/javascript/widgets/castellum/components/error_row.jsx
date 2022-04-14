import { PrettyDate } from "lib/components/pretty_date"

export default (props) => {
  const {
    project_id: projectID,
    asset_type: assetType,
    asset_id: assetID,
    old_size: oldSize,
    new_size: newSize,
    checked,
    finished,
  } = props.error

  const result = checked || finished || {}
  const hasAssetID = assetID && assetID != projectID ? true : false
  const hasSizeColumn = oldSize || newSize ? true : false

  return (
    <React.Fragment>
      <tr>
        <td className={hasSizeColumn ? "col-md-3" : "col-md-4"}>
          <a
            href={`/_/${projectID}/home`}
            target="_blank"
            title="Jump to project"
          >
            {projectID}
          </a>
        </td>
        <td className="col-md-4">
          {hasAssetID ? `${assetType} ${assetID}` : assetType}
        </td>
        {hasSizeColumn && (
          <td className="col-md-2">
            {oldSize} {"->"} {newSize}
          </td>
        )}
        <td className={hasSizeColumn ? "col-md-2" : "col-md-3"}>
          <PrettyDate date={result.at} />
        </td>
      </tr>
      <tr className="explains-previous-line">
        <td colSpan={hasSizeColumn ? 4 : 3} className="text-danger">
          {result.error}
        </td>
      </tr>
    </React.Fragment>
  )
}
