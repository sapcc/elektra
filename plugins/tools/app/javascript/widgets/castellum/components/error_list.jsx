import { Link } from 'react-router-dom';
import { DataTable } from 'lib/components/datatable';

import { CASTELLUM_ERROR_TYPES } from '../constants';
import ErrorRow from './error_row';

const formatErrorTypeForDisplay = (errorType) => {
  //e.g. "resource-scrape-errors" -> "Resource Scrape Errors"
  return errorType.replace(/-/g, ' ').replace(/\b\w/g, txt => txt.toUpperCase());
};

const sortKeyForSizeChange = props => {
  const { old_size, new_size } = props.error;
  return old_size * 100000 + new_size;
};
const sortKeyForTimestamp = props => {
  const { checked, finished } = props.error;
  return (checked || finished || {}).at || 0;
};

const columnSets = {
  'resource-scrape-errors': [ 'project', 'asset_type', 'timestamp' ],
  'asset-scrape-errors': [ 'project', 'asset', 'timestamp' ],
  'asset-resize-errors': [ 'project', 'asset', 'size', 'timestamp' ],
};
const columnDefs = [
  { key: 'project', label: 'Project', sortStrategy: 'text',
    sortKey: props => props.error.project_id },
  { key: 'asset_type', label: 'Asset type', sortStrategy: 'text',
    sortKey: props => props.error.asset_type },
  { key: 'asset', label: 'Asset', sortStrategy: 'text',
    sortKey: props => `${props.error.asset_type} ${props.error.asset_id}`},
  { key: 'size', label: 'Size', sortStrategy: 'numeric',
    sortKey: sortKeyForSizeChange },
  { key: 'timestamp', label: 'Failed at', sortStrategy: 'numeric',
    sortKey: sortKeyForTimestamp },
];

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
    const { errorType, isFetching, data, errorMessage } = this.props;
    if (isFetching) {
      return <p><span className='spinner' /> Loading errors...</p>;
    }
    if (errorMessage !== null) {
      return <p className='alert alert-danger'>Could not load errors: {errorMessage}</p>;
    }

    const columns = columnSets[errorType].map(columnType => columnDefs.find(def => def.key == columnType));
    return (
      <DataTable className='castellum-error-list' columns={columns} pageSize={6}>
        {data.map((error, idx) => <ErrorRow key={`error${idx}`} error={error} />)}
      </DataTable>
    );

    return <pre>{JSON.stringify(data, null, 2)}</pre>;
  }
}
