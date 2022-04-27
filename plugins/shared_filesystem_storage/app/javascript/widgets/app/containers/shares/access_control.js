import { connect } from  'react-redux';
import AccessControlModal from '../../components/shares/access_control';
import { submitNewShareRule, deleteShareRule} from '../../actions/share_rules';

export default connect(
  (state,ownProps ) => {
    let share;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id) {
      let shares = state.shares.items
      if (shares) share = shares.find(item => item.id==ownProps.match.params.id)
    }
    let shareNetwork;
    if (state.shareNetworks.items && share) {
      shareNetwork = state.shareNetworks.items.find(sn => sn.id==share.share_network_id)
    }
    let shareRules;
    if (state.shareRules && share) {
      shareRules = (state.shareRules[share.id] || {items: [], isFetching: false})
    }

    return { shareRules, shareNetwork, share }
  },
  (dispatch,ownProps) => ({
    handleSubmit: (values) => dispatch(submitNewShareRule(
      Object.assign(values,{shareId: ownProps.match.params.id})
    )),
    handleDelete: (shareId,ruleId) => dispatch(deleteShareRule(shareId,ruleId))
  })
)(AccessControlModal);
