import { useState } from 'react'
import useCommons from '../../../lib/hooks/useCommons'
import CopyPastePopover from '../shared/CopyPastePopover'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';

const L7RuleListItem = ({l7Rule, searchTerm, tableScroll}) => {
  const {MyHighlighter} = useCommons()

  const handleDelete = () => {
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
      <td><StateLabel placeholder={l7Rule.operating_status} path="" /></td>
      <td><StateLabel placeholder={l7Rule.provisioning_status} path=""/></td>
      <td>
        {l7Rule.type}
      </td>
      <td>
        {l7Rule.compare_type}
      </td>
      <td>
        {l7Rule.invert ?
          <i className="fa fa-check-square-o" />
          :
          <i className="fa fa-square-o" />
        }
      </td>
      <td>
        {l7Rule.key}
      </td>
      <td>
        <CopyPastePopover text={l7Rule.value} size={12} shouldClose={tableScroll}/>
      </td>
      <td>
        <StaticTags tags={l7Rule.tags} />
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