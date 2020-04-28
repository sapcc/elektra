import React from 'react'
import useCommons from '../../../lib/hooks/useCommons'
import CopyPastePopover from '../shared/CopyPastePopover'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import useL7Rule from '../../../lib/hooks/useL7Rule';

const L7RuleListItem = ({loadbalancerID, listenerID, policyID, l7Rule, searchTerm, tableScroll}) => {
  const {MyHighlighter} = useCommons()
  const {deleteL7Rule, displayInvert} = useL7Rule()

  const handleDelete = (e) => {
    e.preventDefault()
    deleteL7Rule(loadbalancerID, listenerID, policyID, l7Rule).then(() => {
    })
  }

  const displayID = () => {
    const copyPasteId = <CopyPastePopover text={l7Rule.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldClose={tableScroll}/>
    if (searchTerm) {
      return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{l7Rule.id}</MyHighlighter></span></React.Fragment>
    } else {
      return copyPasteId
    }
  }
  return ( 
    <tr>
      <td className="snug-nowrap">
        {displayID()}
      </td>
      <td>
        <StateLabel placeholder={l7Rule.operating_status} path="" /><br/>
        <StateLabel placeholder={l7Rule.provisioning_status} path=""/>
      </td>
      <td>
        <StaticTags tags={l7Rule.tags} shouldPopover={true}/>
      </td>
      <td className="word-break">
        {l7Rule.type}<br/>
        {l7Rule.compare_type}
      </td>
      <td>
        {displayInvert(l7Rule.invert)}
      </td>
      <td>
        <CopyPastePopover text={l7Rule.key} size={12} shouldClose={tableScroll}/>
      </td>
      <td>
        <CopyPastePopover text={l7Rule.value} size={12} shouldClose={tableScroll}/>
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
 
export default L7RuleListItem;