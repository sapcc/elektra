import React from "react"
import { getBigvmResources } from "../../actions/elektra"

const columnsPerRow = 3
/**
 * This component shows available HANA Vms
 * @param {Array} bigVmResources a list of vms capable to host HANA instances
 * @returns a React Component
 */
const AvailableBigVmResources = () => {
  const [loading, setLoading] = React.useState(false)
  const [error, setError] = React.useState()
  const [placeableVMs, setPlaceableVMs] = React.useState([])

  React.useEffect(() => {
    setError(null)
    setLoading(true)
    getBigvmResources()
      .then((data) => setPlaceableVMs(data))
      .catch((error) => setError(error))
      .finally(() => setLoading(false))
  }, [setPlaceableVMs, setError, setLoading])

  const columnWidth = React.useMemo(() => {
    if (!placeableVMs || placeableVMs.length === 0) return 1
    if (placeableVMs.length >= columnsPerRow) return 12 / columnsPerRow //more than on line, max 3 columns per row
    return Math.floor(12 / placeableVMs.length)
  }, [placeableVMs, columnsPerRow])

  const itemChunks = React.useMemo(() => {
    if (!placeableVMs) return []
    const result = []
    for (let i = 0; i < placeableVMs.length; i += columnsPerRow) {
      const availabilityZonesChunk = placeableVMs.slice(i, i + columnsPerRow)
      result.push(availabilityZonesChunk)
    }
    return result
  }, [placeableVMs])

  // structure of the UI:
  // eu-de-1a | eu-de-1b | eu-de-1c
  // flavors  | flavors  | flavors
  // ------------------------------
  // eu-de-1d |
  // flavors  |
  // ...
  return (
    <>
      <h3>Available HANA VM resources</h3>
      {loading ? (
        <span>
          <span className="spinner"></span> Loading...
        </span>
      ) : error ? (
        <div className="alert alert-warning">{error.message}</div>
      ) : placeableVMs.length === 0 ? (
        <span>No resources available.</span>
      ) : (
        itemChunks.map((chunk, i1) => (
          <React.Fragment key={i1}>
            <div className="row">
              {chunk.map((azData, i2) => (
                <div className={`col-md-${columnWidth}`} key={i2}>
                  <div>
                    <h4>{azData.availabilityZone}</h4>
                  </div>
                </div>
              ))}
            </div>

            <div className="row">
              {chunk.map((azData, i2) => (
                <div className={`col-md-${columnWidth}`} key={i2}>
                  <div
                    className={`bs-callout bs-callout-${
                      azData.flavors.length > 0 ? "primary" : "warning"
                    }`}
                  >
                    <h5>
                      {azData.flavors.length > 0
                        ? "VM deployment possible from these flavors:"
                        : "No resources available"}
                    </h5>

                    <div>
                      {azData.flavors.map((flavor, i3) => (
                        <div key={i3}>
                          {Object.keys(flavor)[0]}&nbsp;
                          <span className="small text-muted">
                            ({Object.values(flavor)[0]} VMs available)
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </React.Fragment>
        ))
      )}
    </>
  )
}

export default AvailableBigVmResources
