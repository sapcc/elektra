import { Link } from 'react-router-dom';

import { CASTELLUM_ERROR_TYPES } from '../constants';

const formatErrorTypeForDisplay = (errorType) => {
  //e.g. "resource-scrape-errors" -> "Resource Scrape Errors"
  return errorType.replace(/-/g, ' ').replace(/\b\w/g, txt => txt.toUpperCase());
};

export default class Loader extends React.Component {
  componentDidMount() {
    this.props.fetchAllErrorsAsNeeded();
  }
  componentDidUpdate() {
    this.props.fetchAllErrorsAsNeeded();
  }

  render() {
    const { errorType: currentErrorType } = this.props;

    return (
      <React.Fragment>
        <nav className='nav-with-buttons'>
          <ul className='nav nav-tabs'>
            { CASTELLUM_ERROR_TYPES.map(errorType => (
              <li key={errorType} role='presentation' className={errorType == currentErrorType ? 'active' : ''}>
                <Link to={`/${errorType}`}>{formatErrorTypeForDisplay(errorType)}</Link>
              </li>
            ))}
          </ul>
        </nav>
        {this.renderContent()}
      </React.Fragment>
    );
  }

  renderContent() {
    const { isFetching, data, errorMessage } = this.props;
    if (isFetching) {
      return <p><span className='spinner' /> Loading errors...</p>;
    }
    if (errorMessage !== null) {
      return <p className='alert alert-danger'>Could not load errors: {errorMessage}</p>;
    }
    return <pre>{JSON.stringify(data, null, 2)}</pre>;
  }
}
