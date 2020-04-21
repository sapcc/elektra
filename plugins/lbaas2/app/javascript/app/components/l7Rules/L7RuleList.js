import { useState, useEffect } from 'react'
import {DefeatableLink} from 'lib/components/defeatable_link';
import useCommons from '../../../lib/hooks/useCommons'
import HelpPopover from '../shared/HelpPopover'
import useL7Rule from '../../../lib/hooks/useL7Rule';
import { useGlobalState } from '../StateProvider'
import { Table } from 'react-bootstrap'
import ErrorPage from '../ErrorPage';
import L7RuleListItem from './L7RuleListItem'

const L7RulesList = ({props, loadbalancerID}) => {
  const {searchParamsToString} = useCommons()
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
                <div className="btn-right">
                  {!selected &&
                    <DefeatableLink
                      disabled={isLoading}
                      to={`/loadbalancers/${loadbalancerID}/l7policies/${policyID}/l7rules/new?${searchParamsToString(props)}`}
                      className='btn btn-primary btn-xs'>
                      New L7 Rule
                    </DefeatableLink>
                  }
                </div>
              </div>

              <Table className={l7Rules.length>0 ? "table table-hover l7rules" : "table l7rules"} responsive>
                  <thead>
                      <tr>
                          <th>ID</th>
                          <th>State/Prov. Status</th>
                          <th>Type/Compare Type</th>
                          <th>Invert</th>
                          <th>Key</th>
                          <th>Value</th>
                          <th>Tags</th>
                          <th className='snug'></th>
                      </tr>
                  </thead>
                  <tbody>
                    {l7Rules && l7Rules.length>0 ?
                      l7Rules.map( (l7Rule, index) =>
                        <L7RuleListItem loadbalancerID={loadbalancerID} listenerID={listenerID} policyID={policyID} l7Rule={l7Rule} key={index}/>
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