/* eslint no-console:0 */
import { Link, withRouter } from 'react-router-dom'
import { SearchField } from 'lib/components/search_field';

// render all components inside a hash router
export default withRouter((props) => {
  const search = (term) => {
    // if(term==null|| term.trim().length==0) return

    props.search({term})
    props.history.replace(`/universal-search`)
  }

  return(
    <div className="flex-header-sticky">
      <div className="mega-nav-responsive">
        <div className="container">
          <div className="mega-nav-items">
            <div className="mega-nav-block">
              <h5>
                <i className="fa fa-fw fa-search"></i>
                Finding All the Things
              </h5>
              <ul>
                <li>
                  <Link to='/universal-search'>Universal Search</Link>
                </li>
                <li>
                  <Link to='/project-user-role-assignments'>Project User Role Assignments</Link>
                </li>
              </ul>
            </div>
          </div>

          <div className="mega-nav-utils">
            <SearchField
              onChange={(term) => search(term)}
              value={props.objects.searchTerm}
              placeholder='Object ID, name or project ID'/>
          </div>
        </div>
      </div>
    </div>
  )
})
