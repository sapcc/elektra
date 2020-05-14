import React from 'react';
import CopyPastePopover from '../shared/CopyPastePopover'
import useCommons from '../../../lib/hooks/useCommons'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';

const MemberListItem = ({loadbalancerID,poolID,member,searchTerm}) => {
  const {MyHighlighter} = useCommons()

  const handleDelete = () => {}

  const displayName = () => {
    const name = member.name || member.id  
    if (searchTerm) {
      return <MyHighlighter search={searchTerm}>{name}</MyHighlighter>
    } else {
      return <CopyPastePopover text={name} size={20} sliceType="MIDDLE"/> 
    }
  }

  const displayID = () => {
    if (member.name) {
      if (searchTerm) {
        return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{member.id}</MyHighlighter></span></React.Fragment>
      } else {
        return <CopyPastePopover text={member.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids"/>
      }        
    }
  }

  return (     
    <tr>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
      </td>
      <td>        
        <CopyPastePopover text={member.address} size={12}/>
      </td>
      <td>
        <StateLabel placeholder={member.operating_status} path="" /><br/>
        <StateLabel placeholder={member.provisioning_status} path=""/>
      </td>
      <td>
        <StaticTags tags={member.tags} shouldPopover={true}/>
      </td>
      <td>        
        <CopyPastePopover text={member.protocol_port} size={12}/>
      </td>
      <td>{member.weight}</td>
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
 
export default MemberListItem;