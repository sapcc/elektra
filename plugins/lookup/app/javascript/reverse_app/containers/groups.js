import { connect } from  'react-redux';
import Groups from '../components/groups';
import { fetchGroupMembers } from '../actions/groupMembers'

const mapStateToProps = (state) => {
  return {
    groupMembers: state.groupMembers
  }
}

const mapDispatchToProps = dispatch => {
  return {
    fetchGroupMembers: (groupId) => dispatch(fetchGroupMembers(groupId))
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Groups);
