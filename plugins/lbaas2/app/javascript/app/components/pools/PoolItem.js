import React from 'react';
import { Link } from 'react-router-dom';
import { Highlighter } from 'react-bootstrap-typeahead'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import CopyPastePopover from '../shared/CopyPastePopover'

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

const PoolItem = ({pool, searchTerm, onSelectPool, disabled}) => {

  const onClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool(pool.id)
  }

  const handleDelete = () => {
  }

  const displayName = () => {
    const name = pool.name || pool.id
    const cutName = <CopyPastePopover text={name} size={20} sliceType="MIDDLE" shouldPopover={false} shouldCopy={false}/>
    if (disabled) {
        return <span className="info-text">{cutName}</span>
    } else {
      if (searchTerm) {
        return <Link to={`/loadbalancers/${pool.id}/show`}>
                <MyHighlighter search={searchTerm}>{name}</MyHighlighter>
              </Link>
      } else {
        return <Link to={`/loadbalancers/${pool.id}/show`}>
                <MyHighlighter search={searchTerm}>{cutName}</MyHighlighter>
              </Link>
      }
    }
  }
  const displayID = () => {
    const copyPasteId = <CopyPastePopover text={pool.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids"/>
    const cutId = <CopyPastePopover text={pool.id} size={12} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldPopover={false}/>
    if (pool.name) {
      if (disabled) {
        return <span className="info-text">{cutId}</span>
      } else {
        if (searchTerm) {
          return <React.Fragment><br/><span className="info-text"><MyHighlighter search={searchTerm}>{pool.id}</MyHighlighter></span></React.Fragment>
        } else {
          return copyPasteId
        }        
      }
    }
  }
  const displayDescription = () => {
    const description = <CopyPastePopover text={pool.description} size={20} shouldCopy={false} shouldPopover={true}/>
    if (disabled) {
      return description
    } else {
      if (searchTerm) {
        return <MyHighlighter search={searchTerm}>{pool.description}</MyHighlighter>
      } else {
        return description
      }
    }
  }

  return ( 
    <tr className={disabled ? "active" : ""}>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
      </td>
      <td>{displayDescription()}</td>
      <td><StateLabel placeholder={pool.operating_status} path="" /></td>
      <td><StateLabel placeholder={pool.provisioning_status} path=""/></td>
      <td>
        <StaticTags tags={pool.tags} />
      </td>
      <td>{pool.protocol}</td>
      <td>{pool.lb_algorithm}</td>
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
}
 
export default PoolItem;