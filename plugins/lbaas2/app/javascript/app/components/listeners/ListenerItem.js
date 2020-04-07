import React from 'react';
import { Link } from 'react-router-dom';
import { Highlighter } from 'react-bootstrap-typeahead'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';
import CopyPastePopover from '../shared/CopyPastePopover'

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

const ListenerItem = ({listener, searchTerm, onSelectListener, disabled}) => {

  const onClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectListener(listener.id)
  }

  const handleDelete = () => {
  }


  const displayName = () => {
    const name = listener.name || listener.id
    const cutName = <CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldPopover={false} shouldCopy={false}/>
    if (disabled) {
        return <span className="info-text">{cutName}</span>
    } else {
      if (searchTerm) {
        return <Link to={`/loadbalancers/${listener.id}/show`}>
                <MyHighlighter search={searchTerm}>{name}</MyHighlighter>
              </Link>
      } else {
        return <Link to={`/loadbalancers/${listener.id}/show`}>
                <MyHighlighter search={searchTerm}>{cutName}</MyHighlighter>
              </Link>
      }
    }
  }
  const displayID = () => {
    const copyPasteId = <CopyPastePopover text={listener.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids"/>
    const cutId = <CopyPastePopover text={listener.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldPopover={false}/>
    if (listener.name) {
      if (disabled) {
        return <span className="info-text">{cutId}</span>
      } else {
        if (searchTerm) {
          return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{listener.id}</MyHighlighter></span></React.Fragment>
        } else {
          return copyPasteId
        }        
      }
    }
  }
  const displayDescription = () => {
    const description = <CopyPastePopover text={listener.description} size={20} shouldCopy={false} shouldPopover={true}/>
    if (disabled) {
      return description
    } else {
      if (searchTerm) {
        return <MyHighlighter search={searchTerm}>{listener.description}</MyHighlighter>
      } else {
        return description
      }
    }
  }

  const l7PolicyIDs = listener.l7policies.map(l7p => l7p.id)
  return ( 
    <tr className={disabled ? "active" : ""}>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
      </td>
      <td>{displayDescription()}</td>
      <td><StateLabel placeholder={listener.operating_status} path="" /></td>
      <td><StateLabel placeholder={listener.provisioning_status} path=""/></td>
      <td>
        <StaticTags tags={listener.tags} />
      </td>
      <td>{listener.protocol}</td>
      <td>{listener.protocol_port}</td>
      <td>
        {listener.default_pool_id ?
          <OverlayTrigger placement="top" overlay={<Tooltip id="defalult-pool-tooltip">{listener.default_pool_id}</Tooltip>}>
            <i className="fa fa-check" />
          </OverlayTrigger>  
          :
          <i className="fa fa-times" />
        }
      </td>
      <td>{listener.connection_limit}</td>
      <td>{l7PolicyIDs.length}</td>
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
 
export default ListenerItem;