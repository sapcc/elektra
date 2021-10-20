import { connect } from "react-redux";
import Items from "../../components/security_group_rules/list";
import { deleteSecurityGroupRule } from "../../actions/security_group_rules";

import {
  fetchSecurityGroup,
  deleteSecurityGroup,
  fetchSecurityGroupsIfNeeded,
} from "../../actions/security_groups";

export default connect(
  (state, ownProps) => {
    let securityGroupRules;
    let securityGroup;
    let securityGroupId =
      ownProps.match &&
      ownProps.match.params &&
      ownProps.match.params.securityGroupId;

    if (securityGroupId) {
      securityGroup = state.securityGroups.items.find(
        (i) => i.id == securityGroupId
      );
      if (securityGroup) {
        securityGroupRules = securityGroup.security_group_rules;
      }
    }

    return {
      securityGroupId,
      securityGroup,
      securityGroupRules,
      securityGroups: state.securityGroups.items,
    };
  },
  (dispatch, ownProps) => {
    let securityGroupId =
      ownProps.match &&
      ownProps.match.params &&
      ownProps.match.params.securityGroupId;
    return {
      handleDelete: (id) =>
        dispatch(deleteSecurityGroupRule(securityGroupId, id)),
      handleGroupDelete: () => dispatch(deleteSecurityGroup(securityGroupId)),
      loadSecurityGroup: () => dispatch(fetchSecurityGroup(securityGroupId)),
      loadSecurityGroupsOnce: () => dispatch(fetchSecurityGroupsIfNeeded()),
    };
  }
)(Items);
