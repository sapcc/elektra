import React from 'react';
import { Link } from 'react-router-dom';
import { Highlighter } from 'react-bootstrap-typeahead'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';

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

  return ( 
    <tr className={disabled ? "active" : ""}>
      <td className="snug-nowrap">
        {disabled ?
            <span className="info-text"><MyHighlighter search={searchTerm}>{pool.name || pool.id}</MyHighlighter></span>
          :
          <Link to="#" onClick={onClick}>
            <MyHighlighter search={searchTerm}>{pool.name || pool.id}</MyHighlighter>
          </Link>
        }
        {pool.name && 
            <React.Fragment>
              <br/>
              <span className="info-text"><MyHighlighter search={searchTerm}>{pool.id}</MyHighlighter></span>
            </React.Fragment>
          }
      </td>
      <td><MyHighlighter search={searchTerm}>{pool.description}</MyHighlighter></td>
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