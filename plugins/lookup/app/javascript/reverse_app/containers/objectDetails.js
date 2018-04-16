import { connect } from  'react-redux';
import ObjectDetails from '../components/objectDetails';
import { fetchObjectInfo } from '../actions/object'

const mapStateToProps = state => {
  return {
    project: state.project,
    domain: state.domain,
    parents: state.parents,
    users: state.users,
    groups: state.groups,
  }
}

const mapDispatchToProps = dispatch => {
  return {
    fetchObjectInfo: (searchValue,objectId,searchBy) => dispatch(fetchObjectInfo(searchValue,objectId,searchBy))
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ObjectDetails);
