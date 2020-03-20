import React from 'react';
import { Link } from 'react-router-dom';
import { Highlighter } from 'react-bootstrap-typeahead'
import StateLabel from '../StateLabel'
import { Tooltip, OverlayTrigger } from 'react-bootstrap';

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

  return ( 
    <tr className={disabled ? "active" : ""}>
      <td className="snug-nowrap">
        {disabled ?
          <span className="info-text"><MyHighlighter search={searchTerm}>{listener.name || listener.id}</MyHighlighter></span>
         :
          <Link to="#" onClick={onClick}>
            <MyHighlighter search={searchTerm}>{listener.name || listener.id}</MyHighlighter>
          </Link>
        }
        {listener.name && 
            <React.Fragment>
              <br/>
              <span className="info-text"><MyHighlighter search={searchTerm}>{listener.id}</MyHighlighter></span>
            </React.Fragment>
          }
      </td>
      <td><MyHighlighter search={searchTerm}>{listener.description}</MyHighlighter></td>
      <td><StateLabel placeholder={listener.operating_status} path="" /></td>
      <td><StateLabel placeholder={listener.provisioning_status} path=""/></td>
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