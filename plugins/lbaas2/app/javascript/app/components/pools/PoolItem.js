import { useEffect, useState } from 'react'
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

const PoolItem = ({props, pool, searchTerm, onSelectPool, disabled}) => {
  const {persistPool,deletePool} = usePool()
  const {MyHighlighter,matchParams,errorMessage} = useCommons()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const {fetchLoadbalancer} = useLoadbalancer()
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
        // console.log(JSON.stringify(error))
      })
    }, interval
    )
  }

  const stopPolling = () => {
    console.log("stop polling for pool id -->", pool.id)
    clearInterval(polling)
    polling = null
  }

  const onClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool(pool.id)
  }

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
      fetchLoadbalancer(loadbalancerID).then(() => {
      }).catch(error => {
      })
    }).catch(error => {
      addError(React.createElement(ErrorsList, {
        errors: errorMessage(error.response)
      }))
    })
  }

  const onSelectMember = () => {}

  const onShowAllClick = () => {}

  const displayName = () => {
    const name = pool.name || pool.id
    if (disabled) {
        return <span className="info-text"><CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldCopy={false}/></span>
    } else {
      if (searchTerm) {
        return <Link to="#" onClick={onClick}>
                <MyHighlighter search={searchTerm}>{name}</MyHighlighter>
              </Link>
      } else {
        return <Link to="#" onClick={onClick}>
                <MyHighlighter search={searchTerm}><CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldPopover={false} shouldCopy={false}/></MyHighlighter>
              </Link>
      }
    }
  }
  const displayID = () => {
    const copyPasteId = <CopyPastePopover text={pool.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids"/>
    const cutId = <CopyPastePopover text={pool.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldPopover={false}/>
    if (pool.name) {
      if (disabled) {
        return <span className="info-text">{cutId}</span>
      } else {
        if (searchTerm) {
          return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{pool.id}</MyHighlighter></span></React.Fragment>
        } else {
          return copyPasteId
        }        
      }
    }
  }
  const displayDescription = () => {
    const description = <CopyPastePopover text={pool.description} size={20} shouldCopy={false} shouldPopover={true}/>
    if (disabled) {
      return description
    } else {
      if (searchTerm) {
        return <MyHighlighter search={searchTerm}>{pool.description}</MyHighlighter>
      } else {
        return description
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
              content={<CachedInfoPopoverContentListeners listenerIDs={listenersIDs} cachedListeners={pool.cached_listeners} onSelectMember={onSelectMember}/>} />
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
        {displayDescription()}
      </td>
      <td>
        <div><StateLabel placeholder={pool.operating_status} path="" /></div>
        <div><StateLabel placeholder={pool.provisioning_status} path=""/></div>
      </td>
      <td>
        <StaticTags tags={pool.tags} />
      </td>
      <td>{pool.lb_algorithm}</td>
      <td>{pool.protocol}</td>
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
                    title={<React.Fragment>Members<Link to="#" onClick={onShowAllClick} style={{float: 'right'}}>Show all</Link></React.Fragment>}
                    content={<CachedInfoPopoverContent memberIDs={memberIDs} cachedMembers={pool.cached_members} onSelectMember={onSelectMember}/>} />
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
 
export default PoolItem;