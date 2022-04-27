import { connect } from  'react-redux';
import NewReplicaModal from '../../components/replicas/new';
import { submitNewReplicaForm } from '../../actions/replicas';

export default connect(
  // these are the values that are available in the component new.jsx form 
  (state,ownProps) => {
    let share;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id) {
      let shares = state.shares.items
      if (shares) share = shares.find(item => item.id==ownProps.match.params.id)
    }
    return {
      availabilityZones: state.availabilityZones,
      share_id: share['id']
    }
  },
  // these are the values that are send to elektra controller
  (dispatch,ownProps) => ({
    handleSubmit: (values) => dispatch(submitNewReplicaForm(
      Object.assign(values,{share_id:ownProps.match.params.id})
    ))
  })
)(NewReplicaModal);
