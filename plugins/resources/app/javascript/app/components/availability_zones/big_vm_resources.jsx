import ResourceName from "../resource_name"
import ResourceBar from "../resource_bar"
import React from "react"

// const AvailableBigVmResources = ({ bigVmResources }) => {
//   const availabilityZones = React.useMemo(() =>
//     Object.keys(bigVmResources).sort()
//   )
//   const hv_sizes = {}
//   Object.keys(bigVmResources).map((az) =>
//     Object.keys(bigVmResources[az]).map(
//       (memory_size) => (hv_sizes[memory_size] = bigVmResources[az][memory_size])
//     )
//   )
//   const azColumnWidth = Math.floor(10 / availabilityZones.length)

//   // there is only one HV per az and memory size
//   function get_available_capacity(capacity) {
//     if (capacity) {
//       return 1
//     } else {
//       return 0
//     }
//   }

//   if (Object.keys(availabilityZones).length > 0) {
//     return (
//       <React.Fragment>
//         <h3>Available HANA VM resources</h3>
//         <div className="row">
//           <div className="col-md-2"> </div>
//           {availabilityZones.map((az) => (
//             <div key={az} className={`col-md-${azColumnWidth}`}>
//               <h4>{az}</h4>
//             </div>
//           ))}
//         </div>

//         {Object.keys(hv_sizes)
//           .sort()
//           .map((memory_size) => (
//             <div key={memory_size} className="row">
//               <ResourceName
//                 name={memory_size + "TiB Hypervisor"}
//                 flavorData={{ primary: true }}
//               />
//               {availabilityZones.map((az) => (
//                 <div
//                   key={az + "-" + memory_size}
//                   className={`col-md-${azColumnWidth}`}
//                 >
//                   <ResourceBar
//                     capacity={get_available_capacity(
//                       bigVmResources[az][memory_size]
//                     )}
//                     fill={0}
//                     labelOverride={"Available flavors " + hv_sizes[memory_size]}
//                     showsCapacity={true}
//                   />
//                 </div>
//               ))}
//             </div>
//           ))}
//       </React.Fragment>
//     )
//   } else {
//     return <React.Fragment></React.Fragment>
//   }
// }

const AvailableBigVmResources = ({ bigVmResources }) => {
  const availabilityZones = React.useMemo(
    () => Object.keys(bigVmResources).sort(),
    [bigVmResources]
  )

  const dataByAz = React.useMemo(() => {
    const map = {}
    Object.keys(bigVmResources).forEach((az) => {
      map[az] = map[az] || {
        capacity: 0,
        used: 0,
        flavors: [],
        sizeTotal: 0,
        sizeUsed: 0,
      }
      const items = bigVmResources[az] || []
      items.forEach((item) => {
        map[az].capacity++
        map[az].used += item.status === "used" ? 1 : 0
        map[az].flavors = map[az].flavors.concat(item.flavors || [])
        map[az].sizeTotal += parseFloat(item.size_tb)
        map[az].sizeUsed +=
          item.status === "used" ? parseFloat(item.size_tb) : 0
      })
    })
    return map
  }, [bigVmResources])

  const azColumnWidth = React.useMemo(() =>
    Math.floor(10 / availabilityZones.length, [availabilityZones])
  )

  console.log("===================", bigVmResources, dataByAz)

  if (availabilityZones.length === 0) return null

  return (
    <React.Fragment>
      <h3>Available HANA VM resources</h3>
      {Object.keys(dataByAz).map((az) => (
        <React.Fragment key={az}>
          <div className="row">
            <div className="col-md-2"> </div>

            <div key={az} className={`col-md-9` /*`col-md-${azColumnWidth}`*/}>
              <h4>{az}</h4>
            </div>
          </div>
          <div className="row">
            <div className="col-md-2 text-right">
              Flavors: <br />
              {dataByAz[az].flavors.join(" ")}
            </div>
            <div key={az} className={"col-md-9" /*`col-md-${azColumnWidth}`*/}>
              <ResourceBar
                capacity={dataByAz[az].capacity}
                fill={dataByAz[az].used}
                labelOverride={`${
                  dataByAz[az].capacity - dataByAz[az].used
                } more VMs possible (${dataByAz[az].sizeUsed} TiB/${
                  dataByAz[az].sizeTotal
                } TiB)`}
                showsCapacity={true}
              />
            </div>
          </div>
        </React.Fragment>
      ))}
    </React.Fragment>
  )
}

export default AvailableBigVmResources
