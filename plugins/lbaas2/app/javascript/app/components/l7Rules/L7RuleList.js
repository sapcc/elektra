import { useState, useEffect } from 'react'
import {DefeatableLink} from 'lib/components/defeatable_link';
import HelpPopover from '../shared/HelpPopover'
import useL7Rule from '../../../lib/hooks/useL7Rule';
import { useGlobalState } from '../StateProvider'
import { Table } from 'react-bootstrap'
import ErrorPage from '../ErrorPage';

const L7RulesList = ({props, loadbalancerID}) => {
  const {persistL7Rules} = useL7Rule()
  const listenerID = useGlobalState().listeners.selected
  const policyID = useGlobalState().l7policies.selected
  const state = useGlobalState().l7rules

  useEffect(() => {    
    initialLoad()
  }, [policyID]);

  const initialLoad = () => {
    if (policyID) {
      console.log("FETCH L7 RULES")
      persistL7Rules(loadbalancerID, listenerID, policyID, null).then((data) => {
      }).catch( error => {
      })
    }
  }

  const error = state.error
  const hasNext = state.hasNext
  const searchTerm = state.searchTerm
  const selected = state.selected
  const isLoading = state.isLoading
  const l7Rules = state.items

  return ( 
    <React.Fragment>
      {policyID &&
        <React.Fragment>
          {error ?
            <div className="subtalbe multiple-subtable-right">
              <ErrorPage headTitle="L7 Rules" error={error} onReload={initialLoad}/>
            </div>
            :
            <div className="subtalbe multiple-subtable-right">
              <div className="display-flex">
                <h5>L7 Rules</h5>
                <HelpPopover text="An L7 Rule is a single, simple logical test which returns either true or false. It consists of a rule type, a comparison type, a value, and an optional key that gets used depending on the rule type. An L7 rule must always be associated with an L7 policy." />
                {!selected &&
                    <DefeatableLink
                      disabled={isLoading}
                      to={`/loadbalancers/`}
                      className='btn btn-link btn-right'>
                      New L7 Rule
                    </DefeatableLink>
                  }
              </div>

              <Table className={l7Rules.length>0 ? "table table-hover l7rules" : "table l7rules"} responsive>
                  <thead>
                      <tr>
                          <th>ID</th>
                          <th>Type</th>
                          <th>Compare Type</th>
                          <th>State</th>
                          <th>Prov. Status</th>
                          <th>Tags</th>
                          <th>Key</th>
                          <th>Value</th>
                          <th>Invers</th>
                          <th className='snug'></th>
                      </tr>
                  </thead>
                  <tbody>
                    {l7Rules && l7Rules.length>0 ?
                      l7Rules.map( (l7Rule, index) =>
                        <div></div>
                      )
                      :
                      <tr>
                        <td colSpan="10">
                          { isLoading ? <span className='spinner'/> : 'No L7 Rules found.' }
                        </td>
                      </tr>  
                    }
                  </tbody>
                </Table>
            </div> 
          }
        </React.Fragment>
      }
    </React.Fragment>
   );
}
 
export default L7RulesList;