import React from "react"
import AvailabilityZoneCategory from "../../containers/availability_zones/category"

import { byUIString, byNameIn } from "../../utils"

const AvailabilityZoneOverview = ({
  isFetching,
  overview,
  flavorData,
  scopeData,
  projectShards,
  shardingEnabled,
  projectScope,
  pathToEnableSharding,
}) => {
  if (isFetching) {
    return (
      <p>
        <span className="spinner" /> Loading capacity data...
      </p>
    )
  }

  const forwardProps = {
    flavorData,
    scopeData,
    projectShards,
    shardingEnabled,
    projectScope,
  }

  //pathToEnableSharding = "/monsoon3/hgws/identity/project/enable_sharding"
  let shardingEnabledMessage = ""
  if (!shardingEnabled && projectScope) {
    shardingEnabledMessage = (
      <div className="bs-callout bs-callout-info bs-callout-emphasize">
        <h5>
          Why do I see greyed out capacity bars for Cores, Instances and RAM?
        </h5>
        Because not all resource pools are enabled. To use all resource pools
        and get access to additional resources click
        <a
          title=""
          data-modal="true"
          data-toggle="tooltip"
          data-placement="left"
          href={pathToEnableSharding}
          data-original-title="Enable Resource Pooling"
        >
          <i className="fa fa-arrow-right fa-fw"></i>here
        </a>
      </div>
    )
  }

  return (
    <>
      <div className="bs-callout bs-callout-info bs-callout-emphasize">
        This screen shows the available capacity (gray bar) and actual current
        resource usage (blue part) in each availability zone. Use this data to
        choose which availability zone to deploy your application to. Please
        note, it does not account for capacity that has already been assigned
        but not yet used and therefore may not reflect overall available
        capacity in the region.
      </div>
      {shardingEnabledMessage}
      {Object.keys(overview.areas)
        .sort(byUIString)
        .map((area) =>
          overview.areas[area]
            .sort(byUIString)
            .map((serviceType) =>
              overview.categories[serviceType]
                .sort(byNameIn(serviceType))
                .map((categoryName) => (
                  <AvailabilityZoneCategory
                    key={categoryName}
                    categoryName={categoryName}
                    {...forwardProps}
                  />
                ))
            )
        )}
    </>
  )
}

export default AvailabilityZoneOverview
