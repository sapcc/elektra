import { t } from '../../utils';

export default class AutoscalingView extends React.Component {
  state = {
    currentFullResource: '',
  }

  handleSelect(fullResource) {
    this.setState({ ...this.state, currentFullResource: fullResource });
  }

  render() {
    const { autoscalableSubscopes } = this.props;
    const { currentFullResource } = this.state;

    //assemble options for <select> box
    const options = [];
    for (const srvType in autoscalableSubscopes) {
      for (const resName in autoscalableSubscopes[srvType]) {
        const subscopes = autoscalableSubscopes[srvType][resName];
        if (subscopes.length > 0) {
          options.push({
            key: `${srvType}/${resName}`,
            label: `${t(srvType)} > ${t(resName)} (?/${subscopes.length})`,
          });
        }
      }
    }
    options.sort((a, b) => a.label.localeCompare(b.label));

    return (
      <React.Fragment>
        <select className='form-control' onChange={(e) => this.handleSelect(e.target.value)} value={currentFullResource}>
          {currentFullResource == '' && <option value=''>-- Select a resource --</option>}
          {options.map(opt => (
            <option key={opt.key} value={opt.key}>{opt.label}</option>
          ))}
        </select>
      </React.Fragment>
    );

    return <p>Hello</p>;
  }
}
