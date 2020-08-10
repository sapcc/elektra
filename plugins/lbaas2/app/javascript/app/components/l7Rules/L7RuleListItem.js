import { useEffect,useState, useMemo } from 'react'
import useCommons from '../../../lib/hooks/useCommons'
import CopyPastePopover from '../shared/CopyPastePopover'
import StateLabel from '../shared/StateLabel'
import StatusLabel from '../shared/StatusLabel'
import StaticTags from '../StaticTags';
import useL7Rule from '../../../lib/hooks/useL7Rule';
import SmartLink from "../shared/SmartLink"
import { policy } from "policy";
import { scope } from "ajax_helper";

const L7RuleListItem = ({props, listenerID, l7PolicyID, l7Rule, searchTerm}) => {
  const {MyHighlighter,matchParams,errorMessage, searchParamsToString} = useCommons()
  const {deleteL7Rule, displayInvert,persistL7Rule} = useL7Rule()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  let polling = null

  useEffect(() => {
    const params = matchParams(props)
    setLoadbalancerID(params.loadbalancerID)

    if(l7Rule.provisioning_status.includes('PENDING')) {
      startPolling(5000)
    } else {
      startPolling(30000)
    }

    return function cleanup() {
      stopPolling()
    };
  })

  const startPolling = (interval) => {   
    // do not create a new polling interval if already polling
    if(polling) return;
    polling = setInterval(() => {
      console.log("Polling l7 rule -->", l7Rule.id, " with interval -->", interval)
      persistL7Rule(loadbalancerID, listenerID, l7PolicyID, l7Rule.id).catch( (error) => {
        // console.log(JSON.stringify(error))
      })
    }, interval
    )
  }

  const stopPolling = () => {
    console.log("stop polling for l7rule id -->", l7Rule.id)
    clearInterval(polling)
    polling = null
  }

  const canEdit = useMemo(
    () => 
      policy.isAllowed("lbaas2:l7rule_update", {
        target: { scoped_domain_name: scope.domain }
      }),
    [scope.domain]
  );

  const canDelete = useMemo(
    () => 
      policy.isAllowed("lbaas2:l7rule_delete", {
        target: { scoped_domain_name: scope.domain }
      }),
    [scope.domain]
  );

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    deleteL7Rule(loadbalancerID, listenerID, l7PolicyID, l7Rule).then(() => {
    })
  }

  return ( 
    <tr>
      <td className="snug-nowrap">
        <CopyPastePopover text={l7Rule.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids"  searchTerm={searchTerm}/>
      </td>
      <td>
        <StateLabel label={l7Rule.operating_status} /><br/>
        <StatusLabel label={l7Rule.provisioning_status} />
      </td>
      <td>
        <StaticTags tags={l7Rule.tags} shouldPopover={true}/>
      </td>
      <td className="word-break">
        <MyHighlighter search={searchTerm}>{l7Rule.type}</MyHighlighter><br/>
        {l7Rule.compare_type}
      </td>
      <td>
        {displayInvert(l7Rule.invert)}
      </td>
      <td>
        <CopyPastePopover text={l7Rule.key} size={12} />
      </td>
      <td>
        <CopyPastePopover text={l7Rule.value} size={12}  searchTerm={searchTerm}/>
      </td>
      <td>
        <div className='btn-group'>
          <button
            className='btn btn-default btn-sm dropdown-toggle'
            type="button"
            data-toggle="dropdown"
            aria-expanded={true}>
            <span className="fa fa-cog"></span>
          </button>
          <ul className="dropdown-menu dropdown-menu-right" role="menu">
            <li>
              <SmartLink 
                to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${l7Rule.id}/edit?${searchParamsToString(props)}`}
                isAllowed={canEdit} 
                notAllowedText="Not allowed to edit. Please check with your administrator.">
                  Edit
              </SmartLink>
            </li>
            <li>
              <SmartLink 
                onClick={handleDelete} 
                isAllowed={canDelete} 
                notAllowedText="Not allowed to delete. Please check with your administrator.">
                  Delete
              </SmartLink>
            </li>
          </ul>
        </div>
      </td>
    </tr>
  );
}
 
export default L7RuleListItem;