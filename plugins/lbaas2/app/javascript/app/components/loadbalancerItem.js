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
        {loadbalancer.name}
      </td>
      <td>{loadbalancer.description}</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  )
})
LoadbalancerItem.displayName = 'LoadbalancerItem';

export default LoadbalancerItem;