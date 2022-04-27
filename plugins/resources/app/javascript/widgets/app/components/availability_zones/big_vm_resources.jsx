import React from "react"
import { Unit } from "../../unit"
import { getBigvmResources } from "../../actions/elektra"

const mbUnit = new Unit("MiB")
const columnsPerRow = 3

/**
 * This component shows available HANA Vms
 * @param {Array} bigVmResources a list of vms capable to host HANA instances
 * @returns a React Component
 */
const AvailableBigVmResources = () => {
  const [loading, setLoading] = React.useState(false)
  const [error, setError] = React.useState()
  const [bigVmResources, setBigVmResources] = React.useState()

  React.useEffect(() => {
    setError(null)
    setLoading(true)
    getBigvmResources()
      .then((data) => setBigVmResources(data))
      .catch((error) => setError(error))
      .finally(() => setLoading(false))
  }, [])
  /**
   * This functions converts the list of big vms into a list of flavors
   * grouped by availability zone.
   */
  const flavorsByAz = React.useMemo(() => {
    if (!bigVmResources) return []
    const map = {}

    bigVmResources.forEach((item) => {
      // az => availability_zone
      const az = item.az
      // create entry for az unless already exists
      map[az] = map[az] || []
      // consider flavor for free hosts only
      if (item.status === "free") {
        let flavors = map[az].concat(item.flavors || [])
        // and remove duplicates
        map[az] = flavors
          .filter((elem, pos, arr) => {
            const index = arr.findIndex((e) => e.name === elem.name)
            return index === pos
          })
          .sort((a, b) => (a.ram > b.ram ? 1 : a.ram < b.ram ? -1 : 0))
      }
    })

    // result of map is e.g. {"eu-de-1a" => [flavor1,flavor2]}

    // convert map to array of arrays and split it into chunks (columns per row)
    // and sort values by az
    const result = []
    const availabilityZones = Object.keys(map).sort()
    for (let i = 0; i < availabilityZones.length; i += columnsPerRow) {
      const values = availabilityZones
        .slice(i, i + columnsPerRow)
        .map((az) => ({ az, items: map[az] }))
      result.push(values)
    }

    // for tests only
    // result[0].push({ az: "eu-de-2c", items: [] })

    // now the result looks like e.g. [[{az: "eu-de-1a", items: [flavor1,flavor2]}]]
    return result
  }, [bigVmResources])

  const columnWidth = React.useMemo(() => {
    if (flavorsByAz.length === 0) return 1
    const dataLength = flavorsByAz[0].length
    return Math.floor(12 / dataLength)
  }, [flavorsByAz])

  // structure of the UI:
  // eu-de-1a | eu-de-1b | eu-de-1c
  // flavors  | flavors  | flavors
  // ------------------------------
  // eu-de-1d |
  // flavors  |
  // ...
  return (
    <React.Fragment>
      <h3>Available HANA VM resources</h3>
      {loading ? (
        <span>
          <span className="spinner"></span> Loading...
        </span>
      ) : error ? (
        <div className="alert alert-danger">{error}</div>
      ) : flavorsByAz.length === 0 ? (
        <span>No resources available.</span>
      ) : (
        flavorsByAz.map((chunk, i1) => (
          <React.Fragment key={i1}>
            <div className="row">
              {chunk.map((region, i2) => (
                <div className={`col-md-${columnWidth}`} key={i2}>
                  <div>
                    <h4>{region.az}</h4>
                  </div>
                </div>
              ))}
            </div>

            <div className="row">
              {chunk.map((region, i2) => (
                <div className={`col-md-${columnWidth}`} key={i2}>
                  <div
                    className={`bs-callout bs-callout-${
                      region.items.length > 0 ? "primary" : "warning"
                    }`}
                  >
                    <h5>
                      {region.items.length > 0
                        ? "VM deployment possible from these flavors:"
                        : "No resources available"}
                    </h5>

                    <div>
                      {region.items.map((f, i3) => (
                        <div key={i3}>
                          {f.name}&nbsp;
                          <span className="small text-muted">
                            ({mbUnit.format(f.ram)} RAM each)
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
    </React.Fragment>
  )
}

export default AvailableBigVmResources
