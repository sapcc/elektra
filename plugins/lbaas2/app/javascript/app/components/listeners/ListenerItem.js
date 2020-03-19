import React from 'react';
import { Link } from 'react-router-dom';
import { Highlighter } from 'react-bootstrap-typeahead'

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

const ListenerItem = ({listener, searchTerm, onSelectListener}) => {

  const onClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectListener(listener.id)
  }

  return ( 
    <tr>
      <td className="snug-nowrap">
        <Link to="#" onClick={onClick}>
          <MyHighlighter search={searchTerm}>{listener.name || listener.id}</MyHighlighter>
        </Link>
        {listener.name && 
            <React.Fragment>
              <br/>
              <span className="info-text"><MyHighlighter search={searchTerm}>{listener.id}</MyHighlighter></span>
            </React.Fragment>
          }
      </td>
      <td><MyHighlighter search={searchTerm}>{listener.description}</MyHighlighter></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
   );
}
 
export default ListenerItem;