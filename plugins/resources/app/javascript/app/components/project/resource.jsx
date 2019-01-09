import { byUIString, t } from '../../utils';

export default class ProjectResource extends React.Component {
  state = {}

  render() {
    return (
      <div className='row'>
        <div className='col-md-2'>{t(this.props.resource.name)}</div>
      </div>
    );
  }
}
