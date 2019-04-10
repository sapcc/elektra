import { WIZARD_RESOURCES } from '../constants';
import { Unit } from '../unit';
import { t, byUIString } from '../utils';

export default class InitProjectModal extends React.Component {
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
    console.log(resourceValues);

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
          <table className='table initial-packages'>
            <thead><tr>
              { Object.keys(resourceValues).map(categoryName => (
                <th key={categoryName}>{t(categoryName)}</th>
              ))}
            </tr></thead>
            <tbody>
              <tr>
                { Object.keys(resourceValues).map(categoryName => (
                  <td key={categoryName}>{this.renderResourceList(resourceValues[categoryName], true)}</td>
                ))}
              </tr>
              <tr className='text-muted'>
                { Object.keys(resourceValues).map(categoryName => (
                  <td key={categoryName}>{this.renderResourceList(resourceValues[categoryName], false)}</td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>
        <div className='buttons modal-footer'>
          <div className='btn btn-primary'>Submit</div>
          <div className='btn btn-default' onClick={() => Dashboard.hideModal()}>Cancel</div>
        </div>
      </React.Fragment>
    );
  }

  renderResourceList(resources, isHighlighted) {
    const rows = [];
    const resourceNames = Object.keys(resources).sort(byUIString);

    for (let resourceName of resourceNames) {
      const resource = resources[resourceName];
      if (resource.isHighlighted != isHighlighted) {
        continue;
      }

      const typeText = resource.quotaText == '1'
        ? t(resourceName + '_single')
        : t(resourceName);
      rows.push(<div key={resourceName}>{resource.quotaText} {typeText}</div>);
    }

    return rows;
  }
}
