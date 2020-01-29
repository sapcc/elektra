import React from 'react'
import { Highlighter } from 'react-bootstrap-typeahead'
import {Link} from 'react-router-dom';

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

const LoadbalancerItem = React.memo(({loadbalancer, searchTerm}) => {
  console.log('render item')
  return(
    <tr>
      <td>
        <Link to={`/${loadbalancer.id}/show`}>
          <MyHighlighter search={searchTerm}>{loadbalancer.name || loadbalancer.id}</MyHighlighter>
        </Link>
        {loadbalancer.name && 
            <React.Fragment>
              <br/>
              <span className='info-text'><MyHighlighter search={searchTerm}>{loadbalancer.id}</MyHighlighter></span>
            </React.Fragment>
          }
      </td>
      <td>{loadbalancer.description}</td>
      <td></td>
      <td></td>
      <td className="snug-nowrap">
        {loadbalancer.subnet && 
          <React.Fragment>
            <p className="list-group-item-text">{loadbalancer.subnet.name}</p>
          </React.Fragment>
        }
        {loadbalancer.vip_address && 
          <React.Fragment>
            <p className="list-group-item-text">
              <i className="fa fa-desktop fa-fw"/>
              {loadbalancer.vip_address}
            </p>
          </React.Fragment>
        }
        {loadbalancer.floating_ip && 
          <React.Fragment>
            <p className="list-group-item-text">
              <i className="fa fa-globe fa-fw"/>
              {loadbalancer.floating_ip.floating_ip_address}
            </p>
          </React.Fragment>
        }
      </td>
      <td></td>
      <td></td>
    </tr>
  )
})
LoadbalancerItem.displayName = 'LoadbalancerItem';

export default LoadbalancerItem;