import { useEffect,useState } from 'react'
import useCommons from '../../../lib/hooks/useCommons'
import { Link } from 'react-router-dom';
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import CopyPastePopover from '../shared/CopyPastePopover'
import useListener from '../../../lib/hooks/useListener'
import { addNotice, addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';
import CachedInfoPopover from '../shared/CachedInforPopover';
import CachedInfoPopoverContent from './CachedInfoPopoverContent'

const L7PolicyListItem = ({props, l7Policy, searchTerm, tableScroll, listenerID, disabled}) => {
  const {MyHighlighter,matchParams,errorMessage} = useCommons()
  const {actionRedirect, deleteL7Policy, persistL7Policy, onSelectL7Policy} = useL7Policy()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const {persistListener} = useListener()
  let polling = null

  useEffect(() => {
    const params = matchParams(props)
    setLoadbalancerID(params.loadbalancerID)

    if(l7Policy.provisioning_status.includes('PENDING')) {
      startPolling(5000)
    } else {
      startPolling(30000)
    }

    return function cleanup() {
      stopPolling()
    };
  });

  const startPolling = (interval) => {   
    // do not create a new polling interval if already polling
    if(polling) return;
    polling = setInterval(() => {
      console.log("Polling l7 policy -->", l7Policy.id, " with interval -->", interval)
      persistL7Policy(loadbalancerID, listenerID, l7Policy.id).catch( (error) => {
        // console.log(JSON.stringify(error))
      })
    }, interval
    )
  }

  const stopPolling = () => {
    console.log("stop polling for l7policy id -->", l7Policy.id)
    clearInterval(polling)
    polling = null
  }

  const onL7PolicyClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectL7Policy(props, l7Policy.id)
  }

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    const l7policyID = l7Policy.id
    const l7policyName = l7Policy.name
    return deleteL7Policy(loadbalancerID, listenerID, l7policyID, l7policyName).then((response) => {
      addNotice(<React.Fragment>L7 Policy <b>{l7policyName}</b> ({l7policyID}) is being deleted.</React.Fragment>)
      // fetch the listener again containing the new policy so it gets updated fast
      persistListener(loadbalancerID, listenerID).then(() => {
      }).catch(error => {
      })
    }).catch(error => {
      addError(React.createElement(ErrorsList, {
        errors: errorMessage(error.response)
      }))
    })
  }

  const displayName = () => {
    const name = l7Policy.name || l7Policy.id
    if (disabled) {
        return <span className="info-text"><CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldPopover={false} shouldCopy={false} bsClass="cp copy-paste-ids"/></span>
    } else {
      if (searchTerm) {
        return <Link to="#" onClick={onL7PolicyClick}>
                <MyHighlighter search={searchTerm}>{name}</MyHighlighter>
              </Link>
      } else {
        return <Link to="#" onClick={onL7PolicyClick}>
                <MyHighlighter search={searchTerm}><CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldPopover={false} shouldCopy={false}/></MyHighlighter>
              </Link>
      }
    }
  }
  const displayID = () => {
    const copyPasteId = <CopyPastePopover text={l7Policy.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldClose={tableScroll}/>
    if (l7Policy.name) {
      if (disabled) {
        return <span className="info-text"><CopyPastePopover text={l7Policy.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldPopover={false}/></span>
      } else {
        if (searchTerm) {
          return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{l7Policy.id}</MyHighlighter></span></React.Fragment>
        } else {
          return copyPasteId
        }        
      }
    }
  }
  const displayDescription = () => {
    const description = <CopyPastePopover text={l7Policy.description} size={20} shouldCopy={false} shouldClose={tableScroll} shouldPopover={true}/>
    if (disabled) {
      return description
    } else {
      if (searchTerm) {
        return <MyHighlighter search={searchTerm}>{l7Policy.description}</MyHighlighter>
      } else {
        return description
      }
    }
  }

  const l7RuleIDs = l7Policy.rules.map(l7rule => l7rule.id)
  console.log("RENDER L7 Policy Item")
  return ( 
    <tr>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
      </td>
      <td>{displayDescription()}</td>
      <td><StateLabel placeholder={l7Policy.operating_status} path="" /></td>
      <td><StateLabel placeholder={l7Policy.provisioning_status} path=""/></td>
      <td>
        <StaticTags tags={l7Policy.tags} />
      </td>
      <td>{l7Policy.position}</td>
      <td>
        {l7Policy.action}
        {actionRedirect(l7Policy.action).map( (redirect, index) =>
          <span className="display-flex" key={index}>
            <br/><b>{redirect.label}: </b>
            {redirect.value === "redirect_prefix" || redirect.value === "redirect_url" ?
              <CopyPastePopover text={l7Policy[redirect.value]} size={20} shouldClose={tableScroll} bsClass="cp label-right"/>
            :
            <span className="label-right">{l7Policy[redirect.value]}</span>              
            }
          </span>
        )}
      </td>

      <td>
        
        
        {disabled ?
          <span className="info-text">{l7Policy.rules.length}</span>
        :
        <CachedInfoPopover  popoverId={"l7rules-popover-"+l7Policy.id} 
                    buttonName={l7RuleIDs.length} 
                    title={<React.Fragment>L7 Rules<Link to="#" onClick={onL7PolicyClick} style={{float: 'right'}}>Show all</Link></React.Fragment>}
                    content={<CachedInfoPopoverContent props={props} lbID={loadbalancerID} listenerID={listenerID} l7PolicyID={l7Policy.id} l7RuleIDs={l7RuleIDs} cachedl7RuleIDs={l7Policy.cached_rules}/>} />
        }
      
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
            <li><a href='#' onClick={handleDelete}>Delete</a></li>
          </ul>
        </div>
      </td>
    </tr>
   );
}
 
export default L7PolicyListItem;