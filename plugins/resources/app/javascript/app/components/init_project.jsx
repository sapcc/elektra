import { WIZARD_RESOURCES } from '../constants';
import { Unit } from '../unit';
import { t, byUIString, byNameIn } from '../utils';

export default class InitProjectModal extends React.Component {
  constructor(props) {
    super(props);

    const isSelected = {};
    for (const categoryName in WIZARD_RESOURCES) {
      isSelected[categoryName] = WIZARD_RESOURCES[categoryName].preselect ? true : false;
    }
    this.state = { isSelected };
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

  toggleCategory(categoryName) {
    const isSelected = { ...this.state.isSelected };
    isSelected[categoryName] = !isSelected[categoryName];
    this.setState({ ...this.state, isSelected });
  }

  // close() {
  //   Dashboard.hideModal();
  //   document.location.reload();
  // }

  render() {
    const { scopeData, docsUrl } = this.props;
    const resourceValues = this.resourceValues();
    if (!resourceValues) {
      //data from Limes is not yet loaded
      return null;
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

    const isSelected = this.state.isSelected[categoryName];
    return (
      <div className={isSelected ? 'package is-selected' : 'package'} key={categoryName} onClick={(e) => { e.preventDefault(); this.toggleCategory(categoryName); return false; }}>
        <h3>
          <i className={isSelected ? 'fa fa-check-square' : 'fa fa-square-o'} />
          {' ' + t(categoryName)}
        </h3>
        <div className='highlighted-resources'>{highlightedResources}</div>
        {mutedResources.length > 0 && <div className='muted-resources'>{mutedResources}</div>}
      </div>
    );
  }
}
