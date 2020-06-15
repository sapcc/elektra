import { useEffect,useState } from 'react'
import CopyPastePopover from '../shared/CopyPastePopover'
import useCommons from '../../../lib/hooks/useCommons'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import useMember from '../../../lib/hooks/useMember'
import usePool from '../../../lib/hooks/usePool'
import { addNotice, addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const MemberListItem = ({props, poolID, member, searchTerm}) => {
  const {MyHighlighter,matchParams,errorMessage} = useCommons()
  const {persistPool} = usePool()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const {persistMember,deleteMember} = useMember()
  let polling = null

  useEffect(() => {
    const params = matchParams(props)
    setLoadbalancerID(params.loadbalancerID)

    if(member.provisioning_status.includes('PENDING')) {
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
      console.log("Polling member -->", member.id, " with interval -->", interval)
      persistMember(loadbalancerID, poolID, member.id).catch( (error) => {
        // console.log(JSON.stringify(error))
      })
    }, interval
    )
  }

  const stopPolling = () => {
    console.log("stop polling for member id -->", member.id)
    clearInterval(polling)
    polling = null
  }

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    const memberID = member.id
    const memberName = member.name
    return deleteMember(loadbalancerID, poolID, memberID, memberName).then((response) => {
      addNotice(<React.Fragment>Member <b>{memberName}</b> ({memberID}) is being deleted.</React.Fragment>)
      // fetch the listener again containing the new policy so it gets updated fast
      persistPool(loadbalancerID, poolID).then(() => {
      }).catch(error => {
      })
    }).catch(error => {
      addError(React.createElement(ErrorsList, {
        errors: errorMessage(error.response)
      }))
    })
  }

  const displayName = () => {
    const name = member.name || member.id  
    if (searchTerm) {
      return <MyHighlighter search={searchTerm}>{name}</MyHighlighter>
    } else {
      return <CopyPastePopover text={name} size={20} sliceType="MIDDLE"/> 
    }
  }

  const displayID = () => {
    if (member.name) {
      if (searchTerm) {
        return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{member.id}</MyHighlighter></span></React.Fragment>
      } else {
        return <CopyPastePopover text={member.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids"/>
      }        
    }
  }

  return (     
    <tr>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
      </td>
      <td>        
        <CopyPastePopover text={member.address} size={12}/>
      </td>
      <td>
        <StateLabel placeholder={member.operating_status} path="" /><br/>
        <StateLabel placeholder={member.provisioning_status} path=""/>
      </td>
      <td>
        <StaticTags tags={member.tags} shouldPopover={true}/>
      </td>
      <td>        
        <CopyPastePopover text={member.protocol_port} size={12}/>
      </td>
      <td>{member.weight}</td>
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
            <li><a href='#' onClick={handleDelete}>Delete</a></li>
          </ul>
        </div>
      </td>
    </tr>
  );
}
 
export default MemberListItem;