import { Link } from 'react-router-dom';

import { byLeaderAndName, t } from '../utils';
import { Scope } from '../scope';

export default class Category extends React.Component {
  state = {}

  render() {
    const { categoryName, canEdit } = this.props;
    const { area, serviceType, resources } = this.props.category;

    const scope = new Scope(this.props.scopeData);
    const Resource = scope.resourceComponent();

    //these props are passed on to the Resource children verbatim
    const forwardProps = {
      flavorData:   this.props.flavorData,
      scopeData:    this.props.scopeData,
      metadata:     this.props.metadata,
      categoryName, area, canEdit,
    };

    return (
      <React.Fragment>
        <h3>
          <div className='row'>
            <div className='col-md-6'>{t(categoryName)}</div>
            {canEdit && !scope.isCluster() && (
              <div className='col-md-1 text-right'>
                <Link to={`/${area}/edit/${categoryName}`} className='btn btn-primary btn-sm btn-edit-quota'>Edit</Link>
              </div>
            )}
          </div>
        </h3>
        {resources.sort(byLeaderAndName).map(res => (
          <Resource key={res.name} resource={res} {...forwardProps} />
        ))}
      </React.Fragment>
    );
  }
}
