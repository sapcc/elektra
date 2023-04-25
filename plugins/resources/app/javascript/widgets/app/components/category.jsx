import React from "react"
import { Link } from "react-router-dom"

import { sortByLogicalOrderAndName, t } from "../utils"
import { Scope } from "../scope"
import UsageOnlyResource from "./usage_only_resource"

const tracksQuota = (res) => {
  return (
    res.quota !== undefined ||
    res.domains_quota !== undefined ||
    res.projects_quota !== undefined
  )
}

export default class Category extends React.Component {
  state = {}

  render() {
    const { categoryName, canEdit } = this.props
    const { area, serviceType, resources } = this.props.category

    const scope = new Scope(this.props.scopeData)
    const Resource = scope.resourceComponent()

    //these props are passed on to the Resource children verbatim
    const forwardProps = {
      flavorData: this.props.flavorData,
      scopeData: this.props.scopeData,
      metadata: this.props.metadata,
      categoryName,
      area,
      canEdit,
    }

    //on domain/cluster level, skip resources that do not track quota (those
    //levels pretty much only care about quota distribution)
    const resourcesDisplayed = scope.isProject()
      ? resources
      : resources.filter(tracksQuota)

    //for usage-only resources with no quota of their own, this finds
    //the resource they're ultimately "contained_in"
    const getContainingResourceFor = (resName) => {
      const res = resources.find((res) => res.name === resName)
      if (res.contained_in) {
        return getContainingResourceFor(res.contained_in)
      }
      return res
    }

    return (
      <>
        <h3>
          <div className="row">
            <div className="col-md-6">{t(categoryName)}</div>
            {canEdit && !scope.isCluster() && (
              <div className="col-md-1 text-right">
                <Link
                  to={`/${area}/edit/${categoryName}`}
                  className="btn btn-primary btn-sm btn-edit-quota"
                >
                  Edit
                </Link>
              </div>
            )}
          </div>
        </h3>
        {sortByLogicalOrderAndName(resourcesDisplayed).map((res) =>
          tracksQuota(res) ? (
            <Resource key={res.name} resource={res} {...forwardProps} />
          ) : (
            <UsageOnlyResource
              key={res.name}
              resource={res}
              parentResource={getContainingResourceFor(res.name)}
              {...forwardProps}
            />
          )
        )}
      </>
    )
  }
}
