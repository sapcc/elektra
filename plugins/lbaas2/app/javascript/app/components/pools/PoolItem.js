import React from 'react';
import { Link } from 'react-router-dom';
import { Highlighter } from 'react-bootstrap-typeahead'

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

const PoolItem = ({pool, searchTerm, onSelectPool}) => {

  const onClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool(pool.id)
  }

  return ( 
    <tr>
      <td className="snug-nowrap">
        <Link to="#" onClick={onClick}>
          <MyHighlighter search={searchTerm}>{pool.name || pool.id}</MyHighlighter>
        </Link>
        {pool.name && 
            <React.Fragment>
              <br/>
              <span className="info-text"><MyHighlighter search={searchTerm}>{pool.id}</MyHighlighter></span>
            </React.Fragment>
          }
      </td>
      <td><MyHighlighter search={searchTerm}>{pool.description}</MyHighlighter></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
   );
}
 
export default PoolItem;