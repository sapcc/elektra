import { HashRouter, Route, Redirect } from 'react-router-dom';
import { LIMES_ERROR_TYPES } from '../constants';
import ErrorList from '../containers/error_list';

export default (props) => {
  return (
    <HashRouter>
      <React.Fragment>
        {/* entry point */}
        <Route exact path="/" render={() => <Redirect to={`/${LIMES_ERROR_TYPES[0]}`} />} />

        {/* error list tabs */}
        <Route exact path="/:errorType" render={(props) => <ErrorList errorType={props.match.params.errorType} />} />
      </React.Fragment>
    </HashRouter>
  );
};
