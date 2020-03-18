import React from 'react';
import { Link } from 'react-router-dom';

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

const ListenerItem = ({listener, searchTerm}) => {
  return ( 
    <tr>
      <td className="snug-nowrap">
        <Link to={`/listeners/${listener.id}/show`}>
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