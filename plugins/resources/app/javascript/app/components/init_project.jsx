import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import { FormErrors } from 'lib/elektra-form/components/form_errors';

import { WIZARD_RESOURCES } from '../constants';
import { Unit } from '../unit';
import { t, byUIString, byNameIn } from '../utils';

export default class InitProjectModal extends React.Component {
  state = {
    isAvailable: null,
    isSelected: null,
    isChecking: false,
    isSubmitting: false,
    apiErrors: null,
  };

  componentDidMount() {
    this.checkAvailabilityOnce(this.props);
  }
  componentWillReceiveProps(nextProps) {
    this.checkAvailabilityOnce(nextProps);
  }

  //Computes the resource packages offered by this modal. Result looks like:
  //
  //    {
  //      categoryName: {
  //        resourceName: { "quota": 1, "quotaText": "1 GiB", "isHighlighted": true },
  //        ...
  //      },
  //      ...
  //    }
  resourceValues() {
    const { categories } = this.props;
    if (!categories) {
      //data from Limes is not yet loaded
      return null;
    }

    const result = {};
    for (const categoryName in WIZARD_RESOURCES) {
      const categoryConf = WIZARD_RESOURCES[categoryName];
      const category = categories[categoryName];
      if (!category) {
        continue;
      }

      //if WIZARD_RESOURCES does not state anything explicitly, highlight
      //all the explicitly listed resources
      const isHighlighted = categoryConf.highlight
        ? name => categoryConf.highlight.indexOf(name) > -1
        : name => categoryConf.resources[name] > 0;

      const categoryResult = {};
      for (const resource of category.resources) {
        let quotaValue;
        if (categoryConf.resources[resource.name]) {
          //consider resources that are either explicitly listed in WIZARD_RESOURCES...
          quotaValue = categoryConf.resources[resource.name];
        } else if (resource.scales_with && categoryConf.resources[resource.scales_with.resource_name]) {
          //...or which follow a resource that is
          quotaValue = categoryConf.resources[resource.scales_with.resource_name]
            * resource.scales_with.factor;
        } else {
          continue;
        }

        const unit = new Unit(resource.unit);
        categoryResult[resource.name] = {
          quota: quotaValue,
          quotaText: unit.format(quotaValue),
          isHighlighted: isHighlighted(resource.name),
        };
      }

      result[categoryName] = categoryResult;
    }
    return result;
  }

  makeRequestBody(props, isSelected) {
    const values = this.resourceValues();

    const services = [];
    for (const categoryName in values) {
      if (!isSelected[categoryName]) {
        continue;
      }

      const serviceType = props.categories[categoryName].serviceType;
      let serviceIdx = services.findIndex(srv => srv.type == serviceType);
      if (serviceIdx < 0) {
        serviceIdx = services.length;
        services.push({ type: serviceType, resources: [] });
      }

      for (const resourceName in values[categoryName]) {
        const quota = values[categoryName][resourceName].quota;
        services[serviceIdx].resources.push({ name: resourceName, quota });
      }
    }
    return { project: { services } };
  }

  checkAvailabilityOnce(props) {
    //can only do this once we have quota data for the project
    const { categories } = this.props;
    if (!categories) {
      return;
    }

    //initialize state.isSelected -> this also ensures that this function runs only once
    if (this.state.isSelected) {
      return;
    }
    const isSelected = {};
    const isAvailable = {};
    for (const categoryName in WIZARD_RESOURCES) {
      isSelected[categoryName] = WIZARD_RESOURCES[categoryName].preselect ? true : false;
      isAvailable[categoryName] = true; //until disproven
    }
    this.setState({
      ...this.state,
      isSelected,
      isAvailable,
      isChecking: true,
    });

    //simulate a PUT request for each package to determine if it really is available
    const promises = [];
    for (const categoryName in WIZARD_RESOURCES) {
      const onlyOneSelected = {};
      onlyOneSelected[categoryName] = true;

      promises.push(new Promise((resolve, _) => {
        props.simulateSetQuota(
          props.scopeData,
          this.makeRequestBody(props, onlyOneSelected),
        ).catch(response => {
          this.handleAPIErrors(response.errors);
          resolve();
        }).then(response => {
          if (!response.data.success) {
            const isSelected = { ...this.state.isSelected };
            const isAvailable = { ...this.state.isAvailable };
            isSelected[categoryName] = false;
            isAvailable[categoryName] = false;
            this.setState({ ...this.state, isSelected, isAvailable });
          }
          resolve();
        });
      }));
    }

    //uncover the UI once all those checks are done
    Promise.all(promises).then(() => {
      this.setState({ ...this.state, isChecking: false });
    });
  }

  toggleCategory(categoryName) {
    const isSelected = { ...this.state.isSelected };
    isSelected[categoryName] = !isSelected[categoryName];
    if (!this.state.isAvailable[categoryName]) {
      isSelected[categoryName] = false;
    }
    this.setState({ ...this.state, isSelected });
  }

  // close() {
  //   Dashboard.hideModal();
  //   document.location.reload();
  // }

  //This gets called when a PUT request to Limes or Elektra fails.
  handleAPIErrors(errors) {
    this.setState({
      ...this.state,
      isSubmitting: false,
      apiErrors: errors,
    });
  };


  render() {
    const { scopeData, docsUrl } = this.props;
    const resourceValues = this.resourceValues();
    if (!resourceValues) {
      //data from Limes is not yet loaded
      return null;
    }
    if (this.state.isChecking) { 
      //availability checks are not yet done
      return <div className='modal-body'>
        <p><span className='spinner'/> Checking package availability...</p>
      </div>;
    }

    //sorting predicate for categories: sort by area, then like on the main view
    const infoForCategory = {};
    for (const area of Object.keys(this.props.overview.areas)) {
      const serviceTypes = this.props.overview.areas[area];
      for (const serviceType of serviceTypes) {
        for (const categoryName of this.props.overview.categories[serviceType]) {
          infoForCategory[categoryName] = { serviceType, area };
        }
      }
    }
    const byAreaThenByName = (categoryNameA, categoryNameB) => {
      const infoA = infoForCategory[categoryNameA];
      const infoB = infoForCategory[categoryNameB];
      if (infoA.area != infoB.area)
        return byUIString(infoA.area, infoB.area);
      if (infoA.serviceType != infoB.serviceType)
        return byUIString(infoA.serviceType, infoB.serviceType);
      return byNameIn(infoA.serviceType)(categoryNameA, categoryNameB);
    };

    return (
      //NOTE: class='resources' is needed for CSS rules from plugins/resources/ to apply
      <React.Fragment>
        <div className='modal-body resources'>
          {this.state.apiErrors && <FormErrors errors={this.state.apiErrors}/>}
          <p>
            Please select an initial allotment of resources for your project. Note that:
          </p>
          <ul>
            <li>Quota assignments for some resources incur costs according to our
              {" "}
              <a href={`${docsUrl}docs/start/pricing.html`}>price list</a>.</li>
            <li>You can always change your quotas later on. Large quota requests may be
              {" "}
              <a href={`${docsUrl}docs/quota/#auto-approval`}>subject to approval</a>.</li>
          </ul>
          <div id='package-selection'>
            { Object.keys(resourceValues).sort(byAreaThenByName).map(categoryName => this.renderPackage(categoryName, resourceValues[categoryName])) }
          </div>
        </div>
        <div className='buttons modal-footer'>
          <div className='btn btn-primary'>Submit</div>
          <div className='btn btn-default' onClick={() => Dashboard.hideModal()}>Cancel</div>
        </div>
      </React.Fragment>
    );
  }

  renderPackage(categoryName, resources) {
    const highlightedResources = [];
    const mutedResources = [];
    const resourceNames = Object.keys(resources).sort(byUIString);

    for (let resourceName of resourceNames) {
      const resource = resources[resourceName];
      const typeText = resource.quotaText == '1'
        ? t(resourceName + '_single')
        : t(resourceName);

      if (resource.isHighlighted) {
        highlightedResources.push(<div key={resourceName}>{resource.quotaText} {typeText}</div>);
      } else {
        mutedResources.push(<div key={resourceName}>{resource.quotaText} {typeText}</div>);
      }
    }

    const isSelected  = (this.state.isSelected  || {})[categoryName];
    const isAvailable = (this.state.isAvailable || {})[categoryName];
    let classes = 'package';
    if (isSelected) {
      classes += ' is-selected';
    }
    if (!isAvailable) {
      classes += ' is-unavailable';
    }

    const box = (
      <div className={classes} key={categoryName} onClick={(e) => { e.preventDefault(); this.toggleCategory(categoryName); return false; }}>
        <h3>
          <i className={isSelected ? 'fa fa-check-square' : 'fa fa-square-o'} />
          {' ' + t(categoryName)}
        </h3>
        <div className='highlighted-resources'>{highlightedResources}</div>
        {mutedResources.length > 0 && <div className='muted-resources'>{mutedResources}</div>}
      </div>
    );

    if (isAvailable) {
      return box;
    } else {
      const tooltip = <Tooltip id={`package-unavailable-${categoryName}`}>This package is not available right now, most likely because of missing domain quota. If you cannot proceed without it, please get in touch with your domain resource admin.</Tooltip>;
      return <OverlayTrigger overlay={tooltip} placement='top' key={categoryName}>{box}</OverlayTrigger>;
    }
  }
}
