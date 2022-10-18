import React from "react"
import ResourceName from "../resource_name"
import ResourceBar from "../resource_bar"

import { t } from "../../utils"

const renderBar = (resource, serviceType, azName) => {
  const az =
    resource.per_availability_zone.find((data) => data.name == azName) || {}

  //In Manila, we have an overcommit factor for historical reasons. But because
  //of changed usage patterns (more use of autoscaling) shares are fuller than
  //they used to be, and because of disk encryption, deduplication is not as
  //impactful anymore. So we cannot actually promise more than the raw capacity
  //to users. Therefore, for Manila, we show only the raw capacity.
  const capacity = serviceType == "sharev2" ? az.raw_capacity : az.capacity

  return (
    <ResourceBar
      capacity={capacity || 0}
      fill={az.usage || 0}
      unitName={resource.unit}
      isDanger={false}
      showsCapacity={true}
    />
  )
}

// aggregate capa from hypervisor the total sub capacities
const calculateTotalSubCapacity = (subcapacities) => {
  let totalSubcapa = {}
  subcapacities.map((subcapacity) => {
    if (subcapacity.aggregate.startsWith("vc")) {
      // he total capacity and usage for each vCenter can be obtained by summing up the respective values for all hypervisors
      // with the same values for az and aggregate.
      let key = subcapacity.aggregate + "-" + subcapacity.az
      if (totalSubcapa[key]) {
        // summing up capacity and usage
        totalSubcapa[key].capacity =
          totalSubcapa[key].capacity + subcapacity.capacity

        totalSubcapa[key].usage = totalSubcapa[key].usage + subcapacity.usage
      } else {
        totalSubcapa[key] = {
          az: subcapacity.az,
          aggregate: subcapacity.aggregate,
          capacity: subcapacity.capacity,
          usage: subcapacity.usage,
        }
      }
    }
  })

  return Object.values(totalSubcapa)
}

const renderShard = (
  resource,
  azColumnWidth,
  flavorData,
  availabilityZones,
  projectShards,
  shardingEnabled,
  projectScope
) => {
  // check for over commit factor
  let ocFactor = resource.capacity / resource.raw_capacity
  //console.log(resource)
  if ("subcapacities" in resource) {
    let subcapacities = resource.subcapacities
    let totalSubCapacities = calculateTotalSubCapacity(subcapacities)
    return (
      <div className="row usage-only" key={resource.name}>
        <ResourceName name="" flavorData={flavorData} />
        {availabilityZones.map((azName, azIndex) => (
          <div
            className={`col-md-${azColumnWidth}`}
            style={{ marginBottom: 5 }}
            key={azIndex}
          >
            {totalSubCapacities
              .sort(function (a, b) {
                // to sort shards -> https://stackoverflow.com/questions/47998188/how-to-sort-an-object-alphabetically-within-an-array-in-react-js
                if (a.aggregate.toLowerCase() < b.aggregate.toLowerCase())
                  return -1
                if (a.aggregate.toLowerCase() > b.aggregate.toLowerCase())
                  return 1
                return 0
              })
              .map((subcapacity, subcapacityIndex) => {
                //console.log(subcapacity)
                if (subcapacity.aggregate.startsWith("vc")) {
                  if (subcapacity.az == azName) {
                    // calculate data with over commit factor if exist
                    let capa = subcapacity.capacity
                    if (ocFactor) {
                      capa = subcapacity.capacity * ocFactor
                    }
                    if (projectScope) {
                      if (projectShards.indexOf(subcapacity.aggregate) > -1) {
                        return (
                          <div className="row" key={subcapacityIndex}>
                            <div
                              className="col-md-2 text-left shard-name"
                              title={"resource pool " + subcapacity.aggregate}
                            >
                              {"rp - " + subcapacity.aggregate}
                            </div>
                            <div
                              className="col-md-10"
                              style={{ paddingLeft: "8px" }}
                            >
                              <ResourceBar
                                capacity={capa || 0}
                                fill={subcapacity.usage || 0}
                                unitName={resource.unit}
                                isDanger={false}
                                showsCapacity={true}
                              />
                            </div>
                          </div>
                        )
                      } else {
                        let opacity = {}
                        if (!shardingEnabled) {
                          opacity = { opacity: 0.5 }
                        }
                        // disable resourceBar if sharding are disabled and the shard is not part of the project
                        return (
                          <div className="row" key={subcapacityIndex}>
                            <div
                              className="col-md-2 text-left shard-name"
                              title={"resource pool " + subcapacity.aggregate}
                              style={opacity}
                            >
                              {"rp - " + subcapacity.aggregate}
                            </div>
                            <div
                              className="col-md-10"
                              style={{ paddingLeft: "8px" }}
                            >
                              <ResourceBar
                                capacity={capa || 0}
                                fill={subcapacity.usage || 0}
                                unitName={resource.unit}
                                isDanger={false}
                                showsCapacity={true}
                                disabled={!shardingEnabled}
                              />
                            </div>
                          </div>
                        )
                      }
                    } else {
                      // Domain scope
                      return (
                        <div className="row" key={capa}>
                          <div
                            className="col-md-2 text-left shard-name"
                            title={"resource pool " + subcapacity.aggregate}
                          >
                            {"rp - " + subcapacity.aggregate}
                          </div>
                          <div
                            className="col-md-10"
                            style={{ paddingLeft: "8px" }}
                          >
                            <ResourceBar
                              capacity={capa || 0}
                              fill={subcapacity.usage || 0}
                              unitName={resource.unit}
                              isDanger={false}
                              showsCapacity={true}
                            />
                          </div>
                        </div>
                      )
                    }
                  }
                }
              })}
          </div>
        ))}
      </div>
    )
  }
}

const AvailabilityZoneResource = ({
  resource,
  serviceType,
  flavorData: allFlavorData,
  availabilityZones,
  azColumnWidth,
  projectShards,
  shardingEnabled,
  projectScope,
}) => {
  const displayName = t(resource.name)
  const flavorData = allFlavorData[displayName] || {}

  let subcapacitieBars = renderShard(
    resource,
    azColumnWidth,
    flavorData,
    availabilityZones,
    projectShards,
    shardingEnabled,
    projectScope
  )

  let resourceBar = (
    <div className="row" key={displayName}>
      <ResourceName name={displayName} flavorData={flavorData} />
      {availabilityZones.map((azName, i) => (
        <div key={i} className={`col-md-${azColumnWidth}`}>
          {renderBar(resource, serviceType, azName)}
        </div>
      ))}
    </div>
  )

  return [resourceBar, subcapacitieBars]
}

export default AvailabilityZoneResource
