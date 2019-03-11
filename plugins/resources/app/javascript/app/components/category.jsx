import { Link } from 'react-router-dom';

import { byLeaderAndName, t } from '../utils';
import ProjectResource from '../components/project/resource';

export default class Category extends React.Component {
  state = {}

  render() {
    const { categoryName, canEdit } = this.props;
    const { serviceType, resources } = this.props.category;
    const scope = new Scope(this.props.scopeData);

    //these props are passed on to the ProjectResource children verbatim
    const forwardProps = {
      flavorData: this.props.flavorData,
      scopeData:  this.props.scopeData,
      metadata:   this.props.metadata,
    };

    return (
      <React.Fragment>
        <h3>
          {canEdit && !scope.isCluster() && (
            <Link to={`/edit/${categoryName}`} className='btn btn-primary btn-sm btn-edit-quota'>Edit</Link>
          )}
          {t(categoryName)}
        </h3>
        {resources.sort(byLeaderAndName).map(res => (
          <ProjectResource key={res.name} resource={res} {...forwardProps} />
        ))}
      </React.Fragment>
    );
  }
}
