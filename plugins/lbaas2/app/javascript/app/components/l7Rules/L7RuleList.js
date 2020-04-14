import { useState } from 'react'
import {DefeatableLink} from 'lib/components/defeatable_link';
import HelpPopover from '../shared/HelpPopover'
import { Link } from 'react-router-dom';
import useL7Policy from '../../../lib/hooks/useL7Policy';
import { useGlobalState } from '../StateProvider'

const L7RulesList = ({onSelectedPolicy}) => {
  const {reset} = useL7Policy()
  const policyID = useGlobalState().l7policies.selected
  const [isLoading, setIsLoading] = useState(false)
  const [selected, setSelected] = useState(false)

  const onCloseClick = () => {
    reset()
  }

  return ( 
    <React.Fragment>
      {policyID &&
        <div className="subtalbe multiple-subtable-right">
          {/* <div className="display-flex">
            <Link to="#" className="close-link" onClick={onCloseClick}>
              <i className="fa fa-times fa-fw"></i>
            </Link>
          </div> */}
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
        </div> 
      }
    </React.Fragment>
   );
}
 
export default L7RulesList;