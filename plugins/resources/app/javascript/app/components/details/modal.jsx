import { Modal, Button } from "react-bootstrap"
import { DataTable } from "lib/components/datatable"
import { FormErrors } from "lib/elektra-form/components/form_errors"
import { SearchField } from "lib/components/search_field"

import { t } from "../../utils"
import { Scope } from "../../scope"
import { Unit } from "../../unit"
import DetailsResource from "../../components/details/resource"
import ReloadIndicator from "../../components/reload_indicator"

const clusterDataTableColumns = [
  {
    key: "id",
    label: "Domain",
    sortStrategy: "text",
    sortKey: (props) => props.metadata.name || "",
  },
  {
    key: "quota",
    label: "Quota",
    sortStrategy: "numeric",
    sortKey: (props) => props.resource.quota || 0,
  },
  {
    key: "projects_quota",
    label: "Granted to projects",
    sortStrategy: "numeric",
    sortKey: (props) => props.resource.projects_quota || 0,
  },
  {
    key: "usage",
    label: "Usage",
    sortStrategy: "numeric",
    sortKey: (props) => props.resource.usage || 0,
  },
  {
    key: "burst_usage",
    label: "Thereof burst",
    sortStrategy: "numeric",
    sortKey: (props) => props.resource.burst_usage || 0,
  },
  { key: "actions", label: "Actions" },
]

const domainDataTableColumns = [
  {
    key: "id",
    label: "Project",
    sortStrategy: "text",
    searchKey: (props) => `${props.metadata.name} ${props.metadata.id}` || "",
    sortKey: (props) => props.metadata.name || "",
  },
  {
    key: "quota",
    label: "Quota",
    sortStrategy: "numeric",
    sortKey: (props) => props.resource.quota || 0,
  },
  {
    key: "usage",
    label: "Usage",
    sortStrategy: "numeric",
    sortKey: (props) => props.resource.usage || 0,
  },
  {
    key: "burst_usage",
    label: "Thereof burst",
    sortStrategy: "numeric",
    sortKey: (props) => props.resource.burst_usage || 0,
  },
  { key: "actions", label: "Actions" },
]

export default class DetailsModal extends React.Component {
  state = {
    //This will be set to false by this.close().
    show: true,
    //This contains the quota/usage data for the subscopes (for domain level,
    //the domain's projects; for cluster level, the cluster's domains).
    subscopes: null,
    isFetching: false,
    //Unexpected errors returned from the Limes API, if any.
    apiErrors: null,
    searchTerm: null,
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    this.fetchSubscopes(nextProps)
  }

  componentDidMount() {
    this.fetchSubscopes(this.props)
  }

  //This gets called once to initialize the list of subscopes.
  fetchSubscopes = (props) => {
    //do this only once
    if (this.state.subscopes || this.state.isFetching) {
      return
    }

    this.setState({
      ...this.state,
      isFetching: true,
    })
    props
      .listSubscopes(
        props.scopeData,
        props.category.serviceType,
        props.resourceName
      )
      .then(this.receiveSubscopes)
      .catch((response) => this.handleAPIErrors(response.errors))
  }

  //This gets called by fetchSubscopes() on success.
  receiveSubscopes = (data) => {
    const subscopes = []
    for (let subscopeData of data) {
      //transform the nested structure of Limes' JSON into something flatter,
      //similar to app/reducers/limes.js
      const { services: serviceList, ...metadata } = subscopeData
      if (serviceList.length == 0) {
        continue
      }
      const { resources: resourceList, ...serviceData } = serviceList[0]
      if (resourceList.length == 0) {
        continue
      }
      subscopes.push({
        metadata: metadata,
        service: serviceData,
        resource: resourceList[0],
      })
    }

    //initially sort by project name
    subscopes.sort((a, b) => a.metadata.name.localeCompare(b.metadata.name))

    this.setState({
      ...this.state,
      subscopes,
      isFetching: false,
    })
  }

  setSubscopeQuota = (subscopeID, newQuota) => {
    //assemble scopeData for the subscope described by this <DetailsResource/>
    const scope = new Scope(this.props.scopeData)
    const subscopeData = scope.descendIntoSubscope(subscopeID)
    const subscope = new Scope(subscopeData)

    //assemble request body for Limes
    const limesRequestBody = {}
    limesRequestBody[subscope.level()] = {
      services: [
        {
          type: this.props.category.serviceType,
          resources: [
            {
              name: this.props.resource.name,
              quota: newQuota,
            },
          ],
        },
      ],
    }

    return new Promise((resolve, reject) =>
      this.props
        .setQuota(subscopeData, limesRequestBody, {})
        .then(() => {
          this.handleSubscopeQuotaUpdated(subscopeID, newQuota)
          resolve()
        })
        .catch((response) => {
          this.handleAPIErrors(response.errors)
          reject()
        })
    )
  }

  handleSubscopeQuotaUpdated = (subscopeID, newQuota) => {
    //reload quota/usage data for the main scope asynchronously (this updates
    //the bars at the top of this modal)
    this.props.fetchData(this.props.scopeData)

    //update `this.state.subscopes` to reflect the changed subscope quota
    const subscopes = []
    for (const subscope of this.state.subscopes) {
      //do not change subscopes other than the one we're interested in
      if (subscope.metadata.id != subscopeID) {
        subscopes.push(subscope)
        continue
      }

      const newSubscope = { ...subscope }
      newSubscope.resource = { ...subscope.resource }
      newSubscope.resource.quota = newQuota
      subscopes.push(newSubscope)
    }
    this.setState({
      ...this.state,
      subscopes,
      apiErrors: null, //clear errors from previous attempts
    })
  }

  close = (e) => {
    if (e) {
      e.stopPropagation()
    }
    this.setState({ show: false })
    const { currentArea } = this.props.match.params
    setTimeout(() => this.props.history.replace(`/${currentArea}`), 300)
  }

  //This gets called when a PUT request to Limes fails.
  handleAPIErrors = (errors) => {
    this.setState({
      ...this.state,
      isFetching: false,
      isSubmitting: false,
      apiErrors: errors,
    })
  }

  render() {
    const { categoryName, resourceName } = this.props
    const { isFetching, apiErrors } = this.state

    const scope = new Scope(this.props.scopeData)
    const Resource = scope.resourceComponent()
    const columns = scope.isCluster()
      ? clusterDataTableColumns
      : domainDataTableColumns

    //these props are passed on to the Resource children verbatim
    const forwardProps = {
      flavorData: this.props.flavorData,
      scopeData: this.props.scopeData,
      metadata: this.props.metadata,
      categoryName: this.props.categoryName,
      resource: this.props.resource,
    }

    //NOTE: className='resources' on Modal ensures that plugin-specific CSS rules get applied
    return (
      <Modal
        className="resources"
        backdrop="static"
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg"
      >
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Details for: {`${t(categoryName)} > ${t(resourceName)}`}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body className="clearfix">
          {apiErrors && <FormErrors errors={apiErrors} />}
          <ReloadIndicator isReloading={this.props.isFetching}>
            <Resource
              wide={true}
              captionOverride="Quota usage"
              {...forwardProps}
            />
            <Resource
              wide={true}
              captionOverride="Resource usage"
              showUsage={true}
              {...forwardProps}
            />
          </ReloadIndicator>

          {isFetching ? (
            <p>
              <span className="spinner" /> Loading {scope.sublevel()}s...
            </p>
          ) : (
            <>
              <div className="toolbar searchToolbar">
                <SearchField
                  value={this.state.searchTerm}
                  onChange={(term) => this.setState({ searchTerm: term })}
                  placeholder="Name or ID"
                />
              </div>
              <DataTable
                columns={columns}
                pageSize={8}
                searchText={this.state.searchTerm}
              >
                {(this.state.subscopes || []).map((subscopeProps) => (
                  <DetailsResource
                    key={subscopeProps.metadata.id}
                    {...subscopeProps}
                    canEdit={this.props.canEdit}
                    scopeData={this.props.scopeData}
                    setQuota={this.setSubscopeQuota}
                    handleAPIErrors={this.handleAPIErrors}
                  />
                ))}
              </DataTable>
            </>
          )}
        </Modal.Body>

        <Modal.Footer>
          <Button onClick={this.close}>Done</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
