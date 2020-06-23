import { useEffect, useState } from 'react'
import HelpPopover from '../shared/HelpPopover'
import { useGlobalState } from '../StateProvider'
import useCommons from '../../../lib/hooks/useCommons'
import useHealthMonitor from '../../../lib/hooks/useHealthMonitor'
import {DefeatableLink} from 'lib/components/defeatable_link';
import usePool from '../../../lib/hooks/usePool'
import ErrorPage from '../ErrorPage';
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import { addNotice, addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';
import CopyPastePopover from '../shared/CopyPastePopover'
import { Link } from 'react-router-dom';

const HealthMonitor = ({props, loadbalancerID }) => {
  const {deleteHealthmonitor,persistHealthmonitor, httpMethodRelation, expectedCodesRelation, urlPathRelation, resetState} = useHealthMonitor()
  const poolID = useGlobalState().pools.selected
  const pools = useGlobalState().pools.items
  const {findPool,persistPool} = usePool()
  const {searchParamsToString,matchParams,errorMessage} = useCommons()
  const state = useGlobalState().healthmonitors

  useEffect(() => {   
    initialLoad()
  }, [poolID]);

  const initialLoad = () => {
    // if pool selected
    if (poolID) {
      // find the pool to get the health monitor id      
      const pool = findPool(pools, poolID)
      if (pool && pool.healthmonitor_id) {
        console.log("FETCH HEALTH MONITOR")
        persistHealthmonitor(loadbalancerID, poolID, pool.healthmonitor_id, null).then((data) => {
        }).catch( error => {
        })
      } else {
        // reset state
        resetState()
      }
    }
  }

  const onRemoveClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const healthmonitorID = healthmonitor.id.slice()
    const healthmonitorName = healthmonitor.name.slice()
    return deleteHealthmonitor(lbID, poolID, healthmonitorID,healthmonitorName).then((response) => {
      addNotice(<React.Fragment>Health Monitor <b>{healthmonitorName}</b> ({healthmonitorID}) is being deleted.</React.Fragment>)
      // fetch the pool again containing the new healthmonitor so it gets updated fast
      persistPool(lbID,poolID).then(() => {
      }).catch(error => {
      })
    }).catch(error => {
      addError(React.createElement(ErrorsList, {
        errors: errorMessage(error.response)
      }))
    })
  }

  const error = state.error
  const healthmonitor = state.item
  const isLoading = state.isLoading

  const displayName = () => {
    if (healthmonitor.name) {
      return healthmonitor.name
    } else {
      return <CopyPastePopover text={healthmonitor.id} shouldPopover={false} />
    }    
  }

  const displayID = () => {
    if (healthmonitor.name) {
      return  <span className="info-text"><CopyPastePopover text={healthmonitor.id} shouldPopover={false} bsClass="cp copy-paste-ids"/></span>
    }  
  }

  return ( 
    <React.Fragment>
      {poolID &&
        <React.Fragment>
          {error ?
            <div className="healthmonitor subtable multiple-subtable-left">
              <ErrorPage headTitle="Health Monitor" error={error} onReload={initialLoad}/>
            </div>
          :
            <div className="healthmonitor subtable multiple-subtable-left">
              <div className="display-flex multiple-subtable-header">
                <h4>Health Monitor</h4>
                <HelpPopover text="Checks the health of the pool members. Unhealthy members will be taken out of traffic schedule. Set's a load balancer to OFFLINE when all members are unhealthy." />
              </div>

              <div className="toolbar searchToolbar">
                  { healthmonitor ?
                    <div className="main-buttons">
                      <div className='btn-group   '>
                        <button
                          className='btn btn-default btn-xs dropdown-toggle'
                          type="button"
                          data-toggle="dropdown"
                          aria-expanded={true}>
                          <span className="fa fa-cog"></span>
                        </button>
                        <ul className="dropdown-menu dropdown-menu-right" role="menu">
                          <li>              
                            <Link to={`/loadbalancers/${loadbalancerID}/pools/${poolID}/healthmonitor/${healthmonitor.id}/edit?${searchParamsToString(props)}`}>
                              Edit
                            </Link>
                          </li>
                          <li>
                            <Link to="#" onClick={onRemoveClick}>
                              Delete
                            </Link>
                          </li>
                        </ul>
                      </div>
                    </div>
                  :
                    <div className="main-buttons">
                      <DefeatableLink
                        disabled={isLoading}
                        to={`/loadbalancers/${loadbalancerID}/pools/${poolID}/healthmonitor/new?${searchParamsToString(props)}`}
                        className='btn btn-primary btn-xs'>
                        New Health Monitor
                      </DefeatableLink>
                    </div>
                  }     
              </div>  

              {healthmonitor ?
                <div className="list multiple-subtable-scroll-body">

                  <div className="list-entry">
                    <div className="row">
                      <div className="col-md-12">
                        <b>Name/ID:</b>
                      </div>   
                    </div>

                    <div className="row">
                      <div className="col-md-12">
                        {healthmonitor.name || healthmonitor.id}
                      </div>
                    </div>

                    {healthmonitor.name && 
                      <div className="row">
                        <div className="col-md-12 text-nowrap">
                          {displayID()}
                        </div>
                      </div>
                    }
                  </div>

                  <div className="list-entry">
                    <div className="row">
                      <div className="col-md-12">
                        <b>State/Provisioning Status:</b>
                      </div>
                    </div>

                    <div className="row">
                      <div className="col-md-12">
                        <div className="display-flex">
                          <span>
                            <StateLabel placeholder={healthmonitor.operating_status} path="" />
                          </span>
                          <span className="label-right">
                            <StateLabel placeholder={healthmonitor.provisioning_status} path="" />
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="list-entry">
                    <div className="row">
                      <div className="col-md-12">
                        <b>Tags:</b>
                      </div>
                    </div>
                    <div className="row">
                      <div className="col-md-12">
                        <StaticTags tags={healthmonitor.tags}/>
                      </div>
                    </div>
                  </div>

                  <div className="list-entry">
                    <div className="row">
                      <div className="col-md-12">
                        <b>Type:</b>
                      </div>
                    </div>
                    <div className="row">
                      <div className="col-md-12">
                        {healthmonitor.type}
                      </div>
                    </div>
                  </div>

                  <div className="list-entry">
                    <div className="row">
                      <div className="col-md-12">
                        <b>Retries/Timeout/Delay:</b>
                      </div>
                    </div>
                    <div className="row">
                      <div className="col-md-12">
                        {healthmonitor.max_retries} / {healthmonitor.timeout} / {healthmonitor.delay}
                      </div>
                    </div>
                  </div>

                  {httpMethodRelation(healthmonitor.type) &&
                    <div className="list-entry">
                      <div className="row">
                        <div className="col-md-12">
                          <b>HTTP Method:</b>
                        </div>
                      </div>
                      <div className="row">
                        <div className="col-md-12">
                          {healthmonitor.http_method}
                        </div>
                      </div>
                    </div>
                  }

                  {expectedCodesRelation(healthmonitor.type) &&
                    <div className="list-entry">
                      <div className="row">
                        <div className="col-md-12">
                          <b>Expected Codes:</b>
                        </div>
                      </div>
                      <div className="row">
                        <div className="col-md-12">
                          {healthmonitor.expected_codes}
                        </div>
                      </div>
                    </div>
                  }

                  {urlPathRelation(healthmonitor.type) &&
                    <div className="list-entry">
                      <div className="row">
                        <div className="col-md-12">
                          <b>URL Path:</b>
                        </div>
                      </div>
                      <div className="row">
                        <div className="col-md-12">
                          {healthmonitor.url_path}
                        </div>
                      </div>
                    </div>
                  }

                </div>
              :
                <div className="multiple-subtable-scroll-body">
                  { isLoading ? <span className='spinner'/> : 'No Health Monitor found' }
                </div>
              }
            </div>
          }        
        </React.Fragment>
      }
    </React.Fragment>
   );
}
 
export default HealthMonitor;