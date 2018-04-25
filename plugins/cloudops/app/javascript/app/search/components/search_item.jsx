import { Link } from 'react-router-dom'
import { SearchHighlight } from 'lib/components/search_highlight'

export default ({item, term}) =>
  <tr>
    <td>{item.cached_object_type}</td>
    <td>
      <Link to={`/search/${item.id}/show`}>
        <SearchHighlight term={term} text={item.id}/>
      </Link>
    </td>
    <td>
      <SearchHighlight term={term} text={item.name}/>
    </td>
    <td>
      <Link to={`/search/${item.project_id}/show`}>
        <SearchHighlight term={term} text={item.project_id}/>
      </Link>
    </td>
  </tr>
