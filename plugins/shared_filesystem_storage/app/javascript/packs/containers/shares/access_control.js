import { connect } from  'react-redux';
import AccessControlModal from '../../components/shares/access_control';
import {
  updateShareRuleForm,
  submitShareRuleForm,
  deleteShareRule,
  hideShareRuleForm,
  shareRuleFormForCreate,
  showShareRuleForm
} from '../../actions/shares'

export default connect(
  ({shared_filesystem_storage: state},ownProps ) => {
    let shareNetwork = state.shareNetworks.items.find(sn => sn.id==ownProps.networkId)
    return {
      shareRules: (state.shareRules[ownProps.shareId] || {items: [], isFetching: false}),
      shareNetwork,
      ruleForm: state.shareRuleForm
    }
  },
  (dispatch,ownProps) => ({
    handleChange: (name,value) => dispatch(updateShareRuleForm(name,value)),
    handleSubmit: () => dispatch(submitShareRuleForm(ownProps.shareId)),
    handleDelete: (ruleId) => dispatch(deleteShareRule(ownProps.shareId,ruleId)),
    hideForm: () => dispatch(hideShareRuleForm()),
    showForm: (shareId) => {
      dispatch(shareRuleFormForCreate(shareId))
      dispatch(showShareRuleForm())
    }
  })
)(AccessControlModal);
