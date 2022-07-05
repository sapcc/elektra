import { Link } from 'react-router-dom';

const percent = (val) => {
  return `${val}\u{00A0}%`;
};

const duration = (val) => {
  let unit = 'second';
  if (val % 60 == 0) {
    val /= 60;
    unit = 'minute';
  }
  if (val % 60 == 0) {
    val /= 60;
    unit = 'hour';
  }
  if (val != 1) {
    unit += 's';
  }
  return `${val}\u{00A0}${unit}`;
};

export default class CastellumConfigurationView extends React.Component {
  render() {
    const { data: config } = this.props.config;

    if (config == null) {
      return (
        <React.Fragment>
          <p>Autoscaling is not enabled for this project.</p>
          <p><Link to='/autoscaling/configure' className='btn btn-primary'>Configure</Link></p>
        </React.Fragment>
      );
    }

    return (
      <React.Fragment>
        <p>Autoscaling is enabled:</p>
        <ul>
          {config.low_threshold && <li>Shares will be shrunk when usage is below <strong>{percent(config.low_threshold.usage_percent)}</strong> for <strong>{duration(config.low_threshold.delay_seconds)}</strong>.</li>}
          {config.high_threshold && <li>Shares will be extended when usage exceeds <strong>{percent(config.high_threshold.usage_percent)}</strong> {config.size_constraints && config.size_constraints.minimum_free && <React.Fragment>(or when free space is below <strong>{config.size_constraints.minimum_free} GiB</strong>)</React.Fragment>} for <strong>{duration(config.high_threshold.delay_seconds)}</strong>.</li>}
          {config.critical_threshold && <li>Shares will be extended immediately when usage exceeds <strong>{percent(config.critical_threshold.usage_percent)}</strong>.</li>}
        </ul>
        <p>
          Shares will be resized{" "}
          {config.size_steps.single ? <React.Fragment>
            using <a href="https://github.com/sapcc/castellum/blob/master/docs/api-spec.md#stepping-strategies" target="_blank">single-step resizing</a>
          </React.Fragment> : <React.Fragment>
            in steps of <strong>{percent(config.size_steps.percent)}</strong>
          </React.Fragment>}
          {config.size_constraints ? ", but..." : "."}
        </p>
        {config.size_constraints && (
          <ul>
            {config.size_constraints.minimum && <li>...never to a total size below <strong>{config.size_constraints.minimum} GiB</strong>.</li>}
            {config.size_constraints.maximum && <li>...never to a total size above <strong>{config.size_constraints.maximum} GiB</strong>.</li>}
            {config.size_constraints.minimum_free && <li>...never below <strong>{config.size_constraints.minimum_free} GiB</strong> of free space.</li>}
          </ul>
        )}
        <p>
          <Link to='/autoscaling/configure' className='btn btn-primary'>Configure</Link>
          {" "}
          <button className="btn btn-danger" onClick={() => this.props.disableAutoscaling(this.props.projectID)}>Disable autoscaling</button>
        </p>
      </React.Fragment>
    );
  }
}
