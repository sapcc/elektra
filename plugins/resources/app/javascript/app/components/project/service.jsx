import { byUIString, t } from '../../utils';

import ProjectResource from '../../containers/project/resource';

export default class ProjectService extends React.Component {
  state = {}

  render() {
    const serviceType = this.props.serviceType;
    const area        = this.props.service.area || serviceType;
    const categories  = this.props.service.categories;

    //show categories sorted by name, but categories named after their service
    //come first
    const categoryList = Object.keys(categories).sort((a, b) => {
      const aa = a === 'networking' ? 'network' : a;
      const bb = b === 'networking' ? 'network' : b;
      if (aa === serviceType) return -1;
      if (bb === serviceType) return +1;
      return byUIString(aa, bb);
    });

    return (
      <React.Fragment>
        {categoryList.map((category, idx) => (
          <React.Fragment key={category}>
            {(idx !== 0 || t(category) != t(area)) && <h3>{t(category)}</h3>}
            {categories[category].sort(byUIString).map(resourceName => {
              const fullName = `${serviceType}/${resourceName}`;
              return <ProjectResource key={fullName} fullResourceName={fullName} />;
            })}
          </React.Fragment>
        ))}
      </React.Fragment>
    );
  }
}
