import React from 'react';
import HelpPopover from '../shared/HelpPopover'
import { useGlobalState } from '../StateProvider'
import useCommons from '../../../lib/hooks/useCommons'
import useHealthMonitor from '../../../lib/hooks/useHealthMonitor'
import {DefeatableLink} from 'lib/components/defeatable_link';

const HealthMonitor = ({props, loadbalancerID }) => {
  const {persistHealthMonitor, setSearchTerm, setSelected, reset} = useHealthMonitor()
  const poolID = useGlobalState().pools.selected
  const {searchParamsToString} = useCommons()
  const state = useGlobalState().healthmonitors

  const error = state.error
  const healthmonitor = state.item
  const isLoading = state.isLoading

  return ( 
    <React.Fragment>
      {poolID &&
        <div className="">
          <div className="display-flex">
            <h5>Health Monitor</h5>
            <HelpPopover text="Checks the health of the pool members. Unhealthy members will be taken out of traffic schedule. Set's a load balancer to OFFLINE when all members are unhealthy." />
            <div className="btn-right">
              <DefeatableLink
                disabled={isLoading}
                to={`/loadbalancers/${loadbalancerID}/healthmonitor/new?${searchParamsToString(props)}`}
                className='btn btn-primary btn-xs'>
                New Health Monitor
              </DefeatableLink>            
            </div>          
          </div>

          {healthmonitor ?
            <div className="row">

              <div className="col-md-12">
                <b>Name/ID:</b>
              </div>          
              <div className="row">
                <div className="col-md-12">
                  {healthmonitor.name || healthmonitor.id}
                </div>
              </div>
              {healthmonitor.name && 
                <div className="row">
                  <div className="col-md-12 text-nowrap">
                    <small className="info-text">{healthmonitor.id}</small>
                  </div>
                </div>
              }
            </div>
          :
            <span>No Health Monitor found</span>
          }

        </div>
      }
    </React.Fragment>
   );
}
 
export default HealthMonitor;