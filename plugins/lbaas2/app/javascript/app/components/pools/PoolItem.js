import { useEffect, useState, useMemo } from 'react'
import { Link } from 'react-router-dom';
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import CopyPastePopover from '../shared/CopyPastePopover'
import CachedInfoPopover from '../shared/CachedInforPopover';
import CachedInfoPopoverContent from './CachedInfoPopoverContent'
import CachedInfoPopoverContentListeners from './CachedInfoPopoverContentListeners'
import CachedInfoPopoverContentContainers from '../shared/CachedInfoPopoverContentContainers'
import usePool from '../../../lib/hooks/usePool'
import useCommons from '../../../lib/hooks/useCommons'
import { addNotice, addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import { policy } from "policy";
import { scope } from "ajax_helper";
import SmartLink from "../shared/SmartLink"
import { reset } from 'numeral';

const PoolItem = ({props, pool, searchTerm, disabled}) => {
  const {persistPool,deletePool,onSelectPool, reset} = usePool()
  const {MyHighlighter,matchParams,errorMessage} = useCommons()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const {persistLoadbalancer} = useLoadbalancer()
  let polling = null

  useEffect(() => {
    const params = matchParams(props)
    setLoadbalancerID(params.loadbalancerID)

    if(pool.provisioning_status.includes('PENDING')) {
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
      console.log("Polling pool -->", pool.id, " with interval -->", interval)
      persistPool(loadbalancerID,pool.id).catch( (error) => {
        if(error && error.status == 404) {
          // check if the pool is selected and if yes deselect the item
          if(disabled){
            reset()
          }
        } 
      })
    }, interval
    )
  }

  const stopPolling = () => {
    console.log("stop polling for pool id -->", pool.id)
    clearInterval(polling)
    polling = null
  }

  const canDelete = useMemo(
    () => 
      policy.isAllowed("lbaas2:pool_delete", {
        target: { scoped_domain_name: scope.domain }
      }),
    [scope.domain]
  );

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    const poolID = pool.id
    const poolName = pool.name
    return deletePool(loadbalancerID, poolID, poolName).then((response) => {
      addNotice(<React.Fragment>Pool <b>{poolName}</b> ({poolID}) is being deleted.</React.Fragment>)
      // fetch the lb again containing the new listener so it gets updated fast
      persistLoadbalancer(loadbalancerID).catch(error => {
      })
      // TODO: back to the poles      
    }).catch(error => {
      addError(React.createElement(ErrorsList, {
        errors: errorMessage(error.response)
      }))
    })
  }

  const onPoolClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool(props,pool.id)
  }

  const displayName = () => {
    const name = pool.name || pool.id
    if (disabled) {
      return <div className="info-text"><CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldCopy={false} bsClass="cp copy-paste-ids"/></div>
    } else {
      return <Link to="#" onClick={onPoolClick}>
              <CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldPopover={false} shouldCopy={false} searchTerm={searchTerm}/>
            </Link>
    }
  }
  const displayID = () => {
    if (pool.name) {
      if (disabled) {
        return <div className="info-text"><CopyPastePopover text={pool.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldPopover={false}/></div>
      } else {
        return <CopyPastePopover text={pool.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" searchTerm={searchTerm}/>
      }
    }
  }

  const listenersIDs = pool.listeners.map(m => m.id)
  const displayAssignedTo = () => {
    if (pool.listeners && pool.listeners.length > 0) {
      return (
        <div className="display-flex">
          <span>Listeners:</span>
          <div className="label-right">
            <CachedInfoPopover  popoverId={"pool-listeners-popover-"+listenersIDs.id} 
              buttonName={listenersIDs.length} 
              title={<React.Fragment>Listeners</React.Fragment>}
              content={<CachedInfoPopoverContentListeners props={props} listenerIDs={listenersIDs} cachedListeners={pool.cached_listeners} />} />
          </div>
        </div>
      )
    } else {
      return <React.Fragment>Load Balancer</React.Fragment>
    }
  }

  const displayTLS = () => {
    if (pool.tls_enabled) {
     return <i className="fa fa-check" />
    } else {
      return <i className="fa fa-times" />
    }
  }

  const collectContainers = () => {
    const containers = [
      {name:"Certificate Container", ref: pool.tls_container_ref},
      {name:"Authentication Container (CA)", ref: pool.ca_tls_container_ref}
    ]
    var filteredContainers = containers.reduce( (filteredContainers, item) => {
      if(item.ref && item.ref.length > 0 || item.refList && item.refList.length > 0) {
        filteredContainers.push(item)
      }
      return filteredContainers
    },[])
    return filteredContainers
  }

  const displaySecrets = () => {
    const containers = collectContainers()
    return (
      <React.Fragment>
        {pool.tls_enabled &&
          <div className="display-flex">
            <span>Secrets: </span>
            <div className="label-right">
              <CachedInfoPopover  popoverId={"pool-secrets-popover-"+pool.id} 
                buttonName={containers.length} 
                title={<React.Fragment>Secrets</React.Fragment>}
                content={<CachedInfoPopoverContentContainers containers={containers} />} />
            </div>
          </div>
        }
      </React.Fragment>
    )
  }

  const memberIDs = pool.members.map(m => m.id)
  return ( 
    <tr className={disabled ? "active" : ""}>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
        <CopyPastePopover text={pool.description} size={20} shouldCopy={false} shouldPopover={true} searchTerm={searchTerm}/>
      </td>
      <td>
        <div><StateLabel placeholder={pool.operating_status} path="" /></div>
        <div><StateLabel placeholder={pool.provisioning_status} path=""/></div>
      </td>
      <td>
        <StaticTags tags={pool.tags} />
      </td>
      <td>{pool.lb_algorithm}</td>
      <td><MyHighlighter search={searchTerm}>{pool.protocol}</MyHighlighter></td>
      <td>
        {pool.session_persistence &&
          <div>{pool.session_persistence.type}</div>
        }
        {pool.session_persistence && pool.session_persistence.type == "APP_COOKIE" &&
          <div>{pool.session_persistence.cookie_name}</div>
        }
      </td>
      <td>{displayAssignedTo()}</td>
      <td>
        {displayTLS()}
        {displaySecrets()}
      </td>
      <td>
        {disabled ?
          <span className="info-text">{memberIDs.length}</span>
        :
        <CachedInfoPopover  popoverId={"member-popover-"+memberIDs.id} 
                    buttonName={memberIDs.length} 
                    title={<React.Fragment>Members<Link to="#" onClick={onPoolClick} style={{float: 'right'}}>Show all</Link></React.Fragment>}
                    content={<CachedInfoPopoverContent props={props} lbID={loadbalancerID} poolID={pool.id} memberIDs={memberIDs} cachedMembers={pool.cached_members}/>} />
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
 
export default PoolItem;