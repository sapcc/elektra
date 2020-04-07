import React from 'react';
import useCommons from '../../../lib/hooks/useCommons'
import { Link } from 'react-router-dom';
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import CopyPastePopover from '../shared/CopyPastePopover'

const L7PolicyListItem = React.memo(({l7Policy, searchTerm, tableScroll}) => {
  const {MyHighlighter} = useCommons()
  const {actionRedirect} = useL7Policy()

  const onClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
  }

  const handleDelete = () => {
  }

  console.log("RENDER L7 Policy Item")

  return ( 
    <tr>
      <td className="snug-nowrap">
        <Link to="#" onClick={onClick}>
          <MyHighlighter search={searchTerm}>{l7Policy.name || l7Policy.id}</MyHighlighter>
        </Link>
        {l7Policy.name && 
            <React.Fragment>
              <br/>
              <span className="info-text">
                <MyHighlighter search={searchTerm}>
                  <CopyPastePopover text={l7Policy.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids"/>
                </MyHighlighter>
              </span>
            </React.Fragment>
          }
      </td>
      <td><MyHighlighter search={searchTerm}>{l7Policy.description}</MyHighlighter></td>
      <td><StateLabel placeholder={l7Policy.operating_status} path="" /></td>
      <td><StateLabel placeholder={l7Policy.provisioning_status} path=""/></td>
      <td>
        <StaticTags tags={l7Policy.tags} />
      </td>
      <td>{l7Policy.position}</td>
      <td>
        {l7Policy.action}
        {actionRedirect(l7Policy.action).map( (redirect, index) =>
          <span className="display-flex">
            <br/><b>{redirect.label}: </b>
            {redirect.value === "redirect_prefix" || redirect.value === "redirect_url" ?
              <CopyPastePopover text={l7Policy[redirect.value]} size={20} shouldClose={tableScroll} bsClass="cp label-right"/>
            :
            <span className="label-right">{l7Policy[redirect.value]}</span>              
            }
          </span>
        )}
      </td>
      <td></td>
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
},(oldProps,newProps) => {
  const identical = JSON.stringify(oldProps.l7Policy) === JSON.stringify(newProps.l7Policy) && 
                    oldProps.searchTerm === newProps.searchTerm && 
                    oldProps.tableScroll === newProps.tableScroll
  return identical                  
})
 
export default L7PolicyListItem;