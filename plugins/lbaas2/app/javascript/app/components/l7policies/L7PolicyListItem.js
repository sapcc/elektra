import { useState } from 'react'
import useCommons from '../../../lib/hooks/useCommons'
import { Link } from 'react-router-dom';
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import CopyPastePopover from '../shared/CopyPastePopover'

const L7PolicyListItem = React.memo(({l7Policy, searchTerm, tableScroll, onSelected}) => {
  const {MyHighlighter} = useCommons()
  const {actionRedirect} = useL7Policy()
  const [disabled, setDisabled] = useState(false)

  const onClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelected(l7Policy.id)
  }

  const handleDelete = () => {
  }

  const displayName = () => {
    const name = l7Policy.name || l7Policy.id
    if (disabled) {
        return <span className="info-text"><CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldPopover={false} shouldCopy={false} bsClass="cp copy-paste-ids"/></span>
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
    const copyPasteId = <CopyPastePopover text={l7Policy.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldClose={tableScroll}/>
    if (l7Policy.name) {
      if (disabled) {
        return <span className="info-text"><CopyPastePopover text={l7Policy.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldPopover={false}/></span>
      } else {
        if (searchTerm) {
          return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{l7Policy.id}</MyHighlighter></span></React.Fragment>
        } else {
          return copyPasteId
        }        
      }
    }
  }
  const displayDescription = () => {
    const description = <CopyPastePopover text={l7Policy.description} size={20} shouldCopy={false} shouldClose={tableScroll} shouldPopover={true}/>
    if (disabled) {
      return description
    } else {
      if (searchTerm) {
        return <MyHighlighter search={searchTerm}>{l7Policy.description}</MyHighlighter>
      } else {
        return description
      }
    }
  }

  console.log("RENDER L7 Policy Item")
  return ( 
    <tr>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
      </td>
      <td>{displayDescription()}</td>
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
      <td>{l7Policy.rules.length}</td>
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